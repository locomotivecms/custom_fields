require 'spec_helper'

describe CustomFields::Types::DateTime do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @datetime = DateTime.parse("2010-06-29 11:30:40 -0400")
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it 'sets value (in French format) from a string' do
    I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S')
    @post.posted_at = '29/06/2010 11:30:40 -0400'
    @post.formatted_posted_at.should == '29/06/2010 11:30:40'
    @post.posted_at.should == @datetime
  end

  it 'sets value (in French format) from the formatted_<datetime> accessor' do
    I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S %z')
    @post.formatted_posted_at = '29/06/2010 11:30:40 -0400'
    @post.posted_at.should == @datetime
  end

  it 'sets value from the standard format (YYYY/MM/DD)' do
    I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S %z')
    @post.formatted_posted_at = '2010/06/29 11:30:40 -0400'
    @post.posted_at.should == @datetime
  end

  it 'sets value from a ambiguous datetime format' do
    I18n.stubs(:t).returns('%m/%d/%Y %H:%M:%S')
    @post.formatted_posted_at = '01/04/2013 11:30:40'
    @post.posted_at.should == DateTime.parse('2013-01-04 11:30:40')
  end

  it 'sets nil from an invalid string' do
    I18n.stubs(:t).returns('%d/%m/%Y')
    @post.formatted_posted_at = '1234'
    @post.posted_at.should be_nil
  end

  it 'sets nil value' do
    @post.posted_at = nil
    @post.posted_at.should be_nil
  end

  it 'sets empty value' do
    @post.posted_at = ''
    @post.posted_at.should be_nil
  end

  context '#localize' do

    before(:each) do
      field = @blog.posts_custom_fields.build label: 'Visible at', type: 'datetime', localized: true
      field.valid?
      @blog.bump_custom_fields_version(:posts)
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build visible_at: @datetime
      post.visible_at.should == @datetime
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build visible_at: @datetime
      Mongoid::Fields::I18n.locale = :fr
      post.visible_at = '16/09/2010 11:30:40'
      post.visible_at_translations['fr'].utc.should == DateTime.parse('2010/09/16 11:30:40 -0400').utc
    end

  end


  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      @post.class.datetime_attribute_get(@post, 'posted_at').should == {}
    end

    it 'returns the value' do
      @post.posted_at = DateTime.parse("2010-06-29 11:30:40 -0400")
      @post.class.datetime_attribute_get(@post, 'posted_at').should == {
        'posted_at'           => DateTime.parse("2010-06-29 11:30:40 -0400").strftime(I18n.t('time.formats.default')),
        'formatted_posted_at' => DateTime.parse("2010-06-29 11:30:40 -0400").strftime(I18n.t('time.formats.default'))
      }
    end

    it 'sets a nil value' do
      @post.class.datetime_attribute_set(@post, 'posted_at', {}).should be_nil
    end

    it 'sets a value' do
      @post.class.datetime_attribute_set(@post, 'posted_at', { 'posted_at' => '2010-06-28 11:30:40 UTC' })
      @post.posted_at.should == DateTime.parse('2010-06-28 11:30:40 UTC')

      @post.class.datetime_attribute_set(@post, 'posted_at', { 'formatted_posted_at' => "2010-06-29 11:30:40 UTC" })
      @post.posted_at.should == DateTime.parse("2010-06-29 11:30:40 UTC")
    end

  end

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Posted at', type: 'datetime'
      field.valid?
    end
  end

end
