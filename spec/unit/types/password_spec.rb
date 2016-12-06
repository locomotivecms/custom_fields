describe CustomFields::Types::Password do

  let(:blog)    { build_blog }
  let(:field)   { blog.posts_custom_fields.first }
  let(:post)    { blog.posts.build title: 'Hello world', body: 'Lorem ipsum...' }

  it 'is not considered as a relationship field type' do
    expect(field.is_relationship?).to be false
  end

  it 'sets a value' do
    expect(post.password_hash).to eq nil
    post.password = 'easyone'
    expect(post.password_hash.to_s).not_to eq 'easyone'
  end

  it "doesn't replace the current password if the new value is blank" do
    post.password = 'easyone'
    current_hashed_password = post.password_hash
    post.password = nil
    expect(post.password_hash.to_s).to eq current_hashed_password.to_s
  end

  describe 'validation' do

    it "should not valid if the value is too short" do
      post.password = 'short'
      expect(post.valid?).to eq false
      expect(post.errors[:password]).not_to be_blank
    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Password', type: 'password'
      field.valid?
    end
  end

end
