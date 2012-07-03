require 'spec_helper'

describe CustomFields::Types::Date do

  before(:each) do
    @blog = create_blog
    @date = Date.parse('2007-06-29')
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the posted_at date' do
      @post.posted_at = '2007-06-29'
      @post.attributes['posted_at'].should == @date
    end

    it 'returns the posted_at date' do
      @post.posted_at = '2007-06-29'
      @post.posted_at.should == @date
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :posted_at => @date
      @post = Post.find(@post._id)
    end

    it 'does not modify the other Post class' do
      post = Post.new
      post.respond_to?(:posted_at).should be_false
    end

    it 'returns the posted_at date' do
      @post.posted_at.should == @date
    end

    it 'sets a new posted_at date' do
      @post.posted_at = '2009-09-10'
      @post.save!
      @post = Post.find(@post._id)
      @post.posted_at.should == Date.parse('2009-09-10')
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :visible_at => @date
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      @post.visible_at.should == @date
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr
      @post.visible_at.should == @date
      @post.visible_at = '2009-09-10'
      @post.save
      @post = Post.find(@post._id)
      @post.visible_at.should == Date.parse('2009-09-10')
      Mongoid::Fields::I18n.locale = :en
      @post.visible_at.should == @date
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'posted_at',   :type => 'date'
      blog.posts_custom_fields.build :label => 'visible_at',  :type => 'date', :localized => true
      blog.save & blog.reload
    end
  end
end