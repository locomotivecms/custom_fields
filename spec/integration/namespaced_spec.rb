require 'spec_helper'

describe 'Namespaced models' do
  let(:parent) { Namespaced::Parent.new }

  it 'correctly loads up the association' do
    parent.children.be_blank
  end

  it 'allows access to the custom fields' do
    parent.children_custom_fields.be_blank
  end

  it 'allows custom fields to be build' do
    parent.children_custom_fields.build(:label => 'Test', :kind => 'string')
    parent.save!
  end
end
