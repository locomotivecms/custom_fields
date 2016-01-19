describe CustomFields::Types::Color do

  let(:default) { nil }
  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'sets a value' do
    expect(post.text_color).to eq nil
    post.text_color = '#000'
    expect(post.text_color).to eq '#000'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        post.text_color = value

        expect(post.valid?).to eq false
        expect(post.errors[:text_color]).not_to be_blank
      end
    end

  end

  describe 'default value' do

    let(:default) { '#ccc' }

    subject { post.text_color }

    it { is_expected.to eq '#ccc' }

  end

  describe 'getter and setter' do

    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(post.class.color_attribute_get(post, 'text_color')).to eq expected
    end

    it 'returns the value' do
      post.text_color = '#f00'

      expected = { 'text_color' => '#f00' }

      expect(post.class.color_attribute_get(post, 'text_color')).to eq expected
    end

    it 'sets a nil value' do
      expect(post.class.color_attribute_set(post, 'text_color', {})).to be_nil
    end

    it 'sets a value' do
      post.class.color_attribute_set(post, 'text_color', { 'text_color' => '#f00' })

      expect(post.text_color).to eq '#f00'
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Text color', type: 'color', required: true, default: default

      field.valid?
    end
  end

end
