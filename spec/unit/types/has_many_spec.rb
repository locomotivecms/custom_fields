require 'spec_helper'

describe CustomFields::Types::HasMany do

  before(:each) do
    @blog     = build_blog
    @post_1   = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    @post_2   = @blog.posts.build :title => 'Keep writing', :body => 'Lorem ipsum...'
    @author   = @blog.people.build :name => 'John Doe'
  end

  it 'is considered as a relationship field type' do
    @blog.posts_custom_fields.last.is_relationship?.should be_true
  end

  it 'sets a value' do
    @author.posts = [@post_1, @post_2]
    @author.posts.map(&:title).should == ['Hello world', 'Keep writing']
  end

  it 'includes a scope named ordered' do
    @author.posts.respond_to?(:ordered).should be_true
    @author.posts.ordered.send(:options)[:sort].should == {"position_in_author" => 1}
  end

  describe 'validation' do

    [nil, []].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @author.posts = value
        @author.valid?.should be_false
        @author.errors[:posts].should_not be_blank
      end
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build  :label => 'Author', :type => 'belongs_to', :class_name => 'Person', :required => true
      field.valid?
      field = blog.people_custom_fields.build :label => 'Posts', :type => 'has_many', :class_name => "Post#{blog._id}", :inverse_of => 'author', :required => true
      field.valid?
    end
  end

end
