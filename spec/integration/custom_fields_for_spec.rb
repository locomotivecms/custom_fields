require 'spec_helper'

describe 'CustomFieldsFor' do

  before(:each) do
    @blog = build_blog
  end

  it 'makes sure the field aliases are correctly set' do
    @blog.valid?
    @blog.posts_custom_fields.first.alias.should == 'main_author'
  end

  context 'no posts' do

    describe 'recipe' do

      before(:each) do
        @blog.valid?
        puts "8>--------"
        @post = @blog.posts.build :title => 'Hello world', :body => 'Lorem ipsum...'
        puts "--------<8"
      end

      it 'is included in new posts' do
        puts @post.inspect
        @post.title.should == 'Hello world'
        @post.custom_fields_recipe.should_not be_false
      end

    end

  end

  context 'with a bunch of existing posts' do

    before(:each) do
      @blog = Blog.create(:name => 'My personal blog')
      @blog.posts.create :title => 'Hello world', :body => 'Lorem ipsum...'
      @blog.posts.create :title => 'Welcome home', :body => 'Lorem ipsum...'
      @blog.reload

      @blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      @blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
      @blog.save
      @blog.reload
    end

    it 'includes the new fields' do
      post = @blog.posts.first
      post.attributes.key?('main_author').should be_true
      post.attributes.key?('location').should be_true
    end

    it 'renames field' do
      @blog.posts_custom_fields.first.alias = 'author'
      @blog.save &  @blog.reload
      post = @blog.posts.first
      puts post.attributes.inspect
      post.attributes.key?('author').should be_true
      post.attributes.key?('main_author').should be_false
    end

  end

  def build_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
    end
  end
end

  # describe 'Saving' do
  #
  #   before(:each) do
  #     @project = Project.new(:name => 'Locomotive')
  #     @project.people_custom_fields.build(:label => 'E-mail', :_alias => 'email', :kind => 'string')
  #     @project.people_custom_fields.build(:label => 'Age', :_alias => 'age', :kind => 'string')
  #
  #     @project.self_metadata_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
  #     @project.self_metadata_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string')
  #     @field = @project.self_metadata_custom_fields.build(:label => 'Room', :kind => 'string')
  #   end
  #
  #   context '#validate' do
  #
  #     it 'makes sure the field aliases are correctly set' do
  #       @field.expects(:set_alias).at_least(1)
  #       @project.valid?
  #     end
  #
  #   end
  #
  #   context '#create' do
  #
  #     it 'persists parent object' do
  #       lambda { @project.save }.should change(Project, :count).by(1)
  #     end
  #
  #     it 'persists custom fields for collection' do
  #       @project.save
  #       @project = Project.find(@project._id)
  #       @project.people_custom_fields.count.should == 2
  #     end
  #
  #     it 'persists custom fields for metadata' do
  #       @project.save
  #       @project = Project.find(@project._id)
  #       @project.self_metadata_custom_fields.count.should == 3
  #     end
  #
  #   end
  #
  # end

# end