require 'spec_helper'

describe 'CustomFieldsFor' do

  describe 'helpers' do

    before(:each) do
      @blog = Blog.new
    end

    it 'keeps track of all the associations enhanced by the custom fields' do
      @blog._custom_fields_for.should_not be_empty
    end

    it 'tells if an association is enhanced by the custom fields' do
      @blog.custom_fields_for?(:posts).should be_true
    end

  end

  # context '#proxy class'  do
  #
  #   before(:each) do
  #     @project = Project.new
  #     @klass = @project.tasks.klass
  #   end
  #
  #   it 'returns the proxy class in the association' do
  #     @klass.should == @project.tasks.build.class
  #   end
  #
  #   it 'has a link to the parent' do
  #     @klass._parent.should == @project
  #   end
  #
  #   it 'has the association name which references to' do
  #     @klass.association_name.should == :tasks
  #   end
  #
  # end
  #
  # context 'with embedded collection' do
  #
  #   context '#association' do
  #
  #     before(:each) do
  #       @project = Project.new
  #     end
  #
  #     it 'has custom fields for embedded collection' do
  #       @project.respond_to?(:tasks_custom_fields).should be_true
  #     end
  #
  #   end
  #
  #   context '#building' do
  #
  #     before(:each) do
  #       @project = Project.new
  #       build_fake_persisted_field :tasks, :label => 'Short summary', :_alias => 'summary', :kind => 'string'
  #       @project.rebuild_custom_fields_relation :tasks
  #       @task = @project.tasks.build
  #     end
  #
  #     it 'returns a new document whose Class is different from the original one' do
  #       @task.class.should_not == Task
  #     end
  #
  #     it 'returns a new document with custom field' do
  #       @task.respond_to?(:summary).should be_true
  #     end
  #
  #     it 'sets/gets custom attributes' do
  #       @task.summary = 'Lorem ipsum...'
  #       @task.summary.should == 'Lorem ipsum...'
  #     end
  #
  #   end
  #
  # end
  #
  # context 'with related collection' do
  #
  #   context '#association' do
  #
  #     before(:each) do
  #       @project = Project.new
  #     end
  #
  #     it 'has custom fields for related collections' do
  #       @project.respond_to?(:people_custom_fields).should be_true
  #     end
  #
  #   end
  #
  #   context '#building' do
  #
  #     before(:each) do
  #       @project = Project.new
  #       build_fake_persisted_field :people, :label => 'Position in the project', :_alias => 'position', :kind => 'string'
  #       @project.rebuild_custom_fields_relation :people
  #       @person = @project.people.build
  #     end
  #
  #     it 'returns a new document whose Class is different from the original one' do
  #       @person.class.should_not == Person
  #     end
  #
  #     it 'returns a new document with custom field' do
  #       @person.respond_to?(:position).should be_true
  #     end
  #
  #     it 'sets/gets custom attributes' do
  #       @person.position = 'Designer'
  #       @person.position.should == 'Designer'
  #     end
  #
  #   end
  #
  # end
  #
  # context 'for the object itself' do
  #
  #   context '#association' do
  #
  #     before(:each) do
  #       @project = Project.new
  #     end
  #
  #     it 'has custom fields' do
  #       @project.respond_to?(:self_metadata_custom_fields).should be_true
  #     end
  #
  #   end
  #
  #   context '#building' do
  #
  #     before(:each) do
  #       @project = Project.new
  #       field = build_fake_persisted_field :self_metadata, :label => 'Manager name', :_alias => 'manager', :kind => 'string'
  #       @project.rebuild_custom_fields_relation :self_metadata
  #     end
  #
  #     it 'returns a new document whose Class is different from the original one' do
  #       @project.self_metadata.class.should_not == CustomFields::SelfMetadata
  #     end
  #
  #     it 'returns a new document with custom field' do
  #       @project.self_metadata.respond_to?(:manager).should be_true
  #     end
  #
  #     it 'sets/gets custom attributes' do
  #       @project.self_metadata.manager = 'Mr Harrison'
  #       @project.self_metadata.manager.should == 'Mr Harrison'
  #     end
  #
  #     it 'does not modify other class instances' do
  #       @other_project = Project.new
  #       @other_project.self_metadata.respond_to?(:manager).should be_false
  #     end
  #
  #   end
  #
  # end
  #
  # def build_fake_persisted_field(name, attributes)
  #   @project.send(:"#{name}_custom_fields").build(attributes).tap do |field|
  #     field.stubs(:persisted?).returns(true)
  #   end
  # end

end