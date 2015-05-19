describe CustomFields::Types::DateTime do

  before(:each) do
    Time.zone = 'Paris'

    Post.any_instance.stubs(:_formatted_date_time_format).returns('%d/%m/%Y %H:%M:%S')

    @blog = create_blog

    @datetime = Time.zone.parse '2007-06-29 11:30:40'
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the posted_at datetime' do
      @post.posted_at = '2007-06-29 11:30:40'

      expect(@post.attributes['posted_at']).to eq @datetime
    end

    it 'returns the posted_at datetime' do
      @post.posted_at = '2007-06-29 11:30:40'

      expect(@post.posted_at).to eq @datetime
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', posted_at: @datetime
      @post = Post.find @post._id
    end

    it 'does not modify the other Post class' do
      post = Post.new

      expect(post.respond_to?(:posted_at)).to eq false
    end

    it 'returns the posted_at date_time' do
      expect(@post.posted_at).to eq @datetime
    end

    it 'sets a new posted_at date_time' do
      @post.posted_at = '2009-09-10 11:30:40'

      @post.save!

      @post = Post.find @post._id

      expect(@post.posted_at).to eq Time.zone.parse '2009-09-10 11:30:40'
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', visible_at: @datetime

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.visible_at).to eq @datetime
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.visible_at).to eq @datetime

      @post.visible_at = '2009-09-10 11:30:40'

      @post.save

      @post = Post.find @post._id

      expect(@post.visible_at).to eq Time.zone.parse '2009-09-10 11:30:40'

      Mongoid::Fields::I18n.locale = :en

      expect(@post.visible_at).to eq @datetime
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'posted_at',  type: 'date_time'
      blog.posts_custom_fields.build label: 'visible_at', type: 'date_time', localized: true

      blog.save! & blog.reload
    end
  end

end