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

  describe '#validation' do

    describe 'simple' do

      before(:each) do
        @project = Project.new.tap do |project|
          project.task_custom_fields.build :label => 'Developers', :_alias => 'developers', :kind => 'has_many', :_name => 'field_1', :target => 'Person', :required => true
        end
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

    end

    describe 'reverse' do

      before(:each) do
        CustomFields::Types::HasMany::ReverseLookupProxyCollection.any_instance.stubs(:collection).returns([])
        @project, @company = Project.new, Company.new
        @company.employee_custom_fields.build :label => 'Task', :_alias => 'task', :kind => 'has_one', :target => @project.task_klass.to_s
        puts "target_klass = #{@company.employee_klass.to_s.inspect}"
        @project.task_custom_fields.build :label => 'Designers', :_alias => 'designers', :kind => 'has_many', :target => @company.employee_klass.to_s, :reverse_lookup => 'custom_field_1', :required => true
        @project.task_custom_fields.build :label => 'foo', :_alias => 'foo', :kind => 'string', :required => true
        puts "======="
      end

      it 'marks it as invalid if there are no owned items' do
        task = @project.tasks.build
        puts task.inspect
        puts "#validators = #{task.class.validators.size}"
        task.class.validators.each { |v| puts v.inspect }
        task.valid?.should be_false
        task.errors[:designers].should_not be_empty
      end

      it 'marks it as valid if there are owned items' do
        task = @project.tasks.build :designers => [Person.new(:name => 'Rick Gervais'), Person.new(:name => 'Rick Olson')]
        task.valid?.should be_true
      end

    end

  end

end
