require 'spec_helper'

describe 'Invalidating proxy klass' do

  before(:each) do
    puts "relations id = #{Project.relations.object_id}"
    @project = Project.new(:name => 'Locomotive')
    puts "relations id = #{@project.relations.object_id}"

    @field = @project.task_custom_fields.build(:label => 'Hours', :_alias => 'hours', :kind => 'string')
    @project.task_custom_fields.build(:label => 'Done', :_alias => 'done', :kind => 'boolean')
    @project.save
    puts "======================= RELOADING ================="
    @project = Project.find(@project._id) # hard reload
  end

  it 'does not increment the version if there are no changes' do
    puts "task_custom_fields_version (BEFORE)= #{@project.task_custom_fields_version.inspect} should == 1"
    puts "relations id (after saving) = #{@project.relations.object_id}"
    puts "-========-"
    @project.name = 'Locomotive (TEST)'
    @project.name_changed?.should be_true
    @project.save!
    puts "-=========-"
    puts "task_custom_fields_version (AFTER) = #{@project.task_custom_fields_version.inspect} should == 1"
    puts "task class object_id = #{@project.task_klass.object_id}"
    task = @project.tasks.build
    puts task.class.inspect
    puts task.class.custom_fields_version(task.class._parent, 'tasks')
    puts task.class.object_id
    task.class.version.should == 1
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