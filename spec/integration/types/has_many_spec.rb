require 'spec_helper'

describe CustomFields::Types::HasMany do

  before(:each) do
    create_client
    create_company
    create_project
    build_company_custom_field
    create_tasks
    create_employees

    @task = @project.tasks.build :title => 'Managing team'
  end

  it 'attaches many different locations to a task' do
    attach_locations_to_task_and_save

    @task.locations.should_not be_empty
    @task.locations.collect(&:_id).should == [@location_1._id, @location_2._id]
  end

  it 'changes the order of the locations' do
    attach_locations_to_task_and_save

    @task.locations = [@location_2._id, @location_1._id]

    @task.save && @task = Mongoid.reload_document(@task)

    @task.locations.first.name.should == 'dev lab'
  end

  it 'resets the locations by passing a blank value' do
    attach_locations_to_task_and_save

    @task.locations = ''

    @task.save && @task = Mongoid.reload_document(@task)

    @task.locations.should be_empty
  end

  it 'does not include elements which have been removed' do
    attach_locations_to_task_and_save

    @task.locations = [@location_2._id, @location_1._id]

    @task.save

    @location_1.destroy

    @task = Mongoid.reload_document(@task)

    @task.locations.size.should == 1
  end

  it 'returns an empty array if the target class does not exist anymore' do
    attach_locations_to_task_and_save

    @task.locations = [@location_2._id, @location_1._id]

    @task.save

    @client.destroy

    @task = Mongoid.reload_document(@task)

    @task.locations.should be_empty
  end


  # Reverse has_many field

  it 'returns all owned items in the target model' do
    @task_1.developers.ids.should include(@employee_1._id)
    @task_1.developers.values.select { |empl|
      empl._id == @employee_1._id
    }.should_not be_empty

    @task_1.developers.ids.should include (@employee_2._id)
    @task_1.developers.values.select { |empl|
      empl._id == @employee_2._id
    }.should_not be_empty

    @task_2.developers.ids.should include(@employee_3._id)
    @task_2.developers.values.select { |empl|
      empl._id == @employee_3._id
    }.should_not be_empty
  end

  it 'returns an empty array if there are no owned items' do
    @task_3.developers.values.should be_empty
    @task_3.developers.ids.should be_empty
  end

  it 'does not include elements with a different owner' do
    @task_1.developers.ids.should_not include(@employee_3._id)
    @task_1.developers.values.select { |empl|
      empl._id == @employee_3._id
    }.should be_empty

    @task_2.developers.ids.should_not include(@employee_1._id)
    @task_2.developers.values.select { |empl|
      empl._id == @employee_1._id
    }.should be_empty

    @task_2.developers.ids.should_not include(@employee_2._id)
    @task_2.developers.values.select { |empl|
      empl._id == @employee_2._id
    }.should be_empty
  end

  it 'does not include elements with no owner' do
    @task_1.developers.ids.should_not include(@employee_4)
    @task_1.developers.values.select { |empl|
      empl._id == @employee_4._id
    }.should be_empty

    @task_2.developers.ids.should_not include(@employee_4)
    @task_2.developers.values.select { |empl|
      empl._id == @employee_4._id
    }.should be_empty
  end

  it 'allows adding objects with no owner or correct owner' do
    employee_5 = @company.employees.build :full_name => 'Bob'
    @task_1.developers << employee_5
    employee_5.task._id.should == @task_1._id

    employee_6 = @company.employees.build :full_name => 'Fred', :task => @task_1
    @task_1.developers << employee_6
    employee_6.task._id.should == @task_1._id

    employee_7 = @company.employees.build :full_name => 'George', :task => @task_2
    lambda{@task_1.developers << employee_7}.should raise_error
  end

  it 'allows clearing owned objects' do
    @task_1.developers.clear!

    reload_employees

    @employee_1.task.should be_nil
    @employee_2.task.should be_nil

    @task_1.developers.ids.should be_empty
    @task_1.developers.values.should be_empty
  end

  it 'allows updating owned objects' do
    @task_1.developers.update([@employee_2, @employee_4])

    reload_employees

    @employee_1.task.should be_nil
    @employee_2.task._id.should == @task_1._id
    @employee_3.task._id.should_not == @task_1._id
    @employee_4.task._id.should == @task_1._id

    @task_1.developers.ids.should_not include(@employee_1._id)
    @task_1.developers.ids.should include(@employee_2._id)
    @task_1.developers.ids.should_not include(@employee_3._id)
    @task_1.developers.ids.should include(@employee_4._id)
  end

  it 'allows assignment to custom field' do
    @task_1.developers = [@employee_2, @employee_4]

    reload_employees

    @employee_1.task.should be_nil
    @employee_2.task._id.should == @task_1._id
    @employee_3.task._id.should_not == @task_1._id
    @employee_4.task._id.should == @task_1._id

    @task_1.developers.ids.should_not include(@employee_1._id)
    @task_1.developers.ids.should include(@employee_2._id)
    @task_1.developers.ids.should_not include(@employee_3._id)
    @task_1.developers.ids.should include(@employee_4._id)
  end

  it 'specifies whether it is a reverse has_many field' do
    developers_field = @task_1.class.custom_fields.detect { |f| f._alias == 'developers' }
    locations_field = @task_1.class.custom_fields.detect { |f| f._alias == 'locations' }

    developers_field.reverse_has_many?.should be_true
    locations_field.reverse_has_many?.should be_false
  end


  # ___ helpers ___

  def attach_locations_to_task_and_save
    @task.locations << @location_1
    @task.locations << @location_2

    @task.save && @task = Mongoid.reload_document(@task)
  end

  def create_client
    @client = Client.new(:name => 'NoCoffee')
    @client.location_custom_fields.build :label => 'Country', :_alias => 'country', :kind => 'String'

    @client.save!

    @location_1 = @client.locations.build :name => 'office', :country => 'US'
    @location_2 = @client.locations.build :name => 'dev lab', :country => 'FR'

    @client.save!
  end

  def create_company
    @company = Company.new(:name => 'Colibri Software')
    @company.save!
  end

  def create_project
    @project = Project.new(:name => 'Locomotive')
    @project.task_custom_fields.build :label => 'Task Locations', :_alias => 'locations', :kind => 'has_many', :target => @client.location_klass.to_s
    @project.task_custom_fields.build :label => 'Developers', :_alias => 'developers', :kind => 'has_many', :target => @company.employee_klass.to_s, :reverse_lookup => 'task'

    @project.save!
  end

  def build_company_custom_field
    @company.employee_custom_fields.build :label => 'Task', :_alias => 'task', :kind => 'has_one', :target => @project.task_klass.to_s
  end

  def create_tasks
    @task_1 = @project.tasks.build :title => 'Write unit test'
    @task_2 = @project.tasks.build :title => 'Write code'
    @task_3 = @project.tasks.build :title => 'Write UI'

    @project.save!
  end

  def create_employees
    @employee_1 = @company.employees.build :full_name => 'John Doe', :task => @task_1
    @employee_2 = @company.employees.build :full_name => 'Jane Doe', :task => @task_1
    @employee_3 = @company.employees.build :full_name => 'John Smith', :task => @task_2
    @employee_4 = @company.employees.build :full_name => 'John Smith'

    @company.save!
  end

  def reload_employees
    @company.reload
    @employee_1 = @company.employees.find(@employee_1._id)
    @employee_2 = @company.employees.find(@employee_2._id)
    @employee_3 = @company.employees.find(@employee_3._id)
    @employee_4 = @company.employees.find(@employee_4._id)
  end

end
