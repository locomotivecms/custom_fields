# frozen_string_literal: true

describe CustomFields::Types::ManyToMany do
  before(:each) do
    @blog     = build_blog
    @post     = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @author_1 = @blog.people.build name: 'John Doe'
    @author_2 = @blog.people.build name: 'Jane Doe'
  end

  it 'is considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be true
  end

  it 'sets a value' do
    @post.authors = [@author_1, @author_2]

    expect(@post.authors.map(&:name)).to eq ['John Doe', 'Jane Doe']
  end

  it 'includes a scope named ordered' do
    expect(@post.authors.respond_to?(:ordered)).to eq true
  end

  describe 'validation' do
    [nil, []].each do |value|
      it "should not valid if the value is #{value.inspect}" do
        @post.authors = value

        expect(@post.valid?).to eq false
        expect(@post.errors[:authors]).to eq ['must have at least one element']
      end
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build  label: 'Authors', type: 'many_to_many', class_name: 'Person',
                                              required: true

      field.valid?
    end
  end
end
