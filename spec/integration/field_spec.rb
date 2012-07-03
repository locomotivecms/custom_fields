require 'spec_helper'

describe 'CustomFields::Field' do

  before(:each) do
    @blog = create_blog
    @blog = Blog.find(@blog._id)
  end

  describe 'nested_attributes' do

    it 'renames a field' do
      @blog.posts_custom_fields_attributes = {
        '0' => { '_id' => @blog.posts_custom_fields.last._id.to_s, 'label' => 'My location' },
        '1' => { '_id' => @blog.posts_custom_fields.first._id.to_s, 'label' => 'Author' }
      }
      @blog.save
      @blog = Blog.find(@blog._id)
      @blog.posts_custom_fields.first.label.should == 'Author'
      @blog.posts_custom_fields.last.label.should == 'My location'
    end

  end

  def create_blog
    Blog.new(:name => 'My personal blog').tap do |blog|
      blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
      blog.save
    end
  end
end