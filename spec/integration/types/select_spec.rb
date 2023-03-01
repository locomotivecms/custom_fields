# frozen_string_literal: true

describe CustomFields::Types::Select do
  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do
    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the category from an existing name' do
      @post.main_category = 'Development'

      expect(@post.attributes['main_category_id']).to eq @development_cat._id
    end

    it 'sets the category from an id' do
      @post.main_category = @development_cat._id

      expect(@post.attributes['main_category_id']).to eq @development_cat._id
    end

    it 'returns the name of the category' do
      @post.main_category = @design_cat._id

      expect(@post.main_category).to eq 'Design'
    end
  end

  context 'an existing post' do
    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', main_category: @marketing_cat._id

      @post = Post.find @post._id
    end

    it 'returns the main category' do
      expect(@post.main_category).to eq 'Marketing'
    end

    it 'assigns a new main category' do
      @post.main_category = @design_cat._id

      @post.save

      @post = Post.find @post._id

      expect(@post.main_category).to eq 'Design'
    end

    it 'create a new category and assigns it' do
      category = @blog.posts_custom_fields.first.select_options.build name: 'Sales'

      @blog.save

      @post = Post.find @post._id

      @post.main_category = 'Sales'

      expect(@post.attributes['main_category_id']).to eq category._id

      @post.save

      @post = Post.find @post._id

      expect(@post.main_category).to eq 'Sales'
    end
  end

  describe 'group_by' do
    before(:each) do
      @blog.posts.create title: 'Hello world 1(Development)',  body: 'Lorem ipsum...',
                         main_category: @development_cat._id
      @blog.posts.create title: 'Hello world (Design)',        body: 'Lorem ipsum...', main_category: @design_cat._id
      @blog.posts.create title: 'Hello world 2 (Development)', body: 'Lorem ipsum...',
                         main_category: @development_cat._id
      @blog.posts.create title: 'Hello world 3 (Development)', body: 'Lorem ipsum...',
                         main_category: @development_cat._id
      @blog.posts.create title: 'Hello world (Unknown)',        body: 'Lorem ipsum...', main_category: BSON::ObjectId.new
      @blog.posts.create title: 'Hello world (Unknown) 2',      body: 'Lorem ipsum...', main_category: BSON::ObjectId.new

      klass = @blog.klass_with_custom_fields :posts
      @groups = klass.group_by_select_option :main_category
    end

    it 'is an non empty array' do
      expect(@groups.class).to be Array

      expect(@groups.size).to eq 4
    end

    it 'is an array of hashes composed of a name' do
      expect(@groups.map { |g| g[:name].to_s }).to eq ['Design', 'Development', 'Marketing', '']
    end

    it 'is an array of hashes composed of a list of documents' do
      expect(@groups[0][:entries].size).to be 1
      expect(@groups[1][:entries].size).to be 3
      expect(@groups[2][:entries].size).to be 0
      expect(@groups[3][:entries].size).to be 2
    end

    it 'can be accessed from the parent document' do
      blog = Blog.find @blog._id

      expect(blog.posts.group_by_select_option(:main_category).class).to be Array
    end
  end

  describe '#localize' do
    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', author: 'Mister Foo'

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.author).to eq 'Mister Foo'
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.author).to eq 'Monsieur Foo'

      @post.author = 'Monsieur Bar'

      @post.save

      @post = Post.find @post._id

      expect(@post.author).to eq 'Monsieur Bar'

      Mongoid::Fields::I18n.locale = :en

      expect(@post.author).to eq 'Mister Foo'
    end

    it 'displays all the categories' do
      expect(@post.class.author_options.first['name']).to eq 'Mister Foo'

      Mongoid::Fields::I18n.locale = :fr

      expect(@post.class.author_options.first['name']).to eq 'Monsieur Foo'

      Mongoid::Fields::I18n.locale = :en

      expect(@post.class.author_options.first['name']).to eq 'Mister Foo'

      # special case: no fallback found
      Mongoid::Fields::I18n.stubs(:fallbacks?).returns true
      Mongoid::Fields::I18n.stubs(:fallbacks).returns {}

      Mongoid::Fields::I18n.with_locale(:en) do
        expect(@post.class.author_options.first['name']).to eq 'Mister Foo'
      end
    end
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      Mongoid::Fields::I18n.locale = :en

      # === Categories ===

      field = blog.posts_custom_fields.build label: 'Main category', type: 'select'

      @design_cat       = field.select_options.build name: 'Design'
      @development_cat  = field.select_options.build name: 'Development'
      @marketing_cat    = field.select_options.build name: 'Marketing'

      # === Authors ===

      field = blog.posts_custom_fields.build label: 'Author', type: 'select', localized: true

      @option_1 = field.select_options.build name: 'Mister Foo'
      @option_2 = field.select_options.build name: 'Mister Bar'

      # === Localizations ===

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Monsieur Foo'
      @option_2.name = 'Monsieur Bar'

      Mongoid::Fields::I18n.locale = :en

      blog.save & blog.reload
    end
  end
end
