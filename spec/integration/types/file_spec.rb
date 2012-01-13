require 'spec_helper'

describe CustomFields::Types::File do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'attaches the file' do
      @post.image = FixturedFile.open('doc.txt')
      @post.save
      @post.image.url.should == '/uploads/doc.txt'
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :image => FixturedFile.open('doc.txt')
      @post = Post.find(@post._id)
    end

    it 'returns the url to the file' do
      @post.image.url.should == '/uploads/doc.txt'
    end

    it 'attaches a new file' do
      @post.image = FixturedFile.open('another_doc.txt')
      @post.save
      @post = Post.find(@post._id)
      @post.image.url.should == '/uploads/another_doc.txt'
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :banner => FixturedFile.open('doc.txt')
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      @post.banner.url.should == '/uploads/doc.txt'
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr
      @post.banner.url.should == '/uploads/doc.txt'
      @post.banner = FixturedFile.open('another_doc.txt')
      @post.save
      @post = Post.find(@post._id)
      @post.banner.url.should == '/uploads/another_doc.txt'
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'image',   :type => 'file'
      blog.posts_custom_fields.build :label => 'banner',  :type => 'file', :localized => true
      blog.save & blog.reload
    end
  end
end