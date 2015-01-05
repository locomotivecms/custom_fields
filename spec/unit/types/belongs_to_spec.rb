describe CustomFields::Types::BelongsTo do

  before(:each) do
    @blog = build_blog
    @blog.posts_custom_fields

    @author = Person.new name: 'John Doe'
    @post   = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
  end

  it 'is considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be true
  end

  it 'has a field storing the position' do
    expect(@post.respond_to?(:position_in_author)).to be true
  end

  it 'sets a value' do
    @post.author = @author

    expect(@post.author.name).to eq 'John Doe'
  end

  describe 'validation' do

    [nil, ''].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.author = value

        expect(@post.valid?).to be false
        expect(@post.errors[:author]).to_not be_blank
      end
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Author', type: 'belongs_to', class_name: 'Person', required: true

      field.valid?
    end
  end

end