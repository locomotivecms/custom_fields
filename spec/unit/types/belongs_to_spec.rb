require 'spec_helper'

describe CustomFields::Types::BelongsTo do

  before(:each) do
    @blog   = build_blog
    @author = Person.new name: 'John Doe'
    @blog.posts_custom_fields
    @post   = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be true
  end

  it 'has a field storing the position' do
    @post.respond_to?(:position_in_author).should be true
  end

  it 'sets a value' do
    @post.author = @author
    @post.author.name.should == 'John Doe'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.author = value
        @post.valid?.should be false
        @post.errors[:author].should_not be_blank
      end
    end

  end

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Author', type: 'belongs_to', class_name: 'Person', required: true
      field.valid?
    end
  end

end
