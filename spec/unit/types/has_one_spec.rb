require 'spec_helper'

describe CustomFields::Types::HasOne do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'returns true if it is a HasOne' do
      @field.kind = 'has_one'
      @field.has_one?.should be_true
    end

    it 'returns false if it is not a HasOne' do
      @field.kind = 'string'
      @field.has_one?.should be_false
    end

  end

  context '#validation' do

    before(:each) do
      @project = build_project_task_with_custom_field
    end

    it 'marks it as invalid if the field is not filled in' do
      task = @project.tasks.build
      task.valid?.should be_false
      task.errors[:chef].should_not be_empty
    end

    it 'marks the target class as valid if the field is filled in' do
      task = @project.tasks.build :chef => Person.new(:name => 'Rick Gervais')
      task.valid?.should be_true
    end

  end

  def build_project_task_with_custom_field
    Project.new.tap do |project|
      project.task_custom_fields.build :label => 'Person in charge', :_alias => 'chef', :kind => 'has_one', :_name => 'field_1', :target => 'Person', :required => true
    end
  end

end