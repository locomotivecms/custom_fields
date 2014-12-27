describe CustomFields::Types::Tags do

  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the tags' do
      @post.tags = %w[one two three]

      expect(@post.attributes['tags']).to eq %w[one two three]
    end

    it 'returns the tags' do
      @post.tags = %w[one two three]

      expect(@post.tags).to eq %w[one two three]
    end

    it 'sets the tags from a string' do
      @post.tags = 'one, two, three'

      expect(@post.tags).to eq %w[one two three]

      @post.tags = 'one,two, three ,four  ,  five'

      expect(@post.tags).to eq %w[one two three four five]
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', tags: %w[one two]

      @post = Post.find @post._id
    end

    it 'returns the tags' do
      expect(@post.tags).to eq %w[one two]
    end

    it 'sets a new posted_at date' do
      @post.tags = 'one, two, three'

      @post.save!

      @post = Post.find @post._id

      expect(@post.tags).to eq %w[one two three]
    end

    it 'does not modify the other Post class' do
      post = Post.new

      expect(post.respond_to?(:tags)).to eq false
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', localized_tags: %w[hello world]

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.localized_tags).to eq %w[hello world]
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.localized_tags).to eq %w[hello world]

      @post.localized_tags = %w[bonjour]

      @post.save

      @post = Post.find @post._id

      expect(@post.localized_tags).to eq %w[bonjour]

      Mongoid::Fields::I18n.locale = :en

      expect(@post.localized_tags).to eq %w[hello world]
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Tags', type: 'tags'
      blog.posts_custom_fields.build label: 'Localized tags',  type: 'tags', localized: true

      blog.save & blog.reload
    end
  end

end