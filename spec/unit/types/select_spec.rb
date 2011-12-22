require 'spec_helper'

describe CustomFields::Types::Select do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'stores the list of categories' do
    @field.respond_to?(:select_options).should be_true
  end

  it 'includes the categories in the as_json method' do
    @field.as_json['select_options'].should_not be_empty
  end

  it 'adds the categories when calling to_recipe' do
    @field.to_recipe['select_options'].should_not be_empty
  end

  it 'sets a value' do
    @post.main_category = 'Test'
    @post.main_category.should == 'Test'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.main_category = value
        @post.valid?.should be_false
        @post.errors[:main_category].should_not be_blank
      end
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      @field = blog.posts_custom_fields.build :label => 'Main category', :type => 'select', :required => true
      @field.select_options.build :name => 'Test'
      @field.valid?
    end
  end

end