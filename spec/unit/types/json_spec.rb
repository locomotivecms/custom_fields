# frozen_string_literal: true

describe CustomFields::Types::Json do
  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  it 'sets value from a string' do
    @post.metadata = '{"author":"John Doe","visitors":43}'

    expect(@post.metadata).to eq({ 'author' => 'John Doe', 'visitors' => 43 })
  end

  it 'sets value from a hash' do
    @post.metadata = { 'author' => 'John Doe', 'visitors' => 43 }

    expect(@post.metadata).to eq({ 'author' => 'John Doe', 'visitors' => 43 })
  end

  it 'sets nil from an invalid string' do
    @post.metadata = '{a:2'
    expect(@post.metadata).to be_nil
  end

  it 'sets nil value' do
    @post.metadata = nil

    expect(@post.metadata).to be_nil
  end

  it 'sets empty value' do
    @post.metadata = ''

    expect(@post.metadata).to be_nil
  end

  describe 'validation' do
    it 'should not valid if the value is not a valid JSON hash' do
      @post.metadata = '{a:2'
      expect(@post.valid?).to eq false
      expect(@post.errors[:metadata]).not_to be_blank
    end

    it 'should not valid if the value is a string (which is a valid JSON)' do
      @post.metadata = '2'
      expect(@post.valid?).to eq false
      expect(@post.errors[:metadata]).not_to be_blank
    end

    it 'should be valid if the value is an empty string' do
      @post.metadata = ''
      expect(@post.metadata).to eq nil
      expect(@post.valid?).to eq true
    end
  end

  context '#localize' do
    let(:metadata) { '{"author":"John Doe","visitors":43}' }
    let(:metadata_fr) { '{"author":"Jean Personne","visitors":43}' }

    before(:each) do
      field = @blog.posts_custom_fields.build label: 'Metadata', type: 'json', localized: true

      field.valid?

      @blog.bump_custom_fields_version :posts
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build metadata: metadata

      expect(post.metadata).to eq({ 'author' => 'John Doe', 'visitors' => 43 })
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build metadata: metadata

      Mongoid::Fields::I18n.locale = :fr

      post.metadata = metadata_fr

      expect(post.metadata_translations['fr']).to eq({ 'author' => 'Jean Personne', 'visitors' => 43 })
    end
  end

  describe 'getter and setter' do
    it 'returns an empty hash if no value has been set' do
      expect(@post.class.json_attribute_get(@post, 'metadata')).to eq({})
    end

    it 'returns the value' do
      @post.metadata = '{"author":"John Doe","visitors":43}'

      expected = {
        'metadata' => { 'author' => 'John Doe', 'visitors' => 43 }
      }

      expect(@post.class.json_attribute_get(@post, 'metadata')).to eq expected
    end

    it 'sets a nil value' do
      expect(@post.class.json_attribute_set(@post, 'metadata', {})).to be_nil
    end

    it 'sets a value' do
      @post.class.json_attribute_set(@post, 'metadata', { 'metadata' => { 'author' => 'John Doe', 'visitors' => 43 } })
      expect(@post.metadata).to eq({ 'author' => 'John Doe', 'visitors' => 43 })
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Metadata', type: 'json'

      field.valid?
    end
  end
end
