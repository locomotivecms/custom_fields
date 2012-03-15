require 'spec_helper'

describe CustomFields::TargetHelpers do

  before(:each) do
    @post = build_post_with_rules
  end

  context '#grouping fields' do

    it 'returns empty arrays if no rules' do
      @post.stubs(:custom_fields_recipe).returns({ 'rules' => [] })
      @post.select_custom_fields.should be_empty
      @post.file_custom_fields.should be_empty
      @post.has_many_custom_fields.should be_empty
      @post.many_to_many_custom_fields.should be_empty
    end

    it 'groups select fields' do
      @post.select_custom_fields.should == %w(category)
    end

    it 'groups file fields' do
      @post.file_custom_fields.should == %w(illustration author_picture)
    end

    it 'groups has_many fields including the inverse_of property' do
      @post.has_many_custom_fields.should == [%w(projects project), %w(illustrations project)]
    end

    it 'groups many_to_many fields including the field name to get the target ids' do
      @post.many_to_many_custom_fields.should == [%w(contributors contributor_ids)]
    end

  end

  context '#returning safe attributes' do

    before(:each) do
      @safe_attributes = @post.custom_fields_safe_attributes
    end

    it 'includes attributes for string' do
      @safe_attributes.include?('author_name').should be_true
    end

    it 'includes attributes for integer' do
      @safe_attributes.include?('author_age').should be_true
    end

    it 'includes attributes for money' do
      @safe_attributes.include?('formatted_donation').should be_true
     end

    it 'includes attributes for boolean' do
      @safe_attributes.include?('visible').should be_true
    end

    it 'includes attributes for date' do
      @safe_attributes.include?('formatted_posted_at').should be_true
    end

    it 'includes attributes for file' do
      @safe_attributes.include?('illustration').should be_true
      @safe_attributes.include?('remove_illustration').should be_true
    end

    it 'includes attributes for select' do
      @safe_attributes.include?('category_id').should be_true
      @safe_attributes.include?('category').should be_false
    end

    it 'includes attributes for belongs_to' do
      @safe_attributes.include?('ghost_writer_id').should be_true
      @safe_attributes.include?('position_in_ghost_writer').should be_true
      @safe_attributes.include?('ghost_writer').should be_false
    end

    it 'does not include attributes for has_many and many_to_many' do
      @safe_attributes.include?('contributors').should be_false
      @safe_attributes.include?('projects').should be_false
    end

  end

  context '#returning methods' do

    before(:each) do
      @methods = @post.custom_fields_methods
    end

    it 'includes the default method name for string, integer, select, boolean, has_many and many_to_many fields' do
      %w(author_name author_age category visible projects illustrations contributors).each do |name|
        @methods.include?(name).should be_true
      end
    end

    it 'also includes another method name for select (<name>_id)' do
      @methods.include?('category_id').should be_true
    end

    it 'includes the method name for files' do
      @methods.include?('illustration_url').should be_true
      @methods.include?('illustration').should be_false
      @methods.include?('author_picture_url').should be_true
      @methods.include?('author_picture').should be_false
    end

    it 'includes the method name for dates' do
      @methods.include?('formatted_posted_at').should be_true
      @methods.include?('posted_at').should be_false
    end

    it 'includes the method name for money' do
      @methods.include?('formatted_donation').should be_true
    end

    it 'includes the method name for belongs_to relationships' do
      @methods.include?('formatted_posted_at').should be_true
      @methods.include?('posted_at').should be_false
    end

    it 'includes the method name for the has_many and many_to_many relationships' do
      %w(contributors projects illustrations).each do |name|
        @methods.include?(name).should be_true
      end
    end

    it 'filters the list by passing a block' do
      @post.custom_fields_methods do |rules|
        %w(string boolean integer money).include?(rules['type'])
      end.should == %w(visible author_name author_age formatted_donation)
    end

  end

  def build_post_with_rules
    Post.new(:title => 'Hello world').tap do |post|
      post.stubs(:custom_fields_recipe).returns({
        'rules' => [
          { 'name' => 'category',         'type' => 'select', 'required' => false, 'localized' => false },
          { 'name' => 'posted_at',        'type' => 'date', 'required' => false, 'localized' => false },
          { 'name' => 'visible',          'type' => 'boolean', 'required' => false, 'localized' => false },
          { 'name' => 'ghost_writer',     'type' => 'belongs_to', :class_name => 'Person', 'required' => false, 'localized' => false },
          { 'name' => 'illustration',     'type' => 'file', 'required' => false, 'localized' => false },
          { 'name' => 'author_name',      'type' => 'string', 'required' => false, 'localized' => false },
          { 'name' => 'author_age',       'type' => 'integer', 'required' => false, 'localized' => false },
          { 'name' => 'donation',         'type' => 'money', 'required' => false, 'localized' => false },
          { 'name' => 'author_picture',   'type' => 'file', 'required' => false, 'localized' => false },
          { 'name' => 'contributors',     'type' => 'many_to_many', 'class_name' => 'Person', 'inverse_of' => 'posts', 'required' => false, 'localized' => false },
          { 'name' => 'projects',         'type' => 'has_many', 'class_name' => 'Project', 'inverse_of' => 'project', 'required' => false, 'localized' => false },
          { 'name' => 'illustrations',    'type' => 'has_many', 'class_name' => 'PostImage', 'inverse_of' => 'project', 'required' => false, 'localized' => false }
        ]})
    end
  end

end
