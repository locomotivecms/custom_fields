describe CustomFields::Types::Select do

  let(:blog)  { build_blog }
  let(:field) { blog.posts_custom_fields.first }
  let(:post)  { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'stores the list of categories' do
    expect(field.respond_to?(:select_options)).to be true
  end

  it 'includes the categories in the as_json method' do
    expect(field.as_json['select_options']).not_to be_empty
  end

  it 'adds the categories when calling to_recipe' do
    expect(field.to_recipe['select_options']).not_to be_empty
  end

  it 'sets a value' do
    post.main_category = 'Test'
    expect(post.main_category).to eq 'Test'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.main_category = value
        expect(post.valid?).to eq false
        expect(post.errors[:main_category]).not_to be_blank
      end
    end

  end

  describe 'default value' do

    before do
      field.select_options.build name: 'Marketing'
      field.select_options.build name: 'IT'
    end

    subject { post.main_category }

    it { is_expected.to eq 'IT' }

  end

  context '#localize' do

    before(:each) do
      field = blog.posts_custom_fields.build label: 'Taxonomy', type: 'select', localized: true

      Mongoid::Fields::I18n.locale = :en

      @option_1 = field.select_options.build name: 'Item #1 in English'

      @option_2 = field.select_options.build name: 'Item #2 in English'

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Item #1 in French'

      @option_2.name = 'Item #2 in French'

      field.valid?

      Mongoid::Fields::I18n.locale = :en

      blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = blog.posts.build taxonomy: 'Item #1 in English'

      expect(post.taxonomy).to eq 'Item #1 in English'
    end

    it 'serializes / deserializes in a different locale' do
      post = blog.posts.build taxonomy: 'Item #1 in English'

      Mongoid::Fields::I18n.locale = :fr

      post.taxonomy = 'Item #2 in French'

      expect(post.taxonomy_id_translations['fr']).to eq @option_2._id
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(post.class.select_attribute_get(post, 'main_category')).to eq expected
    end

    it 'returns the value' do
      post.main_category = 'Test'

      expected = {
        'main_category'     => 'Test',
        'main_category_id'  => field.select_options.first._id
      }

      expect(post.class.select_attribute_get(post, 'main_category')).to eq expected
    end

    it 'sets a nil value' do
      expect(post.class.select_attribute_set(post, 'main_category', {})).to be_nil
    end

    it 'sets a value from a name' do
      post.class.select_attribute_set(post, 'main_category', { 'main_category' => 'Test' })

      expect(post.main_category).to eq 'Test'
    end

    it 'sets a value from an id' do
      post.class.select_attribute_set(post, 'main_category', { 'main_category' => field.select_options.first._id })

      expect(post.main_category).to eq 'Test'

      post.class.select_attribute_set(post, 'main_category', { 'main_category_id' => field.select_options.first._id })

      expect(post.main_category).to eq 'Test'
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Main category', type: 'select', required: true, default: 'IT'
      field.select_options.build name: 'Test'
      field.valid?
    end
  end

end
