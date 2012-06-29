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
      @post.save
      @post.topic_ids.should include(@locomotive_tag._id)
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
      @post.topics.should == []
    end

    it 'can be set via an array' do
      @post.topics = ['hello', ' world', 'carpe diem']
      @post.topics.should include("hello", "carpe diem", "world")
    end

    it 'returns the name of the tag' do
      @post.topics = ""
      @post.topic_ids.append(@locomotive_tag._id)
      @post.save
      @post.topics.should include('locomotive')
    end

    it 'ignores the case of tags' do
      @post.topics = 'LocomOtive'
      @post.topic_ids.should include(@locomotive_tag._id)
    end
    
    it 'can have a tag field that is not named topics' do
      @post.stuff = 'hello, world'
      @post.stuff.length.should ==  2
    end

    it 'ignores empty tags' do
      @post.topics = 'this,is,,not,blank'
      @post.topic_ids.length.should == 4
    end

  end

  
  
  describe 'an existing post' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :raw_topic_ids => [@beach_tag._id, @castle_tag._id]
      @post = Post.find(@post._id)
    end

    it 'returns the tags' do
      @post.topics.should include("beach", "castle")
    end

    it 'assigns a new tag' do
      @post.topic_ids.append(@lego_tag._id)
      @post.save
      @post = Post.find(@post._id)
      @post.topics.should include("lego")
    end

    it 'create a new tag and assigns it' do
      tag = @blog.posts_custom_fields.detect {|f| f[:label] == "Topics"}.tag_class.create :name => 'new_tag'
      @blog.save
      @post = Post.find(@post._id)
      @post.topics = 'new_tag'
      @post.attributes['raw_topic_ids'].should include(tag._id)
      @post.save
      @post = Post.find(@post._id)
      @post.topics.should include( 'new_tag')
    end

  end

  describe 'an saved post' do

    before(:each) do
      post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...'
      post.topics = "topic1, topic2"
      post.save
      @post = Post.find(post._id)
    end

    it 'has the correct tags' do
      @post.topics.should include("topic2", "topic1")
      @post.topics.length.should == 2
      @post.class.topics_available_tags.find_all{|x| x['name'] == 'topic1' || x['name'] == 'topic2'}.length.should == 2 
      
    end

  end




 describe 'group_by' do

    before(:each) do
      p1 = @blog.posts.create :title => 'Hello world 1(sun, beach)', :body => 'Lorem ipsum...'
      p2 = @blog.posts.create :title => 'Hello world 2(castle, lego)', :body => 'Lorem ipsum...' 
      p3 = @blog.posts.create :title => 'Hello world 3 (locomotive)', :body => 'Lorem ipsum...'
      p4 = @blog.posts.create :title => 'Hello world 4 (beach, castle, locomotive)', :body => 'Lorem ipsum...'
      p5 = @blog.posts.create :title => 'Hello world 5 (castle)', :body => 'Lorem ipsum...'
      p6 = @blog.posts.create :title => 'Hello world (_none_)', :body => 'Lorem ipsum...'
      
      p1.raw_topics.concat([@sun_tag, @beach_tag])
      p1.save
      
      p2.raw_topics.concat([@castle_tag, @lego_tag])
      p2.save
      
      p3.raw_topics << @locomotive_tag
      p3.save
      
      p4.raw_topics.concat([@locomotive_tag, @beach_tag, @castle_tag])
      p4.save
      
      p5.raw_topics.concat([@castle_tag])
      p5.save
      
      
      
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
      blog.posts_custom_fields.build :label => 'stuff', :type => 'tag_set'
      field = blog.posts_custom_fields.build :label => 'Topics', :type => 'tag_set'
     
      Mongoid::Fields::I18n.locale = :en
      
      @sun_tag          = field.tag_class.create(name: 'sun') 
      @beach_tag        = field.tag_class.create(name: 'beach')
      @lego_tag         = field.tag_class.create(name: 'lego')
      @locomotive_tag   = field.tag_class.create(name: 'locomotive' )
      @castle_tag       = field.tag_class.create(name: 'castle')

      blog.save & blog.reload
    end
  end

end