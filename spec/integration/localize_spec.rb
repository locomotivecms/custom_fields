# encoding: utf-8

require 'spec_helper'

describe 'CustomFields::Localize' do

  before(:each) do
    @blog = create_blog
    @blog = Blog.find(@blog._id)
  end

  it 'mimics the original I18n class' do
    Mongoid::Fields::I18n.locale.should == :en
    Mongoid::Fields::I18n.locale = 'fr'
    Mongoid::Fields::I18n.locale.should == :fr
  end

  it 'handles fallbacks' do
    Mongoid::Fields::I18n.fallbacks[:en].should == [:en]
    Mongoid::Fields::I18n.fallbacks[:fr].should == [:fr, :en]
  end

  it 'translate a field from the origin I18n class' do
    Mongoid::Fields::I18n.locale = nil
    post = @blog.posts.build :title => 'Hello world', :body => 'Yeaaaah', :url => '/foo_en.html'
    post.url.should == '/foo_en.html'
    ::I18n.locale = :fr
    post.url.should == '/foo_en.html'
    post.url = '/foo_fr.html'
    post.url.should == '/foo_fr.html'
    I18n.locale = :en
    post.url.should == '/foo_en.html'
  end

  it 'sets the post attributes in French and valids it in English' do
    ::I18n.locale = :en
    Mongoid::Fields::I18n.locale = :fr
    post = @blog.posts.build :body => 'Youpi', :url => '/foo_fr.html'
    post.url.should == '/foo_fr.html'
    post.valid?
    post.errors[:title].should == ["can't be blank"]
  end

  it 'sets the post attributes in English and valids it in French' do
    ::I18n.locale = :fr
    Mongoid::Fields::I18n.locale = :en
    post = @blog.posts.build :body => 'Yeeaah', :url => '/foo_en.html'
    post.url.should == '/foo_en.html'
    post.url_translations[:fr].should be_nil
    Mongoid::Fields::I18n.locale = :fr
    post.url = '/foo_fr.html'
    post.url.should == '/foo_fr.html'
    post.valid?
    post.errors[:title].should == ["doit être rempli(e)"]
  end

  describe 'previously not translated' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Yeaaaah', :main_author => 'Mister Foo'
      @blog.posts_custom_fields.first.localized = true
      @blog.save
    end

    it 'translated it' do
      post = Post.find(@post._id)
      post.main_author.should == 'Mister Foo'
    end

    it 'allows another translation' do
      post = Post.find(@post._id)
      Mongoid::Fields::I18n.locale = :fr
      post.main_author.should == 'Mister Foo'
      post.main_author = 'Monsieur Foo'
      post.main_author_translations['fr'].should == 'Monsieur Foo'
    end

    it 'can be reverted' do
      @blog.posts_custom_fields.first.localized = false
      @blog.save
      post = Post.find(@post._id)
      post.main_author.should == 'Mister Foo'
      post.respond_to?(:main_author_translations).should be_false
    end

  end

  # describe 'dealing with other field types' do
  #
  #   before(:each) do
  #     @blog.posts_custom_fields.build :label => 'Published', :type => 'boolean', :localized => true
  #     @blog.save
  #   end
  #
  #   describe '#boolean' do
  #
  #     it 'serializes' do
  #       post = @blog.posts.build :title => 'Hello world', :body => 'Yeaaaah', :main_author => 'Mister Foo', :published => true
  #       post.published.should be_true
  #     end
  #
  #     it 'serializes in a different locale' do
  #       post = @blog.posts.build :title => 'Hello world', :body => 'Yeaaaah', :main_author => 'Mister Foo', :published => true
  #       Mongoid::Fields::I18n.locale = :fr
  #       post.published = false
  #       post.published_translations['fr'].should == false
  #     end
  #
  #     it 'deserializes' do
  #       post = @blog.posts.create :title => 'Hello world', :body => 'Yeaaaah', :main_author => 'Mister Foo', :published => true
  #       post = Post.find(post._id)
  #       post.published.should be_true
  #     end
  #
  #   end
  #
  # end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Main Author', :type => 'string'
      blog.posts_custom_fields.build :label => 'Url',         :type => 'string', :localized => true
      blog.save
    end
  end
end