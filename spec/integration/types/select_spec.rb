require 'spec_helper'

describe CustomFields::Types::Select do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
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
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', main_category: @marketing_cat._id
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
      category = @blog.posts_custom_fields.first.select_options.build name: 'Sales'
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
      @blog.posts.create title: 'Hello world 1(Development)', body: 'Lorem ipsum...', main_category: @development_cat._id
      @blog.posts.create title: 'Hello world (Design)', body: 'Lorem ipsum...', main_category: @design_cat._id
      @blog.posts.create title: 'Hello world 2 (Development)', body: 'Lorem ipsum...', main_category: @development_cat._id
      @blog.posts.create title: 'Hello world 3 (Development)', body: 'Lorem ipsum...', main_category: @development_cat._id
      @blog.posts.create title: 'Hello world (Unknow)', body: 'Lorem ipsum...', main_category: Moped::BSON::ObjectId.new
      @blog.posts.create title: 'Hello world (Unknow) 2', body: 'Lorem ipsum...', main_category: Moped::BSON::ObjectId.new

      klass = @blog.klass_with_custom_fields(:posts)
      @groups = klass.group_by_select_option(:main_category)
    end

    it 'is an non empty array' do
      @groups.class.should == Array
      @groups.size.should == 4
    end

    it 'is an array of hashes composed of a name' do
      @groups.map { |g| g[:name].to_s }.should == ["Design", "Development", "Marketing", ""]
    end

    it 'is an array of hashes composed of a list of documents' do
      @groups[0][:entries].size.should == 1
      @groups[1][:entries].size.should == 3
      @groups[2][:entries].size.should == 0
      @groups[3][:entries].size.should == 2
    end

    it 'can be accessed from the parent document' do
      blog = Blog.find(@blog._id)
      blog.posts.group_by_select_option(:main_category).class.should == Array
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', author: 'Mister Foo'
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      @post.author.should == 'Mister Foo'
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr
      @post.author.should == 'Monsieur Foo'
      @post.author = 'Monsieur Bar'
      @post.save
      @post = Post.find(@post._id)
      @post.author.should == 'Monsieur Bar'
      Mongoid::Fields::I18n.locale = :en
      @post.author.should == 'Mister Foo'
    end

    it 'displays all the categories' do
      @post.class.author_options.first['name'] = 'Mister Foo'
      Mongoid::Fields::I18n.locale = :fr
      @post.class.author_options.first['name'] = 'Monsieur Foo'
      Mongoid::Fields::I18n.locale = :en
      @post.class.author_options.first['name'] = 'Mister Foo'
    end

  end

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Main category', type: 'select'

      Mongoid::Fields::I18n.locale = :en

      @design_cat       = field.select_options.build name: 'Design'
      @development_cat  = field.select_options.build name: 'Development'
      @marketing_cat    = field.select_options.build name: 'Marketing'

      field = blog.posts_custom_fields.build label: 'Author', type: 'select', localized: true

      @option_1 = field.select_options.build name: 'Mister Foo'
      @option_2 = field.select_options.build name: 'Mister Bar'

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Monsieur Foo'
      @option_2.name = 'Monsieur Bar'

      Mongoid::Fields::I18n.locale = :en

      blog.save & blog.reload
    end
  end

end
