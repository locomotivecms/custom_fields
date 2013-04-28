#encoding: utf-8
require 'spec_helper'

describe CustomFields::Types::Money do

  require 'money'

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @money_string = 'EUR 5,95'
    @money = Money.parse( @money_string )
  end

  it 'is not considered as a relationship field type' do
    @blog.posts_custom_fields.first.is_relationship?.should be_false
  end

  it "returns the currency symbol if allow_currency_from_symbol" do
    @post.donation = "10"
    @post.formatted_donation.should == '€10'
  end

  it "accepts another currency if allow_currency_from_symbol" do
    @post.donation = "5.95 USD"
    @post.formatted_donation.should == "$5.95"
  end

  it "returns no currency symbol unless allow_currency_from_symbol" do
    @post.donation2 = '10'
    @post.formatted_donation2.should == '10'
  end


  describe 'validation' do
    context 'when field required' do
      [nil,''].each do |value|
        it "should not be valid if the value is #{value.inspect}" do
          @post.donation = value
          @post.valid?.should be_false
          @post.errors[:donation].should_not be_blank
        end
      end
    end
  end



  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Amount Donation', type: 'money', name: 'donation', required: true
      field2 = blog.posts_custom_fields.build label: 'Amount Donation2', type: 'money', name: 'donation2'
      field.default_currency = 'EUR'
      field.allow_currency_from_symbol = true
      field2.default_currency = 'AUD'
      field2.allow_currency_from_symbol = false
    end
  end

end
