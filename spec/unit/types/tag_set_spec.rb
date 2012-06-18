require 'spec_helper'

describe CustomFields::Types::TagSet do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it 'stores the list of categories' do
    @field.respond_to?(:tags_used).should be_true
  end

  it 'includes the tags in the as_json method' do
    @field.as_json['tags_used'].should_not be_empty
  end

  it 'adds the tags when calling to_recipe' do
    @field.to_recipe['tags_used'].should_not be_empty
  end

  it 'sets a value' do
    @post.topics = 'Test'
    @post.topics.should == ['Test']
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.topics = value
        @post.valid?.should be_false
        @post.errors[:topics].should_not be_blank
      end
    end

  end

  context '#localize' do

    before(:each) do
      field = @blog.posts_custom_fields.build :label => 'Taxonomy', :type => 'tag_set', :localized => true
      Mongoid::Fields::I18n.locale = :en
      @option_1 = field.tags_used.build :name => 'Item #1 in English'
      @option_2 = field.tags_used.build :name => 'Item #2 in English'
      Mongoid::Fields::I18n.locale = :fr
      @option_1.name = 'Item #1 in French'
      @option_2.name = 'Item #2 in French'
      field.valid?
      Mongoid::Fields::I18n.locale = :en
      @blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build :taxonomy => 'Item #1 in English'
      post.taxonomy.should == ['Item #1 in English']
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build :taxonomy => 'Item #1 in English'
      Mongoid::Fields::I18n.locale = :fr
      post.taxonomy = 'Item #2 in French'
      post.taxonomy_ids_translations['fr'].should == [@option_2._id]
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      @field = blog.posts_custom_fields.build :label => 'Topics', :type => 'tag_set', :required => true
      @field.tags_used.build :name => 'Test'
      @field.valid?
    end
  end

end