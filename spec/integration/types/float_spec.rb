# frozen_string_literal: true

describe CustomFields::Types::Float do
  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do
    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the age' do
      @post.age = 10.42

      expect(@post.attributes['age']).to eq 10.42
    end

    it 'returns the age' do
      @post.age = 3.1415

      expect(@post.age).to eq 3.1415
    end
  end

  context 'an existing post' do
    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', age: 12.42

      @post = Post.find @post._id
    end

    it 'returns the age' do
      expect(@post.age).to eq 12.42
    end

    it 'also returns the age' do
      blog = Blog.find @blog._id

      post = blog.posts.find @post._id

      expect(@post.age).to eq 12.42
    end

    it 'sets a new age' do
      @post.age = 13.333

      @post.save

      @post = Post.find @post._id

      expect(@post.age).to eq 13.333
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'age', type: 'float'

      blog.save & blog.reload
    end
  end
end
