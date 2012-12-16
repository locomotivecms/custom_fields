require 'spec_helper'

describe CustomFields::Types::Select do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
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

  context '#localize' do

    before(:each) do
      field = @blog.posts_custom_fields.build :label => 'Taxonomy', :type => 'select', :localized => true
      Mongoid::Fields::I18n.locale = :en
      @option_1 = field.select_options.build :name => 'Item #1 in English'
      @option_2 = field.select_options.build :name => 'Item #2 in English'
      Mongoid::Fields::I18n.locale = :fr
      @option_1.name = 'Item #1 in French'
      @option_2.name = 'Item #2 in French'
      field.valid?
      Mongoid::Fields::I18n.locale = :en
      @blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build :taxonomy => 'Item #1 in English'
      post.taxonomy.should == 'Item #1 in English'
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build :taxonomy => 'Item #1 in English'
      Mongoid::Fields::I18n.locale = :fr
      post.taxonomy = 'Item #2 in French'
      post.taxonomy_id_translations['fr'].should == @option_2._id
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      @post.class.select_attribute_get(@post, 'main_category').should == {}
    end

    it 'returns the value' do
      @post.main_category = 'Test'
      @post.class.select_attribute_get(@post, 'main_category').should == {
        'main_category'     => 'Test',
        'main_category_id'  => @field.select_options.first._id
      }
    end

    it 'sets a nil value' do
      @post.class.select_attribute_set(@post, 'main_category', {}).should be_nil
    end

    it 'sets a value from a name' do
      @post.class.select_attribute_set(@post, 'main_category', { 'main_category' => 'Test' })
      @post.main_category.should == 'Test'
    end

    it 'sets a value from an id' do
      @post.class.select_attribute_set(@post, 'main_category', { 'main_category' => @field.select_options.first._id })
      @post.main_category.should == 'Test'

      @post.class.select_attribute_set(@post, 'main_category', { 'main_category_id' => @field.select_options.first._id })
      @post.main_category.should == 'Test'
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