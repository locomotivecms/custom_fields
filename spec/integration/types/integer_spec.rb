require 'spec_helper'

describe CustomFields::Types::Integer do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the age' do
      @post.age = 10
      @post.attributes['age'].should == 10
    end

    it 'returns the age' do
      @post.age = 11
      @post.age.should == 11
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :age => 12

      Object.send(:remove_const, @post.custom_fields_recipe['name'])

      @post = Post.find(@post._id)
    end

    it 'returns the age' do
      @post.age.should == 12
    end

    it 'also returns the age' do
      blog = Blog.find(@blog._id)
      post = blog.posts.find(@post._id)
      post.age.should == 12
    end

    it 'sets a new age' do
      @post.age = 13
      @post.save
      @post = Post.find(@post._id)
      @post.age.should == 13
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'age', :type => 'integer'
      blog.save & blog.reload
    end
  end
end
