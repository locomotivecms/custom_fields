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
      @project = build_project
      @date = Date.parse('2010-06-29')
    end

    it 'owns aliases to the getter/setter' do
      @project.self_metadata.respond_to?(:formatted_started_at).should be_true
      @project.self_metadata.respond_to?(:formatted_started_at=).should be_true
    end

    it 'sets value from a date' do
      @project.self_metadata.started_at = @date
      @project.self_metadata.formatted_started_at.should == '2010-06-29'
      @project.self_metadata.started_at.should == @date
      @project.self_metadata.field_1.class.should == Date
      @project.self_metadata.field_1.should == @date
    end

    it 'sets value from a string' do
      @project.self_metadata.started_at = '2010-06-29'
      @project.self_metadata.formatted_started_at.class.should == String
      @project.self_metadata.formatted_started_at.should == '2010-06-29'
      @project.self_metadata.field_1.class.should == Date
      @project.self_metadata.field_1.should == @date
    end

    it 'sets value (in French format) from a string' do
      I18n.stubs(:t).returns('%d/%m/%Y')
      @project.self_metadata.started_at = '29/06/2010'
      @project.self_metadata.formatted_started_at.should == '29/06/2010'
      @project.self_metadata.field_1.should == @date
    end

    it 'sets nil value' do
      @project.self_metadata.started_at = nil
      @project.self_metadata.started_at.should be_nil
      @project.self_metadata.field_1.should be_nil
    end

    it 'sets empty value' do
      @project.self_metadata.started_at = ''
      @project.self_metadata.started_at.should be_nil
      @project.self_metadata.field_1.should be_nil
    end

  end

  def build_project
    Project.new.tap do |project|
      project.self_metadata_custom_fields.build(:label => 'Started at', :kind => 'Date', :_name => 'field_1').tap do |field|
        field.stubs(:persisted?).returns(true)
      end
      project.rebuild_custom_fields_relation :self_metadata
    end
  end

end