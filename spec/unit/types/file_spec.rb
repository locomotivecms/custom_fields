# frozen_string_literal: true

describe CustomFields::Types::File do
  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  describe 'validation' do
    it 'should not valid if the value is nil' do
      @post.picture = nil

      expect(@post.valid?).to eq false
      expect(@post.errors[:picture]).not_to be_blank
    end
  end

  describe 'getter and setter' do
    it 'has a field to store the size of the file' do
      expect(@post).to respond_to(:picture_size)
    end

    it 'uses a hash (empty by default) to store the size of the file' do
      expect(@post.picture_size).to eq({})
    end

    it 'returns an empty hash if no value has been set' do
      expect(@post.class.file_attribute_get(@post, 'picture')).to eq({})
    end

    it 'returns the value' do
      @post.picture = FixturedFile.open 'doc.txt'

      expect(@post.class.file_attribute_get(@post, 'picture').key?('picture')).to eq true
      expect(@post.class.file_attribute_get(@post, 'picture').key?('picture_url')).to eq true
    end

    it 'sets a nil value' do
      @post.class.file_attribute_set(@post, 'picture', {})

      expect(@post.picture.to_s).to be_empty
    end

    it 'sets a value' do
      @post.class.file_attribute_set(@post, 'picture', { 'picture' => FixturedFile.open('doc.txt') })

      expect(@post.picture.to_s).not_to be_empty
    end

    it 'calls the remove_<name>= method of the uploader' do
      @post.expects(:remove_picture=).with(true)

      @post.class.file_attribute_set(@post, 'picture', { 'remove_picture' => true })
    end

    it 'calls the remote_<name>_url method of the uploader' do
      @post.expects(:remote_picture_url=).with('http://somewhere.org')

      @post.class.file_attribute_set(@post, 'picture', { 'remote_picture_url' => 'http://somewhere.org' })
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Picture', type: 'file', required: true

      field.valid?
    end
  end
end
