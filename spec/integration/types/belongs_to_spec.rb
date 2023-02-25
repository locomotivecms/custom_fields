# frozen_string_literal: true

describe CustomFields::Types::BelongsTo do
  before(:each) do
    @blog           = create_blog
    @author         = @blog.people.create name: 'John Doe'
    @another_author = @blog.people.create name: 'Jane Doe'
  end

  context 'a new post' do
    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the author' do
      save_post @post, @author

      expect(@post.author.name).to eq 'John Doe'
    end

    it 'increments the position' do
      save_post @post, @author

      expect(@post.position_in_author).to eq 1
    end
  end

  context 'an existing post' do
    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', author: @author
      @post = Post.find @post._id
    end

    it 'returns the name of the author' do
      expect(@post.author.name).to eq 'John Doe'
    end

    it 'sets a new author' do
      save_post @post, @another_author

      @post = Post.find @post._id

      expect(@post.author.name).to eq 'Jane Doe'
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Author', type: 'belongs_to', class_name: 'Person'

      blog.save & blog.reload
    end
  end

  def save_post(post, author)
    post.author = author

    post.save
  end
end
