require 'spec_helper'

describe CustomFields::CustomFieldsFor do

  context 'no posts' do

    before(:each) do
      @blog = Blog.new(:name => "My personal blog")
      @blog.posts_custom_fields.build :label => 'Main Author',  :type => 'string'
      @blog.posts_custom_fields.build :label => 'Location',     :type => 'string'
    end

    # it 'makes sure the field aliases are correctly set' do
    #   @blog.valid?
    #   @blog.posts_custom_fields.first.alias.should == 'main_author'
    # end

    context 'when saving' do

      before(:each) do
        @blog.save
      end

      it 'builds the recipes' do
        # puts @blog._custom_fields_diff.inspect
      end

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