require 'spec_helper'

describe CustomFields::Types::String do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it 'sets a value' do
    @post.author = 'John Doe'
    @post.author.should == 'John Doe'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.author = value
        @post.valid?.should be_false
        @post.errors[:author].should_not be_blank
      end
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Author', :type => 'string', :required => true
      field.valid?
    end
  end

end