describe CustomFields::Types::Money do

  before(:each) do
    @blog  = build_blog
    @post  = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @money = Money.parse 'EUR 5,95'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  context 'allow_currency_from_symbol' do

    it 'returns the currency symbol' do
      @post.donation = '10'

      expect(@post.formatted_donation).to eq '€10'
    end

    it 'accepts another currency' do
      @post.donation = '5.95 USD'

      expect(@post.formatted_donation).to eq '$5.95'
    end

  end

  context 'no allow_currency_from_symbol' do

    it 'returns no currency symbol' do
      @post.donation2 = '10'

      expect(@post.formatted_donation2).to eq '10'
    end

  end

  describe 'validation' do

    context 'when field required' do

      [nil,''].each do |value|
        it "should not be valid if the value is #{value.inspect}" do
          @post.donation = value

          expect(@post.valid?).to eq false
          expect(@post.errors[:donation]).not_to be_blank
        end
      end

    end

  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Amount Donation', type: 'money', name: 'donation', required: true
      field.default_currency = 'EUR'
      field.allow_currency_from_symbol = true

      field2 = blog.posts_custom_fields.build label: 'Amount Donation2', type: 'money', name: 'donation2'
      field2.default_currency = 'AUD'
      field2.allow_currency_from_symbol = false
    end
  end

end