require 'spec_helper'

describe CustomFields::Metadata do

  before(:each) do
    @project = Project.new(:name => 'Locomotive')
    @project.self_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
    @project.self_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string', :required => true)
    @project.self_custom_fields.build(:label => 'Room', :kind => 'string')
  end

  it 'persists metadata' do
    @project.metadata.manager = 'Mr Harrison'
    @project.metadata.hours = 1234
    @project.metadata.room = 'Room #32'
    @project.save

    # @project = Project.find(@project.id) # ie @project.reload
    @project.reload

    @project.metadata.manager.should == 'Mr Harrison'
    @project.metadata.hours.should == '1234'
    @project.metadata.room.should == 'Room #32'
  end

  context 'modifying fields' do

    it 'renames accessors' do
      @project.metadata.manager = 'Mr Harrison'
      @project.self_custom_fields.first._alias = 'manager_dude'

      @project.save && @project.reload

      @project.metadata.manager_dude.should == 'Mr Harrison'
    end

  end

  context 'validation' do
    it 'fails validation when hours are empty' do
      @project.metadata.hours = nil
      @project.valid?.should == false
    end
	
  end

end
