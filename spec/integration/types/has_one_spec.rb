require 'spec_helper'

describe CustomFields::Types::HasOne do

  before(:each) do
    create_client
    create_project

    @task = @project.tasks.build :title => 'Managing team'
    @another_task = @project.tasks.build :title => 'Cleaning'
  end

  it 'returns nil if no attached object' do
    @task.location.should be_nil
  end

  it 'attaches a location to a task' do
    @task.location = @location_1
    @task.save && @task = Mongoid.reload_document(@task)

    @task.location.should_not be_nil
    @task.location.name.should == 'office'
    @task.location.country.should == 'US'
  end

  it 'returns nil if the target element has been removed' do
    @task.location = @location_1
    @task.save

    @location_1.destroy

    @task = Mongoid.reload_document(@task)
    @task.location.should be_nil
  end

  it 'returns nil if the target class does not exist anymore' do
    @task.location = @location_1
    @task.save

    @client.destroy

    @task = Mongoid.reload_document(@task)
    @task.location.should be_nil
  end

  # ___ helpers ___

  def create_client
    @client = Client.new(:name => 'NoCoffee')
    @client.locations_custom_fields.build :label => 'Country', :_alias => 'country', :kind => 'String'

    @client.save!

    @location_1 = @client.locations.build :name => 'office', :country => 'US'
    @location_2 = @client.locations.build :name => 'dev lab', :country => 'FR'

    @client.save!
  end

  def create_project
    @project = Project.new(:name => 'Locomotive')
    @project.tasks_custom_fields.build :label => 'Task Location', :_alias => 'location', :kind => 'has_one', :target => @client.locations_klass.to_s
    @project.save!
  end

end