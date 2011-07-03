require 'spec_helper'

describe 'Invalidating proxy klass' do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @field = @project.task_custom_fields.build(:label => 'Hours', :_alias => 'hours', :kind => 'string')
    @project.task_custom_fields.build(:label => 'Done', :_alias => 'done', :kind => 'boolean')
    @project.save && @project.reload
  end

  context 'by adding field' do

    it 'invalidates klass' do
      @project.task_custom_fields.build(:label => 'Price', :_alias => 'price', :kind => 'string')
      @project.save && @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:price).should be_true
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'task_custom_fields_attributes' => {
        '1' => { 'label' => 'Price', '_alias' => 'price', 'kind' => 'string' }
      } })
      @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:price).should be_true
    end

  end

  context 'by updating field' do

    it 'invalidates klass' do
      @project.task_custom_fields.first._alias = 'hours_modified'
      @project.save && @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
      task.respond_to?(:hours_modified).should be_true
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'task_custom_fields_attributes' => {
        '1' => { 'id' => @field._id.to_s, '_alias' => 'hours_modified_2' }
      } })
      @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
      task.respond_to?(:hours_modified_2).should be_true
    end

  end

  context 'by destroying field' do

    it 'invalidates klass' do
      @project.task_custom_fields.first.destroy
      @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'task_custom_fields_attributes' => {
        '1' => { 'id' => @field._id.to_s, '_destroy' => '1' }
      } })
      @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
    end

  end

end