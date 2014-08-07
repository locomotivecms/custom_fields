require 'spec_helper'

describe CustomFields::Types::Tags do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the tags as array' do
      @post.tags = ['one', 'two']
      @post.attributes['tags'].should == ['one', 'two']
    end

    it 'returns the tags' do
      @post.tags = ['one', 'two']
      @post.tags.should == ['one', 'two']
    end

    it "sets the tags as a string" do
      @post.tags = 'one,two, three ,four  ,  five'
      @post.tags.should == %w[one two three four five]
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', tags: ['one', 'two']
      @post = Post.find(@post._id)
    end

    it 'does not modify the other Post class' do
      post = Post.new
      post.respond_to?(:tags).should be false
    end

    it 'returns the tags' do
      @post.tags.should == ['one', 'two']
    end

    it 'sets a new posted_at date' do
      @post.tags = "new, tags"
      @post.save!
      @post = Post.find(@post._id)
      @post.tags.should == ['new', 'tags']
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', localized_tags: ['hello', 'world']
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      @post.localized_tags.should == %w[hello world]
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr
      @post.localized_tags.should == %w[hello world]
      @post.localized_tags = ['bonjour']
      @post.save
      @post = Post.find(@post._id)
      @post.localized_tags.should == ['bonjour']
      Mongoid::Fields::I18n.locale = :en
      @post.localized_tags.should == ['hello', 'world']
    end

  end

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'tags', type: 'tags'
      blog.posts_custom_fields.build label: 'localized_tags',  type: 'tags', localized: true
      blog.save & blog.reload
    end
  end
end