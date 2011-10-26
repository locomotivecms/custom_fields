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
        stub_field_for_validation(@field)
        @field._alias = name
        @field.valid?.should == false
        @field.errors[:_alias].should_not be_empty
      end
    end

  end

  def stub_field_for_validation(field)
    field.stubs(:uniqueness_of_label_and_alias).returns(true)
  end

end