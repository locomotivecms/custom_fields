require 'spec_helper'

describe CustomFields::Types::Select do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the category from an existing name' do
      @post.main_category = 'Development'
      @post.attributes['main_category_id'].should == @development_cat._id
    end

    it 'sets the category from an id' do
      @post.main_category = @development_cat._id
      @post.attributes['main_category_id'].should == @development_cat._id
    end

    it 'returns the name of the category' do
      @post.main_category = @design_cat._id
      @post.main_category.should == 'Design'
    end

  end

  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :main_category => @marketing_cat._id
      @post = Post.find(@post._id)
    end

    it 'returns the main category' do
      @post.main_category.should == 'Marketing'
    end

    it 'assigns a new main category' do
      @post.main_category = @design_cat._id
      @post.save
      @post = Post.find(@post._id)
      @post.main_category.should == 'Design'
    end

    it 'create a new category and assigns it' do
      category = @blog.posts_custom_fields.first.select_options.build :name => 'Sales'
      @blog.save
      @post = Post.find(@post._id)
      @post.main_category = 'Sales'
      @post.attributes['main_category_id'].should == category._id
      @post.save
      @post = Post.find(@post._id)
      @post.main_category.should == 'Sales'
    end

  end

  describe 'group_by' do

    before(:each) do
      @blog.posts.create :title => 'Hello world 1(Development)', :body => 'Lorem ipsum...', :main_category => @development_cat._id
      @blog.posts.create :title => 'Hello world (Design)', :body => 'Lorem ipsum...', :main_category => @design_cat._id
      @blog.posts.create :title => 'Hello world 2 (Development)', :body => 'Lorem ipsum...', :main_category => @development_cat._id
      @blog.posts.create :title => 'Hello world 3 (Development)', :body => 'Lorem ipsum...', :main_category => @development_cat._id

      klass = @blog.klass_with_custom_fields(:posts)
      @groups = klass.group_by_select_option(:main_category)
    end

    it 'is an non empty array' do
      @groups.class.should == Array
      @groups.size.should == 3
    end

    it 'is an array of hashes composed of a name' do
      @groups.map { |g| g[:name] }.should == %w{Design Development Marketing}
    end

    it 'is an array of hashes composed of a list of documents' do
      @groups[0][:items].size.should == 1
      @groups[1][:items].size.should == 3
      @groups[2][:items].size.should == 0
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Main category', :type => 'select'

      @design_cat       = field.select_options.build :name => 'Design'
      @development_cat  = field.select_options.build :name => 'Development'
      @marketing_cat    = field.select_options.build :name => 'Marketing'

      blog.save & blog.reload
    end
  end

end