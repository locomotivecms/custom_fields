require 'spec_helper'

describe CustomFields::ProxyClassEnabler do

  context '#proxy klass' do

    before(:each) do
      (@parent = Object.new).stubs(:task_custom_fields).returns([])
      @parent.stubs(:_id).returns(42)
      @klass = Task.to_klass_with_custom_fields([], @parent, 'task_custom_fields')
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

    it 'adds field to itself' do
      @klass.apply_custom_field(CustomFields::Field.new({
        :label => 'In charge',
        :kind => 'string',
        :_name => 'custom_field_1',
        :_alias => 'person',
        :_parent => @parent,
        :association_name => 'task_custom_fields'
      }))

      @klass.custom_fields.should_not be_empty
      @klass.custom_fields.first.label = 'In charge'
    end

  end

end