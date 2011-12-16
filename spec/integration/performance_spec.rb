require 'spec_helper'

describe 'Performance' do

  occurences = 100

  context 'with custom fields' do

    before(:each) do
      @blog = create_blog
      create_posts(@blog, occurences)
      @blog = Blog.find(@blog._id)
    end

    it "retrieves #{occurences} posts" do
      MyBenchmark.measure("retrieving #{occurences} posts") do
        @blog.posts.all.collect(&:title)
      end
    end

    it "retrieves #{occurences} posts and trigger methods" do
      MyBenchmark.measure("retrieving #{occurences} posts") do
        @blog.posts.all.each do |entry|
          entry.main_author = 'john'
          entry.location = 'chicago'
        end
      end
    end

  end

  context 'without custom fields' do

    before(:each) do
      @blog = create_blog(false)
      create_posts(@blog, occurences)
      @blog = Blog.find(@blog._id)
    end

    it "retrieves #{occurences} posts" do
      MyBenchmark.measure("retrieving #{occurences} posts") do
        @blog.posts.all.collect(&:title)
      end
    end

    it "retrieves #{occurences} posts and trigger methods" do
      MyBenchmark.measure("retrieving #{occurences} posts") do
        @blog.posts.all.each do |entry|
          entry.title = 'yeaah'
          entry.body = 'a test'
        end
      end
    end

  end

  def create_blog(custom_fields = true)
    Blog.new(:name => 'My personal blog').tap do |blog|
      if custom_fields
        blog.posts_custom_fields.build :label => 'Main Author', :type => 'string'
        blog.posts_custom_fields.build :label => 'Location',    :type => 'string'
        blog.posts_custom_fields.build :label => 'Posted at', :type => 'string'
        blog.posts_custom_fields.build :label => 'Published',    :type => 'string'
        # blog.posts_custom_fields.build :label => 'Posted at',   :type => 'date'
        # blog.posts_custom_fields.build :label => 'Published',   :type => 'boolean'
      end
      blog.save
    end
  end

  def create_posts(blog, n)
    n.times do |i|
      blog.posts.create :title => "Hello world #{i}", :body => 'Lorem ipsum...'
    end
  end

  # def occurences
  #   100
  # end

end