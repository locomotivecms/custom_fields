describe CustomFields::Types::Boolean do

  let(:default) { nil }
  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  describe 'setting a value' do

    context 'true' do

      it 'sets value from an integer' do
        expect(post.visible).to eq false
        post.visible = 1
        expect(post.visible).to eq true
      end

      it 'sets value from a string' do
        post.visible = '1'

        expect(post.visible).to be true

        post.visible = 'true'

        expect(post.visible).to be true
      end

    end

    context 'false' do

      it 'is false by default' do
        expect(post.visible).to be false
        expect(post.visible?).to be false
      end

      it 'sets value from an integer' do
        post.visible = 0

        expect(post.visible).to be false
      end

      it 'sets value from a string' do
        post.visible = '0'

        expect(post.visible).to be false

        post.visible = 'false'

        expect(post.visible).to be false
      end

    end

  end

  describe 'default value' do

    let(:default) { true }

    subject { post.visible }

    it { is_expected.to eq true }

  end

  describe 'localization' do

    before(:each) do
      field = blog.posts_custom_fields.build label: 'Published', type: 'boolean', localized: true

      field.valid?

      blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = blog.posts.build published: true

      expect(post.published).to be true
    end

    it 'serializes / deserializes in a different locale' do
      post = blog.posts.build published: true

      Mongoid::Fields::I18n.locale = :fr

      post.published = false

      expect(post.published_translations['fr']).to be false
    end

  end

  describe 'getter and setter' do

    it 'returns the value' do
      post.visible = true

      expect(post.class.boolean_attribute_get(post, 'visible')).to eq({ 'visible' => true })
    end

    it 'sets a nil value' do
      expect(post.class.boolean_attribute_set(post, 'visible', {})).to be_nil
    end

    it 'sets a value' do
      post.class.boolean_attribute_set(post, 'visible', { 'visible' => 'true' })

      expect(post.visible).to be true
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Visible', type: 'boolean', default: default
      field.valid?
    end
  end

end
