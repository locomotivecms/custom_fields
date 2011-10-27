require 'spec_helper'

describe 'Caching ProxyClass defined by CustomFields' do

  before(:each) do
    @project = Project.new(:_id => 1)
  end

  context '#fetching' do

    it 'builds once a dynamic class' do
      (klass = Class.new).cattr_accessor :version
      klass.version = 0
      Task.expects(:build_klass_with_custom_fields).returns(klass).once
      2.times.each do
        @project.rebuild_custom_fields_relation(:tasks)
      end
    end

  end

  context '#invalidating' do

    it 'invalidates a dynamic class' do
      @project.rebuild_custom_fields_relation(:tasks)
      Object.const_defined?('TaskProject1').should be_true
      @project.invalidate_tasks_klass
      Object.const_defined?('TaskProject1').should be_false
    end

    it 'does not bump the current version if no changes for the custom fields' do
      @project.send(:bump_tasks_custom_fields_version)
      @project.tasks_custom_fields_version.should == 0
    end

    it 'does bump the current version if changes for the custom fields' do
      @project.mark_klass_with_custom_fields_as_invalidated('tasks')
      @project.send(:bump_tasks_custom_fields_version)
      @project.tasks_custom_fields_version.should == 1
    end

    it 'does not invalidate a dynamic class when validating the model' do
      @project.expects(:invalidate_tasks_klass).never
      @project.valid?
    end

  end

end