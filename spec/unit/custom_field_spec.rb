require 'spec_helper'

describe CustomFields::Field do

  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end

  context '#mongoid' do

    before(:each) do
      @project = build_project
    end

    it 'is added to the list of mongoid fields' do
      @project.fields['field_1'].should_not be_nil
    end

  end

  context 'on target class' do

    before(:each) do
      @project = build_project
    end

    it 'has a new field' do
      @project.respond_to?(:manager).should be_true
    end

    it 'sets / retrieves a value' do
      @project.manager = 'Mickael Scott'
      @project.manager.should == 'Mickael Scott'
    end

  end

  def build_project
    field = CustomFields::Field.new(:label => 'manager', :_name => 'field_1', :kind => 'string', :_alias => 'manager')
    field.stubs(:valid?).returns(true)
    Project.to_klass_with_custom_fields(field, nil, 'self_custom_fields').new
  end

end