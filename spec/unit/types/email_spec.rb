describe CustomFields::Types::Email do

  let(:default) { nil }
  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'sets a value' do
    expect(post.email).to eq nil
    post.email = 'john@doe.net'
    expect(post.email).to eq 'john@doe.net'
  end

  describe 'validation' do

    [nil, 'foo.fr', 'foo@foo'].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.email = value
        expect(post.valid?).to eq false
        expect(post.errors[:email]).not_to be_blank
      end
    end

  end

  describe 'default value' do

    let(:default) { 'john@doe.net' }

    subject { post.email }

    it { is_expected.to eq 'john@doe.net' }

    context 'when unsetting a value' do

      before { post.email = 'jane@doe.net'; post.email = nil }

      it { is_expected.to eq nil }

    end

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expect(post.class.string_attribute_get(post, 'email')).to eq({})
    end

    it 'returns the value' do
      post.email = 'john@doe.net'
      expect(post.class.string_attribute_get(post, 'email')).to eq('email' => 'john@doe.net')
    end

    it 'sets a nil value' do
      expect(post.class.string_attribute_set(post, 'email', {})).to be_nil
    end

    it 'sets a value' do
      post.class.string_attribute_set(post, 'email', { 'email' => 'john@doe.net' })
      expect(post.email).to eq 'john@doe.net'
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Email', type: 'email', required: true, default: default
      field.valid?
    end
  end

end
