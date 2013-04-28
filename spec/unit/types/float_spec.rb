require 'spec_helper'

describe CustomFields::Types::Float do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it 'sets a value' do
    @post.count = 1.42
    @post.count.should == 1.42
  end

  describe 'validation' do

    [nil, '', true, 'John Doe'].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.count = value
        @post.valid?.should be_false
        @post.errors[:count].should_not be_blank
      end
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      @post.class.float_attribute_get(@post, 'count').should == {}
    end

    it 'returns the value' do
      @post.count = 42.12345
      @post.class.float_attribute_get(@post, 'count').should == { 'count' => 42.12345 }
    end

    it 'sets a nil value' do
      @post.class.float_attribute_set(@post, 'count', {}).should be_nil
    end

    it 'sets a value' do
      @post.class.float_attribute_set(@post, 'count', { 'count' => 42.12345 })
      @post.count.should == 42.12345
    end

  end

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Count', type: 'float', required: true
      field.valid?
    end
  end

end
