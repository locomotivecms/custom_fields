require 'spec_helper'

describe CustomFields::Types::HasOne do

  context 'on field class' do

    before(:each) do
      @field = CustomFields::Field.new
    end

    it 'returns true if it is a HasOne' do
      @field.kind = 'has_one'
      @field.has_one?.should be_true
    end

    it 'returns false if it is not a HasOne' do
      @field.kind = 'string'
      @field.has_one?.should be_false
    end

  end

end