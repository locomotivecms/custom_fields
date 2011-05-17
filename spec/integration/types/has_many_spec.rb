require 'spec_helper'

describe CustomFields::Types::HasMany do

  before(:each) do
    create_client
    create_project

    @task = @project.tasks.build :title => 'Managing team'
    @another_task = @project.tasks.build :title => 'Cleaning'
  end

  it 'attaches many different locations to a task' do
    @task.locations << @location_1
    @task.locations << @location_2

    # puts @task.locations.inspect
    # puts @task.location_ids.inspect
    # puts "===="
    # puts @task.custom_field_1.inspect
    # puts "----"

    # puts @task.inspect

    @task.save && @task = Mongoid.reload_document(@task)

    @task.locations.should_not be_empty
    @task.locations.collect(&:_id).should == [@location_1._id, @location_2._id]
  end

  # ___ helpers ___

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

  # def reload_document(doc)
  #   if doc.embedded?
  #     parent = doc.class._parent.reload
  #     parent.send(doc.metadata.name).find(doc._id)
  #   else
  #     doc.class.find(doc._id)
  #   end
  # end

end