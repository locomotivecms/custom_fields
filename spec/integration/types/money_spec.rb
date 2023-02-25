# frozen_string_literal: true

describe CustomFields::Types::Money do
  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do
    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'returns the formatted donation' do
      @post.donation = '10'

      expect(@post.formatted_donation).to eq '€10'
    end

    it 'accepts another currency' do
      @post.donation = '5.95 USD'

      expect(@post.formatted_donation).to eq '$5.95'
    end
  end

  context 'an existing post' do
    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', donation: '5,95'

      @post = Post.find @post._id
    end

    it 'returns the donation' do
      expect(@post.formatted_donation).to eq '€5,95'
    end

    it 'sets a new donation' do
      @post.donation = '50.95 USD'

      @post.save!

      @post = Post.find @post._id

      expect(@post.formatted_donation).to eq '$50.95'
    end

    it 'does not modify the other Post objects' do
      post = Post.new

      expect(post.respond_to?(:donation)).to eq false
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Amount Donation', type: 'money', name: 'donation'
      field.default_currency = 'EUR'
      field.allow_currency_from_symbol = true

      blog.save & blog.reload
    end
  end
end
