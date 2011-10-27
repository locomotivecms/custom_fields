require 'spec_helper'

describe 'Invalidating proxy klass' do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @field = @project.tasks_custom_fields.build(:label => 'Hours', :_alias => 'hours', :kind => 'string')
    @project.tasks_custom_fields.build(:label => 'Done', :_alias => 'done', :kind => 'boolean')
    @project.save
    @project = Project.find(@project._id) # hard reload
  end

  it 'does not increment the version if there are no changes' do
    @project.name = 'Locomotive (TEST)'
    @project.name_changed?.should be_true
    @project.save!
    @project.tasks.build.class.version.should == 1
  end

  context 'by adding field' do

    it 'invalidates klass' do
      @project.tasks_custom_fields.build(:label => 'Price', :_alias => 'price', :kind => 'string')
      task = @project.tasks.build
      @project.save # @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:price).should be_true
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'tasks_custom_fields_attributes' => {
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
      @project.tasks_custom_fields.first._alias = 'hours_modified'
      @project.save && @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
      task.respond_to?(:hours_modified).should be_true
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'tasks_custom_fields_attributes' => {
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
      @project.tasks_custom_fields.first.destroy
      @project.tasks_custom_fields.size.should == 1
      @project.tasks_custom_fields_version.should == 2
      @project = Project.find(@project._id) # hard reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
    end

    it 'invalidates klass through accepts_nested_attributes_for' do
      @project.update_attributes({ 'tasks_custom_fields_attributes' => {
        '1' => { 'id' => @field._id.to_s, '_destroy' => 'true' }
      } })
      @project.reload
      task = @project.tasks.build
      task.class.version.should == 2
      task.respond_to?(:hours).should be_false
    end

  end

end