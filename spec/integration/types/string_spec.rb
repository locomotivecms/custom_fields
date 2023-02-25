# frozen_string_literal: true

describe CustomFields::Types::String do
  let(:blog) { create_blog }

  context 'a new post' do
    let(:post) { blog.posts.build(title: 'Hello world', body: 'Lorem ipsum...') }

    it 'sets the author' do
      post.author = 'John Doe'

      expect(post.attributes['author']).to eq 'John Doe'
    end

    it 'returns the author' do
      post.author = 'John Doe'

      expect(post.author).to eq 'John Doe'
    end
  end

  context 'an existing post' do
    let(:post) { create_post(title: 'Hello world', body: 'Lorem ipsum...', author: 'John Doe') }

    it 'returns the author' do
      expect(post.author).to eq 'John Doe'
    end

    it 'also returns the author' do
      _blog = Blog.find(blog._id)
      _post = _blog.posts.find(post._id)
      expect(_post.author).to eq 'John Doe'
    end

    it 'sets a new author' do
      post.author = 'Jane Doe'
      post.save
      _post = Post.find(post._id)
      expect(_post.author).to eq 'Jane Doe'
    end

    describe 'default value is present' do
      let(:blog) { create_blog('Jane Doe') }
      let(:post) { create_post(title: 'Hello world', body: 'Lorem ipsum...') }

      it 'returns the default author' do
        expect(post.author).to eq 'Jane Doe'
      end

      describe 'unsetting value' do
        let(:post) { create_post(title: 'Hello world', body: 'Lorem ipsum...', author: 'John Doe') }

        it "doesn't set the default author after unsetting it" do
          post.author = nil
          post.save
          _post = Post.find post._id
          expect(_post.author).to eq nil
        end
      end
    end
  end

  protected

  def create_blog(default_value = nil)
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'author', type: 'string', default: default_value
      blog.save! & blog.reload
    end
  end

  def create_post(attributes = {})
    post = blog.posts.create!(attributes)
    Post.find(post._id)
  end
end
