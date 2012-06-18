require 'spec_helper'

describe CustomFields::Types::TagSet do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new post' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    end

    it 'sets the tags' do
      @post.topics = 'locomotive'
      @post.attributes['topics_ids'].should include(@locomotive_tag._id)
    end

    it 'adds a new tag to the list of used tags' do
      @post.topics = "cms, ruby"
      @post.topics.should include("ruby","cms")
    end
    
    it 'removes extra white space from tags' do
      @post.topics = "cms, ruby,   rails   ,  a b c"
      @post.topics.should include("ruby","cms", "rails", "a b c")
    end

    it 'can have no tags' do
      @post.topics = ""
      @post.topics.should == ""
    end

    it 'can be set via an array' do
      @post.topics = ['hello', ' world', 'carpe diem']
      @post.topics.should include("hello", "carpe diem", "world")
    end

    it 'returns the name of the tag' do
      @post.topics = ""
      @post.topics_ids.append(@locomotive_tag._id)
      @post.topics.should include('locomotive')
    end

    it 'ignores the case of tags' do
      @post.topics = 'LocomOtive'
      @post.attributes['topics_ids'].should include(@locomotive_tag._id)
    end



  end
  
  
  
  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :topics_ids => [@beach_tag._id, @castle_tag._id]
      @post = Post.find(@post._id)
    end

    it 'returns the tags' do
      @post.topics.should include("beach", "castle")
    end

    it 'assigns a new tag' do
      @post.topics_ids.append(@lego_tag._id)
      @post.save
      @post = Post.find(@post._id)
      @post.topics.should include("lego")
    end

    it 'create a new tag and assigns it' do
      tag = @blog.posts_custom_fields.first.tags_used.build :name => 'new_tag'
      @blog.save
      @post = Post.find(@post._id)
      @post.topics = 'new_tag'
      @post.attributes['topics_ids'].should include(tag._id)
      @post.save
      @post = Post.find(@post._id)
      @post.topics.should include( 'new_tag')
    end

  end

 describe 'group_by' do

    before(:each) do
      @blog.posts.create :title => 'Hello world 1(sun, beach)', :body => 'Lorem ipsum...', :topics_ids => [@sun_tag._id, @beach_tag._id]
      @blog.posts.create :title => 'Hello world 2(castle, lego)', :body => 'Lorem ipsum...', :topics_ids => [@castle_tag._id, @lego_tag._id]
      @blog.posts.create :title => 'Hello world 3 (locomotive)', :body => 'Lorem ipsum...', :topics_ids => [@locomotive_tag._id]
      @blog.posts.create :title => 'Hello world 4 (beach, castle, locomotive)', :body => 'Lorem ipsum...', :topics_ids => [@locomotive_tag._id, @beach_tag._id, @castle_tag._id]
      @blog.posts.create :title => 'Hello world 5 (castle)', :body => 'Lorem ipsum...',  :topics_ids => [@castle_tag._id]
      @blog.posts.create :title => 'Hello world (_none_)', :body => 'Lorem ipsum...'

      klass = @blog.klass_with_custom_fields(:posts)
      @groups = klass.group_by_tag(:topics)
    end
    
    it 'is an non empty array' do
      @groups.class.should == Array
      @groups.size.should == 6
    end

    it 'is an array of hashes composed of a name' do
      @groups.map { |g| g[:name].to_s }.should == ["beach", "castle", "lego", "locomotive", "sun", ""]
    end

     it 'is an array of hashes composed of a list of documents' do
      @groups[0][:entries].size.should == 2
      @groups[1][:entries].size.should == 3
      @groups[2][:entries].size.should == 1
      @groups[3][:entries].size.should == 2
      @groups[4][:entries].size.should == 1
      @groups[5][:entries].size.should == 1
    end

    it 'can be accessed from the parent document' do
      blog = Blog.find(@blog._id)
      blog.posts.group_by_tag(:topics).class.should == Array
    end
    
  end




  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Topics', :type => 'tag_set'
     
      Mongoid::Fields::I18n.locale = :en
      @sun_tag          = field.tags_used.build :name => 'sun' 
      @beach_tag        = field.tags_used.build :name => 'beach'
      @lego_tag         = field.tags_used.build :name => 'lego'
      @locomotive_tag   = field.tags_used.build :name => 'locomotive'
      @castle_tag       = field.tags_used.build :name => 'castle'
     
=begin
      field = blog.posts_custom_fields.build :label => 'Author', :type => 'select', :localized => true

      @option_1 = field.select_options.build :name => 'Mister Foo'
      @option_2 = field.select_options.build :name => 'Mister Bar'

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Monsieur Foo'
      @option_2.name = 'Monsieur Bar'

      Mongoid::Fields::I18n.locale = :en
=end
      blog.save & blog.reload
    end
  end

end