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

end