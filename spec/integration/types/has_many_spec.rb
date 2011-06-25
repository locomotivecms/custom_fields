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

    # TODO: test for values to be the same as well as ids
    @task_1.developers.ids.should include(@employee_1._id)
    @task_1.developers.ids.should include (@employee_2._id)
    @task_2.developers.ids.should include(@employee_3._id)
  end

  it 'returns an empty array if there are no owned items' do
    @task_3.developers.values.should be_empty
    @task_3.developers.ids.should be_empty
  end

  it 'does not include elements with a different owner'

  it 'does not include elements with no owner'

  it 'creates owned objects with the correct owner'


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

end
