require 'spec_helper'

describe 'CustomFieldsFor' do

  before(:each) do
    @blog = build_blog
  end

  it 'makes sure the field names are correctly set' do
    @blog.valid?
    @blog.posts_custom_fields.first.name.should == 'main_author'
  end

  context 'no posts' do

    describe 'recipe' do

      before(:each) do
        @blog.valid?
        @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
      end

      it 'is included in new posts' do
        @post.title.should == 'Hello world'
        @post.custom_fields_recipe.should_not be_false
      end

    end

  end

  context 'with a bunch of existing posts' do

    before(:each) do
      @blog = Blog.create(:name => 'My personal blog')
      @blog.posts.create :title => 'Hello world',   :body => 'Lorem ipsum...'
      @blog.posts.create :title => 'Welcome home',  :body => 'Lorem ipsum...'
      @blog.reload

      @blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      @blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
      @blog.save
      @blog.reload
    end

    it 'includes the new fields' do
      post = @blog.posts.first
      post.attributes.key?('main_author').should be_true
      post.attributes.key?('location').should be_true
    end

    it 'renames field' do
      @blog.posts_custom_fields.first.name = 'author'
      @blog.save & @blog.reload
      post = @blog.posts.first
      post.attributes.key?('author').should be_true
      post.attributes.key?('main_author').should be_false
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
    end
  end
end