require 'spec_helper'

describe CustomFields::Types::Category do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    # puts "_writing_attributes_with_custom_fields (before) => #{@project.instance_variable_get(:@_writing_attributes_with_custom_fields).inspect}"
    @field = @project.task_custom_fields.build(:label => 'Main category', :_alias => 'main_category', :kind => 'Category')
    @another_field = @project.task_custom_fields.build(:label => 'Domain category', :_alias => 'domain_category', :kind => 'Category')
    # @project.save
    # @project.reload
    # puts "metadata = #{@project.metadata.inspect}"
    # puts "_writing_attributes_with_custom_fields => #{@project.instance_variable_get(:@_writing_attributes_with_custom_fields).inspect}"
  end

  context 'saving category items' do

    before(:each) do
      # @field = @project.task_custom_fields.first
      @field.category_items.build :name => 'Development'
      @field.category_items.build :name => 'Design'
      # @field.updated_at = Time.now
    end

    it 'persists items' do
      @field.save.should be_true
      @project.reload
      @project.task_custom_fields.first.category_items.size.should == 2
      @project.task_custom_fields.last.category_items.size.should == 0
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