describe CustomFields::Types::String do

  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the author' do
      @post.author = 'John Doe'

      expect(@post.attributes['author']).to eq 'John Doe'
    end

    it 'returns the author' do
      @post.author = 'John Doe'

      expect(@post.author).to eq 'John Doe'
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', author: 'John Doe'

      @post = Post.find @post._id
    end

    it 'returns the author' do
      expect(@post.author).to eq 'John Doe'
    end

    it 'also returns the author' do
      blog = Blog.find @blog._id

      post = blog.posts.find @post._id

      expect(post.author).to eq 'John Doe'
    end

    it 'sets a new author' do
      @post.author = 'Jane Doe'

      @post.save

      @post = Post.find @post._id

      expect(@post.author).to eq 'Jane Doe'
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'author', type: 'string'

      blog.save & blog.reload
    end
  end

end