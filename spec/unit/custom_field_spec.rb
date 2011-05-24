require 'spec_helper'

describe CustomFields::Field do

  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end
    
  
  it 'removes dashes in the alias if alias comes from label' do
    field = CustomFields::Field.new(:label => 'foo-bar')
    field.send(:set_alias)
    field._alias.should == 'foo_bar'
  end
  
  context '#validating' do
  
    before(:each) do
      @field = CustomFields::Field.new
    end
    
    %w(foo-bar f- 42test -52).each do |_alias|
      it "does not accept _alias like #{_alias}" do
        stub_field_for_validation(@field)
        @field._alias = _alias
        @field.valid?.should be_false
        @field.errors[:_alias].should_not be_empty
      end
    end
    
    %w(a a42 ab a_b a_ abc_ abc foo42_bar).each do |_alias|
      it "accepts _alias like #{_alias}" do
        stub_field_for_validation(@field)
        @field._alias = _alias
        @field.valid?
        @field.errors[:_alias].should be_empty
      end
    end
    
    %w(id _id save destroy send class).each do |name|
      it "does not accept very unsecure name like #{name}" do
        @field.stubs(:set_target_klass_flag).returns(true)
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
    parent.stubs(:self_custom_field_custom_fields_version).returns(0)
    Project.to_klass_with_custom_fields(field, parent, 'self_custom_fields').new
  end
  
  def stub_field_for_validation(field)
    field.stubs(:set_target_klass_flag).returns(true)
    field.stubs(:uniqueness_of_label_and_alias).returns(true) 
  end

end