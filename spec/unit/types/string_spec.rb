# frozen_string_literal: true

describe CustomFields::Types::String do
  let(:default) { nil }
  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'sets a value' do
    expect(post.author).to eq nil
    post.author = 'John Doe'
    expect(post.author).to eq 'John Doe'
  end

  describe 'validation' do
    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.author = value
        expect(post.valid?).to eq false
        expect(post.errors[:author]).not_to be_blank
      end
    end
  end

  describe 'default value' do
    let(:default) { 'Ricky G.' }

    subject { post.author }

    it { is_expected.to eq 'Ricky G.' }

    context 'when unsetting a value' do
      before do
        post.author = 'Stephen M.'
        post.author = nil
      end

      it { is_expected.to eq nil }
    end
  end

  describe 'getter and setter' do
    it 'returns an empty hash if no value has been set' do
      expect(post.class.string_attribute_get(post, 'author')).to eq({})
    end

    it 'returns the value' do
      post.author = 'John Doe'
      expect(post.class.string_attribute_get(post, 'author')).to eq('author' => 'John Doe')
    end

    it 'sets a nil value' do
      expect(post.class.string_attribute_set(post, 'author', {})).to be_nil
    end

    it 'sets a value' do
      post.class.string_attribute_set(post, 'author', { 'author' => 'John' })
      expect(post.author).to eq 'John'
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Author', type: 'string', required: true, default: default
      field.valid?
    end
  end
end
