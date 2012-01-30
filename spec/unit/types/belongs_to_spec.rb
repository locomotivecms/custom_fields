require 'spec_helper'

describe CustomFields::Types::BelongsTo do

  before(:each) do
    @blog   = build_blog
    @person = Person.create :name => 'John Doe'
    @post   = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'sets a value' do
    @post.author = @person
    @post.author.name.should == 'John Doe'
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
      field = blog.posts_custom_fields.build :label => 'Author', :type => 'belongs_to', :class_name => 'Person', :required => true
      field.valid?
    end
  end

end