require 'spec_helper'

describe CustomFields::Types::String do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the author' do
      @post.author = 'John Doe'
      @post.attributes['author'].should == 'John Doe'
    end

    it 'returns the author' do
      @post.author = 'John Doe'
      @post.author.should == 'John Doe'
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :author => 'John Doe'
      @post = Post.find(@post._id)
    end

    it 'returns the author' do
      @post.author.should == 'John Doe'
    end

    it 'sets a new author' do
      @post.author = 'Jane Doe'
      @post.save
      @post = Post.find(@post._id)
      @post.author.should == 'Jane Doe'
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'author', :type => 'string'
      blog.save & blog.reload
    end
  end
end