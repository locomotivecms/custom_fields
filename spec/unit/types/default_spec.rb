require 'spec_helper'

describe CustomFields::Types::Default do

  context 'on target class' do

    before(:all) do
      @project = build_project_task_with_custom_field
    end

    context '#validation' do

      it 'marks the target class as invalid if the field is not filled in' do
        task = @project.tasks.build
        task.valid?.should be_false
        task.errors[:chef].should_not be_empty
      end

      it 'marks the target class as valid if the field is filled in' do
        task = @project.tasks.build :chef => 'Ricky Gervais'
        task.valid?.should be_true
      end

    end

  end

  def build_project_task_with_custom_field
    Project.new.tap do |project|
      project.task_custom_fields.build :label => 'Person in charge', :_alias => 'chef', :kind => 'string', :_name => 'field_1', :required => true
    end
  end

end