describe 'CustomFields::Simple' do

  let(:blog) { create_blog }

  let(:a_post) { Post.create title: 'LOL cat', body: 'Lorem ipsum' }

  describe 'a post' do

    subject { blog.posts.create title: 'Hello world', body: 'Lorem ipsum' }

    its(:title) { should eq 'Hello world' }
    its(:persisted?) { should eq true }

  end

  describe 'a post without a blog' do

    before { a_post }

    subject { Post.find a_post._id }

    its(:title) { should eq 'LOL cat' }

  end

  protected

  def create_blog
    Blog.create name: 'My personal blog'
  end

end
