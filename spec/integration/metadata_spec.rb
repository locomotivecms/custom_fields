require 'spec_helper'

describe CustomFields::Metadata do

  before(:each) do
    # @project = Project.new(:name => 'Locomotive')
    # puts "================ 1"
    # @project.self_custom_fields.build :label => 'Manager name', :_alias => 'manager', :kind => 'string'
    # puts "================ 2"
    # puts "#{@project.self_custom_fields.inspect} / #{@project.metadata.inspect}"

    @project = Project.new(:name => 'Locomotive')
    @project.self_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
    @project.self_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string')
    @project.self_custom_fields.build(:label => 'Room', :kind => 'string')

    # puts "@project = #{@project.self_custom_fields.inspect} \n #{@project.metadata.inspect}"
  end

  it 'persists metadata' do
    puts "======== ACCESSING METADATA =========="
    @project.metadata.manager = 'Mr Harrison'
    @project.metadata.hours = 1234
    @project.metadata.room = 'Room #32'
    @project.save

    puts "======== SAVED !!! ========="

    @project = Project.find(@project.id) #@project.reload

    puts "======== RELOADED ========="

    @project.metadata.manager.should == 'Mr Harrison'
    @project.metadata.hours.should == '1234'
    @project.metadata.room.should == 'Room #32'
  end

end