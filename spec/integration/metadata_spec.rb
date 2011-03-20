require 'spec_helper'

describe CustomFields::Metadata do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @project.self_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
    @project.self_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string')
    @project.self_custom_fields.build(:label => 'Room', :kind => 'string')
  end

  it 'persists metadata' do
    @project.safe_metadata.manager = 'Mr Harrison'
    @project.safe_metadata.hours = 1234
    @project.safe_metadata.room = 'Room #32'
    @project.save

    # @project = Project.find(@project.id) # ie @project.reload
    @project.reload

    @project.safe_metadata.manager.should == 'Mr Harrison'
    @project.safe_metadata.hours.should == '1234'
    @project.safe_metadata.room.should == 'Room #32'
  end

  context 'modifying fields' do

    it 'renames accessors' do
      @project.safe_metadata.manager = 'Mr Harrison'
      @project.self_custom_fields.first._alias = 'manager_dude'

      @project.save && @project.reload

      @project.safe_metadata.manager_dude.should == 'Mr Harrison'
    end

  end

end