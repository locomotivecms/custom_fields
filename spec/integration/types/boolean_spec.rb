require 'spec_helper'

describe CustomFields::Types::Boolean do

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

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :published => true
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      @post.published.should be_true
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr
      @post.published.should be_true
      @post.published = false
      @post.save
      @post = Post.find(@post._id)
      @post.published.should be_false
      Mongoid::Fields::I18n.locale = :en
      @post.published.should be_true
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Visible',   :type => 'boolean'
      blog.posts_custom_fields.build :label => 'Published', :type => 'boolean', :localized => true
      blog.save & blog.reload
    end
  end
end