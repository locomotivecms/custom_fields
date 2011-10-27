require 'spec_helper'

describe CustomFields::Types::Category do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @field = @project.tasks_custom_fields.build(:label => 'Main category', :_alias => 'main_category', :kind => 'Category')
    @another_field = @project.tasks_custom_fields.build(:label => 'Domain category', :_alias => 'domain_category', :kind => 'Category')
  end

  context 'saving category items' do

    before(:each) do
      @field.category_items.build :name => 'Development'
      @field.category_items.build :name => 'Design'
    end

    it 'persists items' do
      @field.save.should be_true
      @project.reload
      @project.tasks_custom_fields.first.category_items.size.should == 2
      @project.tasks_custom_fields.last.category_items.size.should == 0
    end

    it 'does not mix items of 2 category fields' do
      @another_field.category_items.build :name => 'IT'
      @another_field.category_items.build :name => 'Industry'
      @another_field.save.should be_true
      @project.reload

      klass = @project.tasks.build.class

      klass.main_category_names.should == %w{Development Design}
      klass.domain_category_names.should == %w{IT Industry}
    end

    context 'assigning a category and persists' do

      before(:each) do
        @project.save # persists the custom fields
      end

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