require 'spec_helper'

describe 'Performance' do

  occurences = 1000

  available_tags = %w(some tags picked at random)

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
  
  context 'with custom fields including tags' do

    before(:each) do
      @blog = create_blog_with_tags
      create_posts_with_tags(@blog, occurences, available_tags)
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

    it "retrieves #{occurences} posts via tags" do
      MyBenchmark.measure("retrieving #{occurences} posts") do
        groups = @blog.posts.group_by_tag(:topics)
        groups.class.should == Array
      end
    end


  end
  

  def create_blog(custom_fields = true)
    Blog.new(:name => 'My personal blog').tap do |blog|
      if custom_fields
        blog.posts_custom_fields.build :label => 'Main Author', :type => 'string'
        blog.posts_custom_fields.build :label => 'Location',    :type => 'string'
        blog.posts_custom_fields.build :label => 'Posted at',   :type => 'date'
        blog.posts_custom_fields.build :label => 'Published',   :type => 'boolean'
      end
      blog.save
    end
  end

  def create_posts(blog, n)
    n.times do |i|
      blog.posts.create :title => "Hello world #{i}", :body => 'Lorem ipsum...'
    end
  end

  def create_blog_with_tags(custom_fields = true)
    Blog.new(:name => 'My personal blog').tap do |blog|
      if custom_fields
        blog.posts_custom_fields.build :label => 'Main Author', :type => 'string'
        blog.posts_custom_fields.build :label => 'Location',    :type => 'string'
        blog.posts_custom_fields.build :label => 'Posted at',   :type => 'date'
        blog.posts_custom_fields.build :label => 'Published',   :type => 'boolean'
        blog.posts_custom_fields.build :label => 'Topics',   :type => 'tag_set'
      end
      blog.save
    end
  end

  def create_posts_with_tags(blog, n, available_tags)
    number_available_tags = available_tags.length;
    
    n.times do |i|
       number_of_tags_to_use = rand(number_available_tags)
       instance_tag_list = []
       
       for i in 0..number_of_tags_to_use
         instance_tag_list << available_tags[rand(number_available_tags)]
       end
       blog.posts.create :title => "Hello world #{i}", :body => 'Lorem ipsum...', :topics => instance_tag_list
    end
  end

end