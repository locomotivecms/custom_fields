describe CustomFields::Types::MultipleSelect do

  before(:each) do
    @blog = create_blog
  end

  context 'a new post' do

    before(:each) do
      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    end

    it 'sets the category from an existing name' do
      @post.main_category = ['Development']

      expect(@post.attributes['main_category_id']).to eq [@development_cat._id]
    end

    it 'sets the category from an id' do
      @post.main_category = [@development_cat._id]

      expect(@post.attributes['main_category_id']).to eq [@development_cat._id]
    end

    it 'returns the name of the category' do
      @post.main_category = [@design_cat._id]

      expect(@post.main_category).to eq ['Design']
    end

  end

  context 'an existing post' do

    before(:each) do
      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', main_category: [@marketing_cat._id]

      @post = Post.find @post._id
    end

    it 'returns the main category' do
      expect(@post.main_category).to eq ['Marketing']
    end

    it 'assigns a new main category' do
      @post.main_category = [@design_cat._id]

      @post.save

      @post = Post.find @post._id

      expect(@post.main_category).to eq ['Design']
    end

    it 'create a new category and assigns it' do
      category = @blog.posts_custom_fields.first.multiple_select_options.build name: 'Sales'

      @blog.save

      @post = Post.find @post._id

      @post.main_category = ['Sales']

      expect(@post.attributes['main_category_id']).to eq [category._id]

      @post.save

      @post = Post.find @post._id

      expect(@post.main_category).to eq ['Sales']
    end

  end

  describe '#localize' do

    before(:each) do
      Mongoid::Fields::I18n.locale = :en

      @post = @blog.posts.create title: 'Hello world', body: 'Lorem ipsum...', author: ['Mister Foo']

      @post = Post.find @post._id
    end

    it 'serializes / deserializes' do
      expect(@post.author).to eq ['Mister Foo']
    end

    it 'serializes / deserializes with a different locale' do
      Mongoid::Fields::I18n.locale = :fr

      expect(@post.author).to eq ['Monsieur Foo']

      @post.author = ['Monsieur Bar']

      @post.save

      @post = Post.find @post._id

      expect(@post.author).to eq ['Monsieur Bar']

      Mongoid::Fields::I18n.locale = :en

      expect(@post.author).to eq ['Mister Foo']
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

      field = blog.posts_custom_fields.build label: 'Main category', type: 'multiple_select'

      @design_cat       = field.multiple_select_options.build name: 'Design'
      @development_cat  = field.multiple_select_options.build name: 'Development'
      @marketing_cat    = field.multiple_select_options.build name: 'Marketing'

      # === Authors ===

      field = blog.posts_custom_fields.build label: 'Author', type: 'multiple_select', localized: true

      @option_1 = field.multiple_select_options.build name: 'Mister Foo'
      @option_2 = field.multiple_select_options.build name: 'Mister Bar'

      # === Localizations ===

      Mongoid::Fields::I18n.locale = :fr

      @option_1.name = 'Monsieur Foo'
      @option_2.name = 'Monsieur Bar'

      Mongoid::Fields::I18n.locale = :en

      blog.save & blog.reload
    end
  end

end
