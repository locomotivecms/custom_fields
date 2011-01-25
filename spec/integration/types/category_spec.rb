require 'spec_helper'

describe CustomFields::Types::Category do

  before(:each) do
    puts "====== NEW PROJECT ========"
    @project = Project.new(:name => 'Locomotive')
    @field = @project.task_custom_fields.build(:label => 'Main category', :_alias => 'main_category', :kind => 'Category')
  end

  context 'saving category items' do

    before(:each) do
      puts "===== FILL CATEGORY ITEMS ===="
      @field.category_items.build :name => 'Development'
      @field.category_items.build :name => 'Design'
      @field.updated_at = Time.now
      puts "===== FILL CATEGORY ITEMS (done) ===="
      puts "category items 1 = #{@field.category_items.size}"
      puts "category items 2 = #{@project.task_custom_fields.first.category_items.size}"
      puts "metadata klass? = #{@project.tasks.metadata.klass}"
      puts "category items 3 = #{@project.tasks.metadata.klass.main_category_items.size}"
    end

    it 'persists items' do
      @field.save.should be_true
      @project.reload
      @project.task_custom_fields.first.category_items.size.should == 2
    end

    context 'assigning a category and persists' do

      it 'sets the category from a category name' do
        # @field.save
        # @project = Project.first
        puts "========= TEST ======="
        # task = @project.tasks.build(:main_category => 'Design')
        # puts "_____ task = #{task.class.inspect} ____"
        # task.save #&& @project.reload
        # @project = Project.first
        # puts "========= SAVED ======="
        # puts "        @project.tasks.first = #{@project.tasks.first.class.inspect}"
        # @project.tasks.first.main_category.should == 'Design'
        # puts "GOOD ?"

        task = @project.tasks.build(:main_category => 'Design')

        # puts "...task = #{task.class.custom_fields.inspect}"
        # puts "...task attributes #{task.aliased_attributes.inspect}, #{task.attributes.inspect}"

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
        # puts "__________________ task_custom_fields ? #{@project.task_custom_fields.size}"
        # puts "__________________ proxy custom_fields ? #{@project.tasks.metadata.klass.custom_fields.size}"

        task = @project.tasks.build(:main_category => @field.category_items.last._id)

        # puts "...task = #{task.class.custom_fields.inspect}"
        # puts "...task attributes #{task.aliased_attributes.inspect}, #{task.attributes.inspect}"

        task.save && @project.reload
        @project.tasks.first.main_category.should == 'Design'
      end

    end

  end

end