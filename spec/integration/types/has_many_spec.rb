require 'spec_helper'

describe CustomFields::Types::HasMany do

  before(:each) do
    create_client
    create_project

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

  def create_project
    @project = Project.new(:name => 'Locomotive')
    @project.task_custom_fields.build :label => 'Task Locations', :_alias => 'locations', :kind => 'has_many', :target => @client.location_klass.to_s
    @project.save!
  end

end