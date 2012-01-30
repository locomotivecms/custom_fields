require 'spec_helper'

describe CustomFields::Types::BelongsTo do

  before(:each) do
    @blog   = create_blog
    @author = @blog.people.create(:name => 'John Doe')
    @another_author = @blog.people.create(:name => 'Jane Doe')
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the author' do
      @post.author = @author
      @post.save
      @post.author.name.should == 'John Doe'
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :author => @author
      @post = Post.find(@post._id)
    end

    it 'returns the name of the author' do
      @post.author.name.should == 'John Doe'
    end

    it 'sets a new author' do
      @post.author = @another_author
      @post.save
      @post = Post.find(@post._id)
      @post.author.name.should == 'Jane Doe'
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Author', :type => 'belongs_to', :class_name => 'Person'
      blog.save & blog.reload
    end
  end
end