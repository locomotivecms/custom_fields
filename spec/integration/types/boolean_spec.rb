# frozen_string_literal: true

describe CustomFields::Types::Boolean do
  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do
    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the visible flag' do
      @post.visible = 'true'

      expect(@post.attributes['visible']).to eq true
    end

    it 'returns the visible flag' do
      @post.visible = 'true'

      expect(@post.visible).to eq true
    end
  end

  context 'an existing post' do
    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', visible: true
      @post = Post.find @post._id
    end

    it 'returns the visible flag' do
      expect(@post.visible).to eq true
    end

    it 'toggles the visible flag' do
      @post.visible = false
      @post.save
      @post = Post.find(@post._id)

      expect(@post.visible).to eq false
    end
  end

  describe '#localize' do
    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', published: true
      @post = Post.find(@post._id)
    end

    it 'serializes / deserializes' do
      expect(@post.published).to be true
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.published).to be true

      @post.published = false
      @post.save
      @post = Post.find(@post._id)

      expect(@post.published).to be false

      Mongoid::Fields::I18n.locale = :en

      expect(@post.published).to be true
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Visible',   type: 'boolean'
      blog.posts_custom_fields.build label: 'Published', type: 'boolean', localized: true

      blog.save & blog.reload
    end
  end
end
