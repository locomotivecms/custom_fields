require 'spec_helper'

describe CustomFields::Types::HasMany do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'returns true if it is a HasMany' do
      @field.kind = 'has_many'
      @field.has_many?.should be_true
    end

    it 'returns false if it is not a HasMany' do
      @field.kind = 'string'
      @field.has_many?.should be_false
    end

  end

  context '#validation' do

    before(:each) do
      @project = build_project_task_with_custom_field
    end

    it 'marks it as invalid if the field is not filled in' do
      task = @project.tasks.build
      task.valid?.should be_false
      task.errors[:developers].should_not be_empty
    end

    it 'marks the target class as valid if the field is filled in' do
      task = @project.tasks.build :developers => [Person.new(:name => 'Rick Gervais'), Person.new(:name => 'Rick Olson')]
      task.valid?.should be_true
    end

    it 'marks it as invalid if there are no owned items'

    it 'marks it as valid if there are owned items'

  end

  def build_project_task_with_custom_field
    Project.new.tap do |project|
      project.task_custom_fields.build :label => 'Developers', :_alias => 'developers', :kind => 'has_many', :_name => 'field_1', :target => 'Person', :required => true
    end
  end

end
