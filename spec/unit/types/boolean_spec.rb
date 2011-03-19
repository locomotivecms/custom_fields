require 'spec_helper'

describe CustomFields::Types::Boolean do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'returns true if it is a Boolean' do
      @field.kind = 'boolean'
      @field.boolean?.should be_true
    end

    it 'returns false if it is not a Boolean' do
      @field.kind = 'string'
      @field.boolean?.should be_false
    end

  end

  context 'on target class' do

    before(:each) do
      @project = build_project_with_boolean
    end

    context '#setting' do

      context '#true' do

        it 'sets value from an integer' do
          @project.safe_metadata.active = 1
          @project.safe_metadata.active.should == true
          @project.safe_metadata.field_1.should == '1'
        end

        it 'sets value from a string' do
          @project.safe_metadata.active = '1'
          @project.safe_metadata.active.should == true
          @project.safe_metadata.field_1.should == '1'

          @project.safe_metadata.active = 'true'
          @project.safe_metadata.active.should == true
          @project.safe_metadata.field_1.should == 'true'
        end

      end

      context '#false' do

        it 'sets value from an integer' do
          @project.safe_metadata.active = 0
          @project.safe_metadata.active.should == false
          @project.safe_metadata.field_1.should == '0'
        end

        it 'sets value from a string' do
          @project.safe_metadata.active = '0'
          @project.safe_metadata.active.should == false
          @project.safe_metadata.field_1.should == '0'

          @project.safe_metadata.active = 'false'
          @project.safe_metadata.active.should == false
          @project.safe_metadata.field_1.should == 'false'
        end

      end

    end

  end

  def build_project_with_boolean
    project = Project.new
    project.self_custom_fields.build :label => 'Active', :kind => 'Boolean', :_name => 'field_1'
    project
  end

end