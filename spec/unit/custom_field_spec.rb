describe CustomFields::Field do

  it 'is initialized' do
    expect { CustomFields::Field.new }.to_not raise_error
  end

  it 'removes dashes in the name if name comes from label' do
    field = CustomFields::Field.new(label: 'foo-bar')
    field.send(:set_name)

    expect(field.name).to eql 'foo_bar'
  end

  context '#validating' do

    before(:each) do
      @field = CustomFields::Field.new

      stub_field_for_validation(@field)
    end

    %w[foo-bar f- 42test -52].each do |value|
      it "does not accept name like `#{value}`" do
        @field.name = value

        expect(@field.valid?).to be false
        expect(@field.errors[:name]).not_to be_empty
      end
    end

    %w[a a42 ab a_b a_ abc_ abc foo42_bar].each do |value|
      it "accepts name like `#{value}`" do
        @field.name = value

        @field.valid?

        # expect(@field.valid?).to be true
        expect(@field.errors[:name]).to be_empty
      end
    end

    %w[id _id save destroy send class].each do |name|
      it "does not accept reserved name like `#{name}`" do
        @field.name = name

        expect(@field.valid?).to be false
        expect(@field.errors[:name]).not_to be_empty
      end
    end

    %w[has_one bool].each do |type|
      it "does not accept unknown type like `#{type}`" do
        @field.type = type

        expect(@field.valid?).to be false
        expect(@field.errors[:type]).not_to be_empty
      end
    end

  end

  protected

  def stub_field_for_validation(field)
    field.stubs(:uniqueness_of_label_and_name).returns true
  end

end