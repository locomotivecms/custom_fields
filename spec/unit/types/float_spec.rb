describe CustomFields::Types::Float do

  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  it 'sets a value' do
    @post.count = 1.42

    expect(@post.count).to eq 1.42
  end

  describe 'validation' do

    [nil, '', true, 'John Doe'].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.count = value

        expect(@post.valid?).to eq false
        expect(@post.errors[:count]).not_to be_blank
      end
    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(@post.class.float_attribute_get(@post, 'count')).to eq expected
    end

    it 'returns the value' do
      @post.count = 42.12345

      expected = { 'count' => 42.12345 }

      expect(@post.class.float_attribute_get(@post, 'count')).to eq expected
    end

    it 'sets a nil value' do
      expect(@post.class.float_attribute_set(@post, 'count', {})).to be_nil
    end

    it 'sets a value' do
      @post.class.float_attribute_set(@post, 'count', { 'count' => 42.12345 })

      expect(@post.count).to eq 42.12345
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Count', type: 'float', required: true

      field.valid?
    end
  end

end