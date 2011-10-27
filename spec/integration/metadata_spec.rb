require 'spec_helper'

describe CustomFields::SelfMetadata do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @project.self_metadata_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
    @project.self_metadata_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string')
    @project.self_metadata_custom_fields.build(:label => 'Room', :kind => 'string')
    @project.save
  end

  it 'persists metadata' do
    @project.self_metadata.manager = 'Mr Harrison'
    @project.self_metadata.hours = 1234
    @project.self_metadata.room = 'Room #32'
    @project.save

    @project = Project.find(@project._id)

    @project.self_metadata.manager.should == 'Mr Harrison'
    @project.self_metadata.hours.should == '1234'
    @project.self_metadata.room.should == 'Room #32'
  end

  context 'modifying fields' do

    it 'renames accessors' do
      @project.self_metadata.manager = 'Mr Harrison'
      @project.self_metadata_custom_fields.first._alias = 'manager_dude'

      @project.save
      @project = Project.find(@project._id)

      @project.self_metadata.manager_dude.should == 'Mr Harrison'
    end

  end

end