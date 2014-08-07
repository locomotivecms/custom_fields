require 'spec_helper'

describe 'CustomFieldsFor' do

  let(:blog) { create_blog }

  let(:a_post) { Post.create(title: 'LOL cat', body: 'Lorem ipsum') }

  describe 'post' do

    subject { blog.posts.create(title: 'Hello world', body: 'Lorem ipsum') }

    its(:persisted?) { should be true }
    its(:title) { should == 'Hello world' }

  end

  describe 'a post without a blog' do

    before { a_post }

    subject { Post.find(a_post._id) }

    its(:title) { should == 'LOL cat' }

  end

  def create_blog
    Blog.create(name: 'My personal blog')
  end
end
