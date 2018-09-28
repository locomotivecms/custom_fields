describe CustomFields::Types::Integer do

  let(:default) { nil }
  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'sets a value' do
    expect(post.count).to eq nil
    post.count = 1
    expect(post.count).to eq 1
  end

  describe 'validation' do

    # https://github.com/rails/rails/issues/33651
    [nil, '', true, 'John Doe', 1.42].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.count = value

        expect(post.valid?).to eq false
        expect(post.errors[:count]).not_to be_blank
      end
    end

  end

  describe 'default value' do

    let(:default) { 1 }

    subject { post.count }

    it { is_expected.to eq 1 }

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(post.class.integer_attribute_get(post, 'count')).to eq expected
    end

    it 'returns the value' do
      post.count = 42

      expected = { 'count' => 42 }

      expect(post.class.integer_attribute_get(post, 'count')).to eq expected
    end

    it 'sets a nil value' do
      expect(post.class.integer_attribute_set(post, 'count', {})).to be_nil
    end

    it 'sets a value' do
      post.class.integer_attribute_set(post, 'count', { 'count' => 42 })

      expect(post.count).to eq 42
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Count', type: 'integer', required: true, default: default
      field.valid?
    end
  end

end
