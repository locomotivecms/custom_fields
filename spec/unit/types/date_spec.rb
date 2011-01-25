require 'spec_helper'

describe CustomFields::Types::Date do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'returns true if it is a Date' do
      @field.kind = 'Date'
      @field.date?.should be_true
    end

    it 'returns false if it is not a Date' do
      @field.kind = 'string'
      @field.date?.should be_false
    end

  end

  context 'on target class' do

    before(:each) do
      @project = build_project_with_date
      @date = Date.parse('2010-06-29')
    end

    it 'sets value from a date' do
      @project.metadata.started_at = @date
      @project.metadata.started_at.should == '2010-06-29'
      @project.metadata.field_1.class.should == Date
      @project.metadata.field_1.should == @date
    end

    it 'sets value from a string' do
      @project.metadata.started_at = '2010-06-29'
      @project.metadata.started_at.class.should == String
      @project.metadata.started_at.should == '2010-06-29'
      @project.metadata.field_1.class.should == Date
      @project.metadata.field_1.should == @date
    end

    it 'sets nil value' do
      @project.metadata.started_at = nil
      @project.metadata.started_at.should be_nil
      @project.metadata.field_1.should be_nil
    end

  end

  def build_project_with_date
    project = Project.new
    project.self_custom_fields.build :label => 'Started at', :kind => 'Date', :_name => 'field_1'
    project
  end

end