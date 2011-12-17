require 'spec_helper'

describe CustomFields::Types::String do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the visible flag' do
      @post.visible = 'true'
      @post.attributes['visible'].should == true
    end

    it 'returns the visible flag' do
      @post.visible = 'true'
      @post.visible.should == true
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :visible => true
      @post = Post.find(@post._id)
    end

    it 'returns the visible flag' do
      @post.visible.should == true
    end

    it 'toggles the visible flag' do
      @post.visible = false
      @post.save
      @post = Post.find(@post._id)
      @post.visible.should == false
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Visible', :type => 'boolean'
      blog.save & blog.reload
    end
  end
end