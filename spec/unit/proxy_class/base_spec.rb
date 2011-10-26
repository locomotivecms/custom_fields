require 'spec_helper'

describe CustomFields::ProxyClass::Base do

  context '#proxy klass' do

    before(:each) do
      (@parent = Object.new).stubs(:tasks_custom_fields).returns([])
      @parent.stubs(:_id).returns(42)
      @parent.stubs(:tasks_custom_fields_version).returns(0)
      @parent.stubs(:invalidate_tasks_klass_flag=).returns(true)
      @klass = Task.to_klass_with_custom_fields('tasks', @parent, [])
    end

    it 'does not be flagged as a inherited document' do
      @klass.new.hereditary?.should be_false
    end

    it 'has a list of custom fields' do
      @klass.custom_fields.should == nil
    end

    it 'has the exact same model name than its parent' do
      @klass.model_name.should == 'Task'
    end

    it 'does not add a field if it is not valid' do
      @klass.apply_custom_field(build_custom_field({ :label => 'In charge', :kind => 'string' }, false))
      @klass.custom_fields.should == nil
    end

    it 'adds field to itself' do
      apply_field(@klass)
      @klass.custom_fields.should_not be_empty
      @klass.custom_fields.first.label = 'In charge'
    end

    it 'does not apply twice a field' do
      2.times { apply_field(@klass) }
      @klass.custom_fields.size.should == 1
      apply_field(@klass, { :_name => 'custom_field_2', :_alias => 'person2' })
      @klass.custom_fields.size.should == 2
    end

    def apply_field(klass, attributes = {})
      attributes = {
        :label => 'In charge',
        :kind => 'string',
        :_name => 'custom_field_1',
        :_alias => 'person',
        :_parent => @parent,
        :association_name => 'task_custom_fields'
      }.merge(attributes)

      klass.apply_custom_field(build_custom_field(attributes))
    end

    def build_custom_field(attributes, is_valid = true)
      CustomFields::Field.new(attributes).tap do |field|
        field.stubs(:persisted?).returns(true)
        field.stubs(:valid?).returns(is_valid)
        field.stubs(:quick_valid?).returns(is_valid)
      end
    end

  end

end