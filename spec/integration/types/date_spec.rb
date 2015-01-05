describe CustomFields::Types::Date do

  before(:each) do
    @blog = create_blog
    @date = Date.parse '2007-06-29'
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the posted_at date' do
      @post.posted_at = '2007-06-29'

      expect(@post.attributes['posted_at']).to eq @date
    end

    it 'returns the posted_at date' do
      @post.posted_at = '2007-06-29'

      expect(@post.posted_at).to eq @date
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', posted_at: @date
      @post = Post.find @post._id
    end

    it 'does not modify the other Post class' do
      post = Post.new

      expect(post.respond_to?(:posted_at)).to eq false
    end

    it 'returns the posted_at date' do
      expect(@post.posted_at).to eq @date
    end

    it 'sets a new posted_at date' do
      @post.posted_at = '2009-09-10'

      @post.save!

      @post = Post.find @post._id

      expect(@post.posted_at).to eq Date.parse '2009-09-10'
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', visible_at: @date

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.visible_at).to eq @date
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.visible_at).to eq @date

      @post.visible_at = '2009-09-10'

      @post.save

      @post = Post.find @post._id

      expect(@post.visible_at).to eq Date.parse '2009-09-10'

      Mongoid::Fields::I18n.locale = :en

      expect(@post.visible_at).to eq @date
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'posted_at',  type: 'date'
      blog.posts_custom_fields.build label: 'visible_at', type: 'date', localized: true

      blog.save & blog.reload
    end
  end

end