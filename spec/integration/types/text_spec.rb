require 'spec_helper'

describe CustomFields::Types::Text do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the excerpt' do
      @post.excerpt = 'Well, hello world'
      @post.attributes['excerpt'].should == 'Well, hello world'
    end

    it 'returns the excerpt' do
      @post.excerpt = 'Well, hello world'
      @post.excerpt.should == 'Well, hello world'
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :excerpt => 'Well, hello world'
      @post = Post.find(@post._id)
    end

    it 'returns the excerpt' do
      @post.excerpt.should == 'Well, hello world'
    end

    it 'sets a new excerpt' do
      @post.excerpt = 'A new one'
      @post.save
      @post = Post.find(@post._id)
      @post.excerpt.should == 'A new one'
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Excerpt', :type => 'text', :text_formatting => 'html'
      blog.save & blog.reload
    end
  end
end