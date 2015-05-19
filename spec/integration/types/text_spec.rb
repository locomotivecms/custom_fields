describe CustomFields::Types::Text do

  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the excerpt' do
      @post.excerpt = 'Well, hello world'

      expect(@post.attributes['excerpt']).to eq 'Well, hello world'
    end

    it 'returns the excerpt' do
      @post.excerpt = 'Well, hello world'

      expect(@post.excerpt).to eq 'Well, hello world'
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', excerpt: 'Well, hello world'

      @post = Post.find @post._id
    end

    it 'returns the excerpt' do
      expect(@post.excerpt).to eq 'Well, hello world'
    end

    it 'sets a new excerpt' do
      @post.excerpt = 'A new one'
      @post.save

      @post = Post.find @post._id

      expect(@post.excerpt).to eq 'A new one'
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', localized_excerpt: 'Well, hello world'

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.localized_excerpt).to eq 'Well, hello world'
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.localized_excerpt).to eq 'Well, hello world'

      @post.localized_excerpt = 'Eh bien, bonjour le monde'

      @post.save

      @post = Post.find @post._id

      expect(@post.localized_excerpt).to eq 'Eh bien, bonjour le monde'

      Mongoid::Fields::I18n.locale = :en

      expect(@post.localized_excerpt).to eq 'Well, hello world'
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Excerpt', type: 'text', text_formatting: 'html'
      blog.posts_custom_fields.build label: 'Localized excerpt', type: 'text', text_formatting: 'html', localized: true

      blog.save & blog.reload
    end
  end

end