require 'spec_helper'

describe CustomFields::Field do

  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end

  context '#validating' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    %w(save destroy send class).each do |name|
      it "does not accept very unsecure name like #{name}" do
        @field.stubs(:uniqueness_of_label_and_alias).returns(true)
        @field._alias = name
        @field.valid?.should == false
        @field.errors[:_alias].should_not be_empty
      end
    end

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
    (parent = Object.new).stubs(:_id).returns(42)
    Project.to_klass_with_custom_fields(field, parent, 'self_custom_fields').new
  end

end