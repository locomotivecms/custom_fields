require 'spec_helper'

describe CustomFields::Field do

  it 'is initialized' do
    lambda { CustomFields::Field.new }.should_not raise_error
  end


  it 'removes dashes in the alias if alias comes from label' do
    field = CustomFields::Field.new(:label => 'foo-bar')
    field.send(:set_alias)
    field.alias.should == 'foo_bar'
  end

  context '#validating' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    %w(foo-bar f- 42test -52).each do |value|
      it "does not accept alias like #{value}" do
        stub_field_for_validation(@field)
        @field.alias = value
        @field.valid?.should be_false
        @field.errors[:alias].should_not be_empty
      end
    end

    %w(a a42 ab a_b a_ abc_ abc foo42_bar).each do |value|
      it "accepts alias like #{value}" do
        stub_field_for_validation(@field)
        @field.alias = value
        @field.valid?
        @field.errors[:alias].should be_empty
      end
    end

    %w(id _id save destroy send class).each do |name|
      it "does not accept very unsecure name like #{name}" do
        stub_field_for_validation(@field)
        @field.alias = name
        @field.valid?.should == false
        @field.errors[:alias].should_not be_empty
      end
    end

    # it 'owns a method to validate without running the invalidate_proxy_klass callback' do
    #   @field.stubs(:uniqueness_of_label_and_alias).returns(true)
    #   @field.expects(:invalidate_proxy_klass).never
    #   @field.quick_valid?.should be_false
    #   @field.label = 'Foo'
    #   @field._alias = 'foo'
    #   @field.kind = 'string'
    #   @field.quick_valid?.should be_true
    # end

  end

  def stub_field_for_validation(field)
    # field.stubs(:invalidate_proxy_klass).returns(true)
    field.stubs(:uniqueness_of_label_and_alias).returns(true)
  end

end