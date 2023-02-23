describe 'CustomFields::Validations' do

  before(:each) do
    @blog = create_blog
  end

  it 'owns only one validator' do
    expect(@blog.posts.build.class.validators.size).to eq 3
  end

  it 'does not duplicate the list of validators if adding new fields' do
    3.times do |i|
      @blog.posts_custom_fields.build label: "field #{i}", type: 'string'

      expect(@blog.save).to eq true

      @blog.send :refresh_posts_metadata
    end

    @blog = Blog.find(@blog._id) # Hard reload

    expect(@blog.posts.build.class.validators.size).to eq 3
    expect(@blog.klass_with_custom_fields(:posts).validators.size).to eq 3
  end

  it 'validates uniqueness' do
    post = @blog.posts.create(post_attributes)

    expect(post).to be_valid

    post = @blog.posts.create(post_attributes)

    expect(post).to_not be_valid
    expect(post.errors[:codename].first).to eq 'has already been taken'
  end

  it 'validates uniqueness (and allows blank)' do
    post = @blog.posts.create(post_attributes.merge(codename: ''))
    expect(post).to be_valid
    another_post = @blog.posts.create(post_attributes.merge(codename: ''))
    expect(another_post).to be_valid
  end

  protected

  def create_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build label: 'Codename',    type: 'string', unique: true
      blog.posts_custom_fields.build label: 'Main Author', type: 'string', required: true
      blog.posts_custom_fields.build label: 'Location',    type: 'string'
      blog.save & blog.reload
    end
  end

  def post_attributes
    { title: 'My fancy post', body: 'Lipsum', codename: 'blog', main_author: 'Me', location: 'Somewhere' }
  end

end