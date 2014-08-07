require 'spec_helper'

describe CustomFields::Types::File do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be false
  end

  describe 'validation' do

    it "should not valid if the value is nil" do
      @post.picture = nil
      @post.valid?.should be false
      @post.errors[:picture].should_not be_blank
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      @post.class.file_attribute_get(@post, 'picture').should == {}
    end

    it 'returns the value' do
      @post.picture = FixturedFile.open('doc.txt')
      @post.class.file_attribute_get(@post, 'picture').key?('picture').should be true
      @post.class.file_attribute_get(@post, 'picture').key?('picture_url').should be true
    end

    it 'sets a nil value' do
      @post.class.file_attribute_set(@post, 'picture', {})
      @post.picture.to_s.should be_empty
    end

    it 'sets a value' do
      @post.class.file_attribute_set(@post, 'picture', { 'picture' => FixturedFile.open('doc.txt') })
      @post.picture.to_s.should_not be_empty
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

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Picture', type: 'file', required: true
      field.valid?
    end
  end

end