describe CustomFields::Types::String do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  it 'sets a value' do
    expected = 'John Doe'

    @post.author = expected

    expect(@post.author).to be expected
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.author = value

        expect(@post.valid?).to eq false
        expect(@post.errors[:author]).not_to be_blank
      end
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(@post.class.string_attribute_get(@post, 'author')).to eq expected
    end

    it 'returns the value' do
      @post.author = 'John Doe'

      expected = { 'author' => 'John Doe' }

      expect(@post.class.string_attribute_get(@post, 'author')).to eq expected
    end

    it 'sets a nil value' do
      expect(@post.class.string_attribute_set(@post, 'author', {})).to be_nil
    end

    it 'sets a value' do
      @post.class.string_attribute_set(@post, 'author', { 'author' => 'John' })

      expect(@post.author).to eq 'John'
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Author', type: 'string', required: true

      field.valid?
    end
  end

end