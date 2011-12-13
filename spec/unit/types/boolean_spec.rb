require 'spec_helper'

describe CustomFields::Types::Date do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  context '#true' do

    it 'sets value from an integer' do
      @post.visible = 1
      @post.visible.should == true
    end

    it 'sets value from a string' do
      @post.visible = '1'
      @post.visible.should == true

      @post.visible = 'true'
      @post.visible.should == true
    end

  end

  context '#false' do

    it 'sets value from an integer' do
      @post.visible = 0
      @post.visible.should == false
    end

    it 'sets value from a string' do
      @post.visible = '0'
      @post.visible.should == false

      @post.visible = 'false'
      @post.visible.should == false
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Visible', :type => 'boolean'
      field.valid?
    end
  end

end