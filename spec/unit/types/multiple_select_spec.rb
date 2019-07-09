describe CustomFields::Types::MultipleSelect do

  let(:blog)  { build_blog }
  let(:field) { blog.posts_custom_fields.first }
  let(:post)  { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'stores the list of categories' do
    expect(field.respond_to?(:multiple_select_options)).to be true
  end

  it 'includes the categories in the as_json method' do
    expect(field.as_json['multiple_select_options']).not_to be_empty
  end

  it 'adds the categories when calling to_recipe' do
    expect(field.to_recipe['multiple_select_options']).not_to be_empty
  end

  it 'sets a value' do
    post.categories = ['Test']
    expect(post.categories).to eq ['Test']
  end

  it 'sets a appearance type' do
    field.update(appearance_type: 'checkbox')
    field.reload
    expect(field.appearance_type).to eq 'checkbox'
  end

  describe 'validation' do
    [nil, ''].each do |value|
      it "raise error if the value is #{value.inspect}" do
        expect { post.categories = value }.to raise_error(ArgumentError)
      end      
    end

    [[nil], ['']].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.categories = value
        expect(post.valid?).to eq false
        expect(post.errors[:categories]).not_to be_blank
      end
    end

    it "should not accepts invalid appearance type" do
      field.appearance_type = 'invalid'
      expect(blog.valid?).to eq false
    end

    it "should accepts valid appearance type" do
      field.appearance_type = CustomFields::Types::MultipleSelect::Field::AVAILABLE_APPEARANCE_TYPES.first
      expect(blog.valid?).to eq true
    end
  end

  describe 'default value' do

    before do
      field.multiple_select_options.build name: 'Marketing'
      field.multiple_select_options.build name: 'IT'
    end

    subject { post.categories }

    it { is_expected.to eq ['IT'] }

  end

  context '#localize' do

    before(:each) do
      field = blog.posts_custom_fields.build label: 'Taxonomies', type: 'multiple_select', localized: true

      Mongoid::Fields::I18n.locale = :en

      @option_1 = field.multiple_select_options.build name: 'Item #1 in English'

      @option_2 = field.multiple_select_options.build name: 'Item #2 in English'

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Item #1 in French'

      @option_2.name = 'Item #2 in French'

      field.valid?

      Mongoid::Fields::I18n.locale = :en

      blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = blog.posts.build taxonomies: ['Item #1 in English']

      expect(post.taxonomies).to eq ['Item #1 in English']
    end

    it 'serializes / deserializes in a different locale' do
      post = blog.posts.build taxonomies: ['Item #1 in English']

      Mongoid::Fields::I18n.locale = :fr

      post.taxonomies = ['Item #2 in French']

      expect(post.taxonomies_id_translations['fr']).to eq [@option_2._id]
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(post.class.multiple_select_attribute_get(post, 'categories')).to eq expected
    end

    it 'returns the value' do
      post.categories = ['Test']

      expected = {
        'categories'     => ['Test'],
        'categories_id'  => [field.multiple_select_options.first._id]
      }

      expect(post.class.multiple_select_attribute_get(post, 'categories')).to eq expected
    end

    it 'sets a nil value' do
      expect(post.class.multiple_select_attribute_set(post, 'categories', {})).to be_nil
    end

    it 'sets a value from a name' do
      post.class.multiple_select_attribute_set(post, 'categories', { 'categories' => ['Test'] })

      expect(post.categories).to eq ['Test']
    end

    it 'sets a value from an id' do
      post.class.multiple_select_attribute_set(post, 'categories', { 'categories' => [field.multiple_select_options.first._id] })

      expect(post.categories).to eq ['Test']

      post.class.multiple_select_attribute_set(post, 'categories', { 'categories_id' => [field.multiple_select_options.first._id] })

      expect(post.categories).to eq ['Test']
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Categories', type: 'multiple_select', required: true, default: ['IT']
      field.multiple_select_options.build name: 'Test'
      field.valid?
    end
  end

end
