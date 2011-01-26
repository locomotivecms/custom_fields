require 'spec_helper'

describe CustomFields::Types::Category do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @field = @project.task_custom_fields.build(:label => 'Main category', :_alias => 'main_category', :kind => 'Category')
  end

  context 'saving category items' do

    before(:each) do
      @field.category_items.build :name => 'Development'
      @field.category_items.build :name => 'Design'
      @field.updated_at = Time.now
    end

    it 'persists items' do
      @field.save.should be_true
      @project.reload
      @project.task_custom_fields.first.category_items.size.should == 2
    end

    context 'assigning a category and persists' do

      it 'sets the category from a category name' do
        task = @project.tasks.build(:main_category => 'Design')

        task.save

        @project = Project.find(@project.id)

        @project.tasks.first.main_category.should == 'Design'
      end

      it 'sets the category from an id (string)' do
        task = @project.tasks.build(:main_category => @field.category_items.last._id.to_s)
        task.save && @project.reload
        @project.tasks.first.main_category.should == 'Design'
      end

      it 'sets the category from an id (BSON::ObjectId)' do
        task = @project.tasks.build(:main_category => @field.category_items.last._id)
        task.save && @project.reload
        @project.tasks.first.main_category.should == 'Design'
      end

    end

  end

end