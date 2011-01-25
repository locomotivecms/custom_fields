require 'spec_helper'

describe CustomFields::Types::Category do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'has the category items field' do
      @field.respond_to?(:category_items).should be_true
    end

    it 'has the apply method used for the target object' do
      @field.respond_to?(:apply_category_type).should be_true
    end

    it 'returns true if it is a Category' do
      @field.kind = 'category'
      @field.category?.should be_true
    end

    it 'returns false if it is not a Category' do
      @field.kind = 'string'
      @field.category?.should be_false
    end

  end

  context 'on target class' do

    before(:each) do
      @project = build_project #_with_category
      @task = @project.tasks.build
    end

    it 'has getter/setter' do
      @task.respond_to?(:global_category).should be_true
      @task.respond_to?(:global_category=).should be_true
    end

    it 'has the values of this category' do
      @task.class.global_category_names.should == %w{Maintenance Design Development}
    end

    it 'sets the category from a name' do
      @task.global_category = 'Design'
      @task.global_category.should == 'Design'
      @task.field_1.should == fake_bson_id(42)
    end

    it 'does not set the category if it does not exit' do
      @task.global_category = 'Accounting'
      @task.global_category.should be_nil
      @task.field_1.should be_nil
    end

    context 'group by category' do

      before(:each) do
        # seed_projects
        seed_tasks
        # @groups = @project.class.group_by_global_category
        @task_class = @project.instance_variable_get(:@tasks_proxy_class)
        @groups = @task_class.group_by_global_category
      end

      it 'is an non empty array' do
        @groups.class.should == Array
        @groups.size.should == 3
      end

      it 'is an array of hash composed of a name' do
        @groups.collect { |g| g[:name] }.should == %w{Maintenance Design Development}
      end

      it 'is an array of hash composed of a list of objects' do
        @groups[0][:items].size.should == 0
        @groups[1][:items].size.should == 1
        @groups[2][:items].size.should == 2
      end

      it 'allows to pass method to retrieve items' do
        @project.expects(:ordered_tasks)
        @task_class.group_by_global_category(:ordered_tasks)
      end

    end

  end

  def build_project
    project = Project.new

    field = project.task_custom_fields.build :label => 'Global Category', :kind => 'Category', :_name => 'field_1'
    field.category_items.build :name => 'Development', :_id => fake_bson_id(41), :position => 2
    field.category_items.build :name => 'Design', :_id => fake_bson_id(42), :position => 1
    field.category_items.build :name => 'Maintenance', :_id => fake_bson_id(43), :position => 0

    project
    #
    # field = build_category
    # Project.to_klass_with_custom_fields(field, nil, 'self_custom_fields').new
  end

  # def build_category
  #   field = CustomFields::Field.new(:label => 'global_category', :_name => 'field_1', :kind => 'Category')
  #   field.stubs(:valid?).returns(true)
  #   field.category_items.build :name => 'Development', :_id => fake_bson_id(41), :position => 2
  #   field.category_items.build :name => 'Design', :_id => fake_bson_id(42), :position => 1
  #   field.category_items.build :name => 'Maintenance', :_id => fake_bson_id(43), :position => 0
  #   field
  # end
  #
  # def seed_projects
  #   list = [
  #     @project.class.new(:name => 'Locomotive CMS', :global_category => fake_bson_id(41)),
  #     @project.class.new(:name => 'Ruby on Rails', :global_category => fake_bson_id(41)),
  #     @project.class.new(:name => 'Dribble', :global_category => fake_bson_id(42))
  #   ]
  #   @project.class.stubs(:all).returns(list)
  # end

  def seed_tasks
    @project.tasks.build :name => 'Locomotive CMS', :global_category => fake_bson_id(41)
    @project.tasks.build :name => 'Ruby on Rails', :global_category => fake_bson_id(41)
    @project.tasks.build :name => 'Dribble', :global_category => fake_bson_id(42)
    #
    # list = [
    #   @project.tasks..new(:name => 'Locomotive CMS', :global_category => fake_bson_id(41)),
    #   @project.class.new(:name => 'Ruby on Rails', :global_category => fake_bson_id(41)),
    #   @project.class.new(:name => 'Dribble', :global_category => fake_bson_id(42))
    # ]
    # @project.class.stubs(:all).returns(list)
  end


  def fake_bson_id(id)
    BSON::ObjectId(id.to_s.rjust(24, '0'))
  end

end