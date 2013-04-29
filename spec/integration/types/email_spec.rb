require 'spec_helper'

describe CustomFields::Types::Email do

  before(:each) do
    @blog = create_blog
  end

  describe 'a new Person' do

    before(:each) do
      @person = @blog.people.build name: 'John Doe'
    end

    it 'sets the email' do
      @person.email = 'john@doe.com'
      @person.attributes['email'].should == 'john@doe.com'
    end

    it 'returns the email' do
      @person.email = 'john@doe.com'
      @person.email.should == 'john@doe.com'
    end
    
    it "validates the email" do
      @person.email = 'junk'
      @person.should_not be_valid
    end

  end

  describe 'an existing person' do

    before(:each) do
      @person = @blog.people.create name: 'John Doe', email: 'john@doe.com'

      @person = Person.find(@person._id)
    end

    it 'returns the email' do
      @person.email.should == 'john@doe.com'
    end

    it 'also returns the email' do
      blog = Blog.find(@blog._id)
      person = blog.people.find(@person._id)
      person.email.should == 'john@doe.com'
    end

    it 'sets a new email' do
      @person.email = 'jane@doe.com'
      @person.save
      @person = Person.find(@person._id)
      @person.email.should == 'jane@doe.com'
    end

  end

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.people_custom_fields.build label: 'email', type: 'email'
      blog.save & blog.reload
    end
  end
end
