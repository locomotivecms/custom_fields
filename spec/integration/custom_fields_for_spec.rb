describe 'CustomFields::CustomFieldsFor' do

  before(:each) do
    @blog = create_blog
  end

  it 'makes sure the field names are correctly set' do
    @blog.valid?

    expect(@blog.posts_custom_fields.first.name).to eq 'main_author'
  end

  context 'keeps target model_name property' do
    before(:each) do
      @blog.save

      @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...', main_author: 'Jon Doe'
    end

    it 'set valid target model_name' do
      expect(@post.model_name).to eq 'Post'
      expect(@post.class.model_name).to eq 'Post'
    end

    it 'restore valid target model_name object' do
      @post.save

      blog = Blog.find @blog._id

      post = blog.posts.first

      expect(post.model_name).to be_kind_of(ActiveModel::Name)
    end

  end

  context 'no posts' do

    describe 'recipe' do

      before(:each) do
        @blog.valid?

        @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
      end

      it 'is included in new posts' do
        expect(@post.title).to eq 'Hello world'
        expect(@post.custom_fields_recipe).not_to be false
      end

    end

  end

  context 'with a bunch of existing posts' do

    before(:each) do
      @blog = Blog.create name: 'My personal blog'
      @blog.posts.create title: 'Hello world',  body: 'Lorem ipsum...'
      @blog.posts.create title: 'Welcome home', body: 'Lorem ipsum...'
      @blog.reload

      @blog.posts_custom_fields.build label: 'Main Author', type: 'string'
      @blog.posts_custom_fields.build label: 'Location',    type: 'string'
      @blog.save & @blog.reload
    end

    it 'includes the new fields' do
      post = @blog.posts.first

      expect(post.respond_to?(:main_author)).to be true
      expect(post.respond_to?(:location)).to be true
    end

    it 'renames a field' do
      @blog.posts_custom_fields.first.name = 'author'
      @blog.save & @blog.reload

      post = @blog.posts.first

      expect(post.respond_to?(:author)).to be true
      expect(post.respond_to?(:main_author)).to be false
    end

    it 'destroys a field' do
      @blog.posts_custom_fields.delete_all(name: 'main_author' )
      @blog.save & @blog.reload

      post = @blog.posts.first

      expect(post.respond_to?(:main_author)).to be false
      expect(post.respond_to?(:location)).to be true
    end

  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Main Author', type: 'string'
      blog.posts_custom_fields.build label: 'Location',    type: 'string'
    end
  end

end