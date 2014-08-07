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
      @blog.custom_fields_for?(:posts).should be true
    end

  end

end