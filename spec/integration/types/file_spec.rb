describe CustomFields::Types::File do

  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...', banner: FixturedFile.open('doc.txt')
    end

    it 'does not have 2 image fields' do
      @post.image = FixturedFile.open 'doc.txt'
      @post.save
      expect(@post.attributes.key?('source') && @post.attributes.key?(:source)).to eq false
    end

    it 'attaches the file' do
      @post.image = FixturedFile.open('doc.txt')
      @post.save
      expect(@post.image.url).to  match(/\/uploads\/doc\.txt$/)
    end

    it 'stores the size of the file' do
      @post.image = FixturedFile.open('doc.txt')
      @post.save
      expect(@post.image_size).to eq('default' => 13)
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', image: FixturedFile.open('doc.txt'), banner: FixturedFile.open('doc.txt')
      @post = Post.find @post._id
    end

    it 'returns the url to the file' do
      expect(@post.image.url).to match(/\/uploads\/doc\.txt$/)
    end

    it 'attaches a new file' do
      @post.image = FixturedFile.open 'another_doc.txt'
      @post.save
      @post = Post.find @post._id
      expect(@post.image.url).to match(/\/uploads\/another_doc\.txt$/)
      expect(@post.image_size).to eq('default' => 14)
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en
      @post = @blog.posts.create! title: 'Hello world', body: 'Lorem ipsum...', banner: FixturedFile.open('doc.txt')
      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.banner.url).to match(/\/uploads\/doc_en\.txt$/)
    end

    it 'serializes / deserializes with a different locale' do
      expect(@post.banner_size).to eq('en' => 13)
      Mongoid::Fields::I18n.locale = :fr
      expect(@post.banner.url).to match(/\/uploads\/doc_en\.txt$/)
      @post.banner = FixturedFile.open 'another_doc.txt'
      @post.save
      @post = Post.find @post._id
      expect(@post.banner.url).to match(/\/uploads\/another_doc_fr\.txt$/)
      expect(@post.banner_size).to eq('en' => 13, 'fr' => 14)
    end

    it 'validates the presence of a file not filled in a locale' do
      Mongoid::Fields::I18n.locale = :de
      @post = Post.find @post._id
      expect(@post.valid?).to eq true
      expect(@post.save).to eq true
      expect(@post.banner.url).to match(/\/uploads\/doc_en\.txt$/)
    end

    it 'attaches a new file' do
      expect(@post.banner.url).to match(/\/uploads\/doc_en\.txt$/)
      Mongoid::Fields::I18n.locale = :fr
      post = Post.find(@post._id)
      post.attributes = { title: 'Bonjour le monde', banner: FixturedFile.open('another_doc.txt') }
      post.save
      expect(post.banner.url).to match(/\/uploads\/another_doc_fr\.txt$/)
      Mongoid::Fields::I18n.locale = :en
      post = Post.find @post._id
      expect(post.banner_size).to eq('en' => 13, 'fr' => 14)
      expect(post.banner?).to eq(true)
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'image',   type: 'file'
      blog.posts_custom_fields.build label: 'banner',  type: 'file', localized: true, required: true
      blog.save & blog.reload
    end
  end
end
