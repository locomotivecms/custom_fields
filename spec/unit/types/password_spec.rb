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

    it "should be valid" do
      post.password = 'superlongpassword'
      expect(post.valid?).to eq true
    end

    it "should be valid if the confirmation matches the password" do
      post.password = 'superlongpassword'
      post.password_confirmation = 'superlongpassword'
      expect(post.valid?).to eq true
    end

    it "shouldn't be valid if the value is too short" do
      post.password = 'short'
      expect(post.valid?).to eq false
      expect(post.errors[:password]).to eq(['is too short (minimum is 6 characters)'])
    end

    it "shouldn't be valid if the confirmation is blank" do
      post.password = 'superlongpassword'
      post.password_confirmation = ''
      expect(post.valid?).to eq false
      expect(post.errors[:password_confirmation]).to eq(["doesn't match password"])
    end

    it "shouldn't be valid if the confirmation is different from the password" do
      post.password = 'superlongpassword'
      post.password_confirmation = 'superlongpwd'
      expect(post.valid?).to eq false
      expect(post.errors[:password_confirmation]).to eq(["doesn't match password"])
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
