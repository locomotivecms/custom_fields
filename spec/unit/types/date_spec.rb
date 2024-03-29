# frozen_string_literal: true

describe CustomFields::Types::Date do
  before(:each) do
    @blog = build_blog
    @post = @blog.posts.build title: 'Hello world', body: 'Lorem ipsum...'
    @date = Date.parse '2010-06-29'
  end

  it 'is not considered as a relationship field type' do
    expect(@blog.posts_custom_fields.first.is_relationship?).to be false
  end

  it 'sets value (in French format) from a string' do
    I18n.stubs(:t).returns('%d/%m/%Y')

    @post.posted_at = '29/06/2010'

    expect(@post.formatted_posted_at).to eq '29/06/2010'
    expect(@post.posted_at).to eq @date
  end

  it 'sets value (in French format) from the formatted_<date> accessor' do
    I18n.stubs(:t).returns('%d/%m/%Y')

    @post.formatted_posted_at = '29/06/2010'

    expect(@post.posted_at).to eq @date
  end

  it 'sets value from the standard format (YYYY/MM/DD)' do
    I18n.stubs(:t).returns('%d/%m/%Y')

    @post.formatted_posted_at = '2010/06/29'

    expect(@post.posted_at).to eq @date
  end

  it 'sets value from a ambiguous date format' do
    I18n.stubs(:t).returns('%m/%d/%Y')

    @post.formatted_posted_at = '01/04/2013'

    expect(@post.posted_at).to eq Date.parse('2013-01-04')
  end

  it 'sets nil from an invalid string' do
    I18n.stubs(:t).returns('%d/%m/%Y')

    @post.formatted_posted_at = '1234'

    expect(@post.posted_at).to be_nil
  end

  it 'sets nil value' do
    @post.posted_at = nil

    expect(@post.posted_at).to be_nil
  end

  it 'sets empty value' do
    @post.posted_at = ''

    expect(@post.posted_at).to be_nil
  end

  context '#localize' do
    before(:each) do
      field = @blog.posts_custom_fields.build label: 'Visible at', type: 'date', localized: true

      field.valid?

      @blog.bump_custom_fields_version :posts
    end

    it 'serializes / deserializes' do
      post = @blog.posts.build visible_at: @date

      expect(post.visible_at).to eq @date
    end

    it 'serializes / deserializes in a different locale' do
      post = @blog.posts.build visible_at: @date

      Mongoid::Fields::I18n.locale = :fr

      post.visible_at = '16/09/2010'

      expect(post.visible_at_translations['fr']).to eq Date.parse '2010/09/16'
    end
  end

  describe 'getter and setter' do
    it 'returns an empty hash if no value has been set' do
      expected = {}

      expect(@post.class.date_attribute_get(@post, 'posted_at')).to eq expected
    end

    it 'returns the value' do
      @post.posted_at = Date.parse '2010-06-29'

      expected = {
        'posted_at' => '2010-06-29',
        'formatted_posted_at' => '2010-06-29'
      }

      expect(@post.class.date_attribute_get(@post, 'posted_at')).to eq expected
    end

    it 'sets a nil value' do
      expect(@post.class.date_attribute_set(@post, 'posted_at', {})).to be_nil
    end

    it 'sets a value' do
      @post.class.date_attribute_set(@post, 'posted_at', { 'posted_at' => '2010-06-28' })

      expect(@post.posted_at).to eq Date.parse '2010-06-28'

      @post.class.date_attribute_set(@post, 'posted_at', { 'formatted_posted_at' => '2010-06-29' })

      expect(@post.posted_at).to eq Date.parse '2010-06-29'
    end
  end

  protected

  def build_blog
    Blog.new(name: 'My personal blog').tap do |blog|
      field = blog.posts_custom_fields.build label: 'Posted at', type: 'date'

      field.valid?
    end
  end
end
