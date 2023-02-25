# frozen_string_literal: true

describe CustomFields::Types::HasMany do
  before(:each) do
    @blog   = build_blog
    @post_1 = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @post_2 = @blog.posts.build title: 'Keep writing', body: 'Lorem ipsum...'
    @author = @blog.people.build name: 'John Doe'
  end

  it 'is considered as a relationship field type' do
    expect(@blog.posts_custom_fields.last.is_relationship?).to be true
  end

  it 'sets a value' do
    @author.posts = [@post_1, @post_2]

    expect(@author.posts.map(&:title)).to eq ['Hello world', 'Keep writing']
  end

  it 'includes a scope named ordered' do
    expect(@author.posts.respond_to?(:ordered)).to eq true

    expected = { 'position_in_author' => 1 }

    expect(@author.posts.ordered.send(:options)[:sort]).to eq expected
  end

  describe 'validation' do
    context 'when not persisted' do
      it 'is valid if nil' do
        expect(@author.valid?).to eq true
      end

      it 'is valid if empty' do
        @author.posts = []

        expect(@author.valid?).to eq true
      end
    end

    context 'persisted' do
      before(:each) { @author.stubs(:new_record?).returns(false) }

      [nil, []].each do |value|
        it "is not valid if the value is #{value.inspect}" do
          @author.posts = value

          expect(@author.valid?).to eq false
          expect(@author.errors[:posts]).to eq ['must have at least one element']
        end
      end
    end
  end

  context 'multi-thread environment' do
    it 're-builds the class even if it has not been loaded' do
      Object.send(:remove_const, "Post#{@blog._id}".to_sym)

      Blog.expects(:find).with(@blog._id.to_s).returns(@blog)

      expect(@author.posts).to eq []
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build  label: 'Author', type: 'belongs_to', class_name: 'Person', required: true

      field.valid?

      field = blog.people_custom_fields.build label: 'Posts', type: 'has_many', class_name: "Post#{blog._id}",
                                              inverse_of: 'author', required: true

      field.valid?
    end
  end
end
