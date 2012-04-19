require 'spec_helper'

describe CustomFields::Types::ManyToMany do

  before(:each) do
    @blog     = create_blog
    @post_1   = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :published => true
    @post_2   = @blog.posts.create :title => 'High and Dry', :body => 'Lorem ipsum...', :published => false
    @post_3   = @blog.posts.create :title => 'Nude', :body => 'Lorem ipsum...', :published => true

    @author_1 = @blog.people.create :name => 'John Doe'
    @author_2 = @blog.people.create :name => 'Jane Doe'
  end

  it 'assigns posts to an author' do
    author = assign_posts_to_author @author_1, [@post_1, @post_3]
    author.posts.map(&:title).should == ['Nude', 'Hello world']
  end

  it 'assigns posts to authors' do
    author_1 = assign_posts_to_author @author_1, [@post_1, @post_3]
    author_2 = assign_posts_to_author @author_2, [@post_2, @post_3]
    author_1.posts.map(&:title).should == ['Nude', 'Hello world']
    author_2.posts.map(&:title).should == ['Nude', 'High and Dry']
  end

  it 'returns the authors of a post' do
    assign_posts_to_author @author_1, [@post_1, @post_3]
    assign_posts_to_author @author_2, [@post_2, @post_3]
    @post_3 = Post.find(@post_3._id)
    @post_3.authors.map(&:name).should == ['John Doe', 'Jane Doe']
  end

  it 'returns the posts based on the order in the post_ids field' do
    assign_posts_to_author @author_1, [@post_1, @post_3, @post_2]
    author = Person.find(@author_1._id)
    author.posts.filtered.map(&:title).should == ['Hello world', 'Nude', 'High and Dry']
    author.posts.map(&:title).should == ['Nude', 'High and Dry', 'Hello world']
  end

  it 'filters the posts' do
    assign_posts_to_author @author_1, [@post_1, @post_3, @post_2]
    author = Person.find(@author_1._id)
    author.posts.filtered({ :published => true }).map(&:title).should == ['Hello world', 'Nude']
  end

  it 'filters and orders the posts' do
    assign_posts_to_author @author_1, [@post_1, @post_3, @post_2]
    author = Person.find(@author_1._id)
    author.posts.filtered({ :published => true }, %w(title desc)).map(&:title).should == ['Nude', 'Hello world']
  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.people_custom_fields.build :label => 'Posts',      :type => 'many_to_many', :class_name => "Post#{blog._id}", :inverse_of => :authors, :order_by => ['title', 'desc']
      blog.posts_custom_fields.build  :label => 'Authors',    :type => 'many_to_many', :class_name => "Person#{blog._id}", :inverse_of => :posts
      blog.posts_custom_fields.build  :label => 'Published',  :type => 'boolean'
      blog.save & blog.reload
    end
  end

  def assign_posts_to_author(author, posts)
    author.posts = posts
    author.save
    Person.find(author._id)
  end

end