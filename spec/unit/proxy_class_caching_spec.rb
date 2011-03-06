require 'spec_helper'

describe 'Caching ProxyClass defined by CustomFields' do

  before(:each) do
    @project = Project.new(:_id => 1)
  end

  context '#fetching' do

    it 'builds once a dynamic class' do
      Task.expects(:build_proxy_class_with_custom_fields).returns(Class.new).once
      2.times.each do
        @project.fetch_task_klass
      end
    end

  end

  context '#invalidating' do

    it 'invalidates a dynamic class' do
      @project.fetch_task_klass
      Object.const_defined?('TaskProject1').should be_true
      @project.invalidate_task_klass
      Object.const_defined?('TaskProject1').should be_false
    end

    it 'invalidates a dynamic class when validating the model' do
      @project.expects(:invalidate_task_klass).once
      @project.valid?
    end

  end

end