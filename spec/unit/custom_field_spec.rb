require 'spec_helper'

describe CustomFields::Field do

  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end


  it 'removes dashes in the name if name comes from label' do
    field = CustomFields::Field.new(label: 'foo-bar')
    field.send(:set_name)
    field.name.should == 'foo_bar'
  end

  context '#validating' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    %w(foo-bar f- 42test -52).each do |value|
      it "does not accept name like #{value}" do
        stub_field_for_validation(@field)
        @field.name = value
        @field.valid?.should be_false
        @field.errors[:name].should_not be_empty
      end
    end

    %w(a a42 ab a_b a_ abc_ abc foo42_bar).each do |value|
      it "accepts name like #{value}" do
        stub_field_for_validation(@field)
        @field.name = value
        @field.valid?
        @field.errors[:name].should be_empty
      end
    end

    %w(id _id save destroy send class).each do |name|
      it "does not accept very unsecure name like #{name}" do
        stub_field_for_validation(@field)
        @field.name = name
        @field.valid?.should == false
        @field.errors[:name].should_not be_empty
      end
    end

  end

  def stub_field_for_validation(field)
    field.stubs(:uniqueness_of_label_and_name).returns(true)
  end

end