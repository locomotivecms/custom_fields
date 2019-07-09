describe 'CustomFields::Field' do

  before(:each) do
    @blog = create_blog
    @blog = Blog.find @blog._id
  end

  describe 'nested attributes' do

    it 'renames a field' do
      @blog.posts_custom_fields_attributes = {
        '0' => { '_id' => @blog.posts_custom_fields.last._id.to_s, 'label' => 'My location' },
        '1' => { '_id' => @blog.posts_custom_fields.first._id.to_s, 'label' => 'Author' }
      }

      @blog.save

      expect(@blog.posts_custom_fields.first.label).to eq 'Author'
      expect(@blog.posts_custom_fields.last.label).to eq 'My location'
    end

  end

  describe 'validation' do
    let(:blog)  { build_blog }
    let(:field) { blog.posts_custom_fields.first }

    context '#inclusion_of_appearance_type' do
      it "always passes when appearance_type is blank" do
        field.appearance_type = nil
        expect(blog.valid?).to eq true
      end

      it "should not accepts invalid appearance type" do
        field.appearance_type = 'invalid'
        expect(blog.valid?).to eq false
      end

      it "should accepts valid appearance type" do
        field.appearance_type = CustomFields::Types::Select::Field::AVAILABLE_APPEARANCE_TYPES.first
        expect(blog.valid?).to eq true
      end

      xit "always passes when type does not has AVAILABLE_APPEARANCE_TYPES" do
        field.appearance_type = 'invalid'
        expect(blog.valid?).to eq true
      end
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Main Author', type: 'string'
      blog.posts_custom_fields.build label: 'Location',    type: 'string'

      blog.save
    end
  end

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Main category', type: 'select', required: true, default: 'IT'
      field.select_options.build name: 'Test'
      field.valid?
    end
  end

end