require 'spec_helper'

describe CustomFields::Types::Date do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
    @date = Date.parse('2010-06-29')
  end

  it 'sets value (in French format) from a string' do
    I18n.stubs(:t).returns('%d/%m/%Y')
    @post.posted_at = '29/06/2010'
    @post.formatted_posted_at.should == '29/06/2010'
    @post.posted_at.should == @date
  end

  it 'sets value (in French format) from the formatted_<date> accessor' do
    I18n.stubs(:t).returns('%d/%m/%Y')
    @post.formatted_posted_at = '29/06/2010'
    @post.posted_at.should == @date
  end

  it 'sets nil value' do
    @post.posted_at = nil
    @post.posted_at.should be_nil
  end

  it 'sets empty value' do
    @post.posted_at = ''
    @post.posted_at.should be_nil
  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Posted at', :type => 'date'
      field.valid?
    end
  end

end