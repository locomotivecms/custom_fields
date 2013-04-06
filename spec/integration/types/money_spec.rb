# -*- coding: utf-8 -*-
require 'spec_helper'

describe CustomFields::Types::Money do

  before(:each) do
    @blog = create_blog
    @money_string = 'EUR 5,95'
    @money = Money.parse( @money_string )
  end

  describe 'a new post with donation' do

    before(:each) do
      @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
      @post.formatted_donation = @money_string
    end

    it 'sets the donation' do
      @post.donation.should == @money
    end

    it 'returns the formatted_donation' do
      @post.formatted_donation.should == @money_string.gsub(/EUR /,'€')
    end

  end

  describe 'an existing post with donation' do

    before(:each) do
      @post = @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...', :donation => @money
      @post = Post.find(@post._id)
    end

    it 'does not modify the other Post class' do
      post = Post.new
      post.respond_to?(:donation).should be_false
    end

    it 'returns the donated money' do
      @post.donation.should == @money
    end

#    it 'sets a new posted_at money' do
#      @post.posted_at = '2009-09-10'
#      @post.save!
#      @post = Post.find(@post._id)
#      @post.posted_at.should == Money.parse('2009-09-10')
#    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build :label => 'Amount Donation', :type => 'money', :name => 'donation'
      field.default_currency = 'EUR'
      field.allow_currency_from_symbol = true
      blog.save & blog.reload
    end
  end
end
