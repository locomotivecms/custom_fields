# frozen_string_literal: true

describe 'CustomFieldsFor' do
  describe 'helpers' do
    before(:each) do
      @blog = Blog.new
    end

    it 'keeps track of all the associations enhanced by the custom fields' do
      expect(@blog._custom_fields_for).not_to be_empty
    end

    it 'tells if an association is enhanced by the custom fields' do
      expect(@blog.custom_fields_for?(:posts)).to be true
    end
  end
end
