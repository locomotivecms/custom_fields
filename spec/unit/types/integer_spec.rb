require 'spec_helper'

describe CustomFields::Types::Integer do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'

  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it 'sets a value' do
    @post.age = 102
    @post.age.should == 102
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.age = value
        @post.valid?.should be_false
        @post.errors[:age].should_not be_blank
      end
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Age', :name => 'age', :type => 'integer', :required => true
      field.valid?
    end
  end

end

