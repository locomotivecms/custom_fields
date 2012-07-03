require 'spec_helper'

describe CustomFields::Types::Boolean do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  context '#true' do

    it 'sets value from an integer' do
      @post.visible = 1
      @post.visible.should == true
    end

    it 'sets value from a string' do
      @post.visible = '1'
      @post.visible.should == true

      @post.visible = 'true'
      @post.visible.should == true
    end

  end

  context '#false' do

    it 'is false by default' do
      @post.visible.should == false
      @post.visible?.should == false
    end

    it 'sets value from an integer' do
      @post.visible = 0
      @post.visible.should == false
    end

    it 'sets value from a string' do
      @post.visible = '0'
      @post.visible.should == false

      @post.visible = 'false'
      @post.visible.should == false
    end

  end

  context '#localize' do

    before(:each) do
      field = @blog.posts_custom_fields.build :label => 'Published', :type => 'boolean', :localized => true
      field.valid?
      @blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build :published => true
      post.published.should be_true
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build :published => true
      Mongoid::Fields::I18n.locale = :fr
      post.published = false
      post.published_translations['fr'].should == false
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Visible', :type => 'boolean'
      field.valid?
    end
  end

end