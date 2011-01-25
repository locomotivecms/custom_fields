require 'spec_helper'

describe CustomFields::CustomFieldsFor do

  describe 'Saving' do

    before(:each) do
      puts "===================================================================================================="
      @project = Project.new(:name => 'Locomotive')
      @project.person_custom_fields.build(:label => 'E-mail', :_alias => 'email', :kind => 'string')
      @project.person_custom_fields.build(:label => 'Age', :_alias => 'age', :kind => 'string')

      puts "======> METADATA = #{@project._metadata.inspect}"

      @project.self_custom_fields.build(:label => 'Name of the manager', :_alias => 'manager', :kind => 'string')
      @project.self_custom_fields.build(:label => 'Working hours', :_alias => 'hours', :kind => 'string')
      @project.self_custom_fields.build(:label => 'Room', :kind => 'string')
    end

    context '@create' do

      it 'persists parent object' do
        lambda { @project.save }.should change(Project, :count).by(1)
      end

      it 'persists custom fields for collection' do
        # puts "@foo = #{@foo.inspect}";
        # puts "first = #{@project.person_custom_fields.first.inspect}"
        # puts "reflected = #{@project.person_custom_fields.first.project.inspect}"
        # puts "counter = #{@project.person_custom_fields_counter.inspect}"

        # @project.save
        # puts "\n<==== saved\n"
        # @project.reload
        # puts "\n<==== reloaded\n"

        # puts "counter = #{@project.person_custom_fields_counter.inspect}"

        # puts "first = #{@project.person_custom_fields.first.inspect}"
        # puts "reflected = #{@project.person_custom_fields.first.project.inspect}"
        # puts "counter = #{@project.person_custom_fields_counter.inspect}"

        @project.save && @project.reload
        @project.person_custom_fields.count.should == 2
      end

      # it 'persists custom fields for metadata' do
      #   @project.save && @project.reload
      #   @project.self_custom_fields.count.should == 3
      # end

    end

  end

end