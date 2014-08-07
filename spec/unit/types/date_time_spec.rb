require 'spec_helper'

describe CustomFields::Types::DateTime do

  before(:each) do
    Time.zone = 'Paris'
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @datetime = Time.zone.parse('2010-06-29 11:30:40')
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be false
  end

  context 'French format' do

    before(:each) do
      I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S')
    end

    it 'sets value (in French format) from a string' do
      @post.posted_at = '29/06/2010 11:30:40'
      @post.formatted_posted_at.should == '29/06/2010 11:30:40'
      @post.posted_at.should == @datetime
    end

    it 'sets value (in French format) from the formatted_<date_time> accessor' do
      @post.formatted_posted_at = '29/06/2010 11:30:40'
      @post.posted_at.should == @datetime
    end

  end

  it 'sets value from the standard format (YYYY/MM/DD)' do
    I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S')
    @post.formatted_posted_at = '2010/06/29 11:30:40'
    @post.posted_at.should == @datetime
  end

  it 'sets value from a ambiguous DateTime format' do
    I18n.stubs(:t).returns('%m/%d/%Y %H:%M:%S')
    @post.formatted_posted_at = '01/04/2013 11:30:40'
    @post.posted_at.should == Time.zone.parse('2013-01-04 11:30:40')
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
      field = @blog.posts_custom_fields.build label: 'Visible at', type: 'date_time', localized: true
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
      post.visible_at = '29/06/2010 11:30:40'
      post.visible_at_translations['fr'].should == @datetime
    end

  end

  describe 'getter and setter' do

    before(:each) do
      I18n.stubs(:t).returns('%d/%m/%Y %H:%M:%S')
    end

    it 'returns an empty hash if no value has been set' do
      @post.class.date_time_attribute_get(@post, 'posted_at').should == {}
    end

    it 'returns the value' do
      @post.posted_at = @datetime
      @post.class.date_time_attribute_get(@post, 'posted_at').should == {
        'posted_at'             => '29/06/2010 11:30:40',
        'formatted_posted_at'   => '29/06/2010 11:30:40'
      }
    end

    it 'sets a nil value' do
      @post.class.date_time_attribute_set(@post, 'posted_at', {}).should be_nil
    end

    it 'sets a value' do
      @post.class.date_time_attribute_set(@post, 'posted_at', { 'posted_at' => '2010-06-28 11:30:40' })
      @post.posted_at.should == Time.zone.parse('2010-06-28 11:30:40')

      @post.class.date_time_attribute_set(@post, 'posted_at', { 'formatted_posted_at' => '2010-06-29 11:30:40' })
      @post.posted_at.should == Time.zone.parse('2010-06-29 11:30:40')
    end

  end

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Posted at', type: 'date_time'
      field.valid?
    end
  end

end
