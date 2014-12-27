describe CustomFields::TargetHelpers do

  before(:each) do
    @post = build_post_with_rules
  end

  context '#grouping fields' do

    it 'returns empty arrays if no rules' do
      @post.stubs(:custom_fields_recipe).returns({ 'rules' => [] })

      expect(@post.select_custom_fields).to be_empty
      expect(@post.file_custom_fields).to be_empty
      expect(@post.has_many_custom_fields).to be_empty
      expect(@post.many_to_many_custom_fields).to be_empty
    end

    it 'groups select fields' do
      expect(@post.select_custom_fields).to eq %w[category]
    end

    it 'groups file fields' do
      expect(@post.file_custom_fields).to eq %w[illustration author_picture]
    end

    it 'groups has_many fields including the inverse_of property' do
      expect(@post.has_many_custom_fields).to eq [%w[projects project], %w[illustrations project]]
    end

    it 'groups many_to_many fields including the field name to get the target ids' do
      expect(@post.many_to_many_custom_fields).to eq [%w[contributors contributor_ids]]
    end

  end

  context '#returning safe setters' do

    before(:each) do
      @names = @post.custom_fields_safe_setters
    end

    it 'includes setters for string' do
      expect(@names.include?('author_name')).to be true
    end

    it 'includes setters for boolean' do
      expect(@names.include?('visible')).to be true
    end

    it 'includes setters for integer' do
      expect(@names.include?('int_count')).to be true
    end

    it 'includes setters for float' do
      expect(@names.include?('float_count')).to be true
    end

    it 'includes setters for money' do
      expect(@names.include?('formatted_donation')).to be true
    end

    it 'includes setters for date' do
      expect(@names.include?('formatted_posted_at')).to be true
    end

    it 'includes setters for file' do
      expect(@names.include?('illustration')).to be true
      expect(@names.include?('remove_illustration')).to be true
    end

    it 'includes setters for select' do
      expect(@names.include?('category_id')).to be true
      expect(@names.include?('category')).to be false
    end

    it 'includes setters for integer' do
      expect(@names.include?('int_count')).to be true
      expect(@names.include?('remove_int_count')).to be false
    end

    it 'includes setters for float' do
      expect(@names.include?('float_count')).to be true
      expect(@names.include?('remove_float_count')).to be false
    end

    it 'includes setters for belongs_to' do
      expect(@names.include?('ghost_writer_id')).to be true
      expect(@names.include?('position_in_ghost_writer')).to be true
      expect(@names.include?('ghost_writer')).to be false
    end

    it 'does not include setters for has_many and many_to_many' do
      expect(@names.include?('contributors')).to be false
      expect(@names.include?('projects')).to be false
    end

  end

  context '#returning basic attributes' do

    before(:each) do
      %w[
        category formatted_posted_at visible author_name illustration?
        author_picture? int_count float_count formatted_donation
      ].each do |meth|
        @post.stubs(meth.to_sym).returns(nil)
      end
    end

    it 'calls the getter for string' do
      @post.class.expects(:string_attribute_get).with(@post, 'author_name').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for integer' do
      @post.class.expects(:integer_attribute_get).with(@post, 'int_count').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for float' do
      @post.class.expects(:float_attribute_get).with(@post, 'float_count').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for money' do
      @post.class.expects(:money_attribute_get).with(@post, 'donation').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for boolean' do
      @post.class.expects(:boolean_attribute_get).with(@post, 'visible').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for date' do
      @post.class.expects(:date_attribute_get).with(@post, 'posted_at').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for file' do
      @post.class.expects(:file_attribute_get).once.with(@post, 'illustration').returns({})
      @post.class.expects(:file_attribute_get).once.with(@post, 'author_picture').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'calls the getter for select' do
      @post.class.expects(:select_attribute_get).with(@post, 'category').returns({})
      @post.custom_fields_basic_attributes
    end

    it 'does not call the getter for belongs_to, has_many and many_to_many' do
      @post.class.expects(:belongs_to_attribute_get).never
      @post.class.expects(:has_many_attribute_get).never
      @post.class.expects(:many_to_many_attribute_get).never
      @post.custom_fields_basic_attributes
    end

  end

  context '#setting basic attributes' do

    before(:each) do
      %w[
        category= formatted_posted_at= visible=
        author_name= int_count= float_count= money=
      ].each do |meth|
        @post.stubs(meth.to_sym).returns(nil)
      end
    end

    it 'calls the setter for string' do
      @post.class.expects(:string_attribute_set).with(@post, 'author_name', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for boolean' do
      @post.class.expects(:boolean_attribute_set).with(@post, 'visible', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for integer' do
      @post.class.expects(:integer_attribute_set).with(@post, 'int_count', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for float' do
      @post.class.expects(:float_attribute_set).with(@post, 'float_count', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for money' do
      @post.class.expects(:money_attribute_set).with(@post, 'donation', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for date' do
      @post.class.expects(:date_attribute_set).with(@post, 'posted_at', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for file' do
      @post.class.expects(:file_attribute_set).once.with(@post, 'illustration', {}).returns({})
      @post.class.expects(:file_attribute_set).once.with(@post, 'author_picture', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'calls the setter for select' do
      @post.class.expects(:select_attribute_set).with(@post, 'category', {}).returns({})
      @post.custom_fields_basic_attributes = {}
    end

    it 'does not call the setter for belongs_to, has_many and many_to_many' do
      @post.class.expects(:belongs_to_attribute_set).never
      @post.class.expects(:has_many_attribute_set).never
      @post.class.expects(:many_to_many_attribute_set).never
      @post.custom_fields_basic_attributes = {}
    end

  end

  context '#returning methods' do

    before(:each) do
      @methods = @post.custom_fields_methods
    end

    it 'includes the default method name for string, select, boolean, integer, float, has_many and many_to_many fields' do
      %w[
        author_name category visible projects illustrations
        contributors int_count float_count
      ].each do |name|
        expect(@methods.include?(name)).to be true
      end
    end

    it 'also includes another method name for select (<name>_id)' do
      expect(@methods.include?('category_id')).to be true
    end

    it 'includes the method name for files' do
      expect(@methods.include?('illustration_url')).to be true
      expect(@methods.include?('illustration')).to be false
      expect(@methods.include?('author_picture_url')).to be true
      expect(@methods.include?('author_picture')).to be false
    end

    it 'includes the method name for dates' do
      expect(@methods.include?('formatted_posted_at')).to be true
      expect(@methods.include?('posted_at')).to be false
    end

    it 'includes the method name for money' do
      expect(@methods.include?('formatted_donation')).to be true
      expect(@methods.include?('donation')).to be false
    end

    it 'includes the method name for belongs_to relationships' do
      expect(@methods.include?('formatted_posted_at')).to be true
      expect(@methods.include?('posted_at')).to be false
    end

    it 'includes the method name for the has_many and many_to_many relationships' do
      %w[contributors projects illustrations].each do |name|
        expect(@methods.include?(name)).to be true
      end
    end

    it 'filters the list by passing a block' do
      block = @post.custom_fields_methods do |rules|
        %w[string boolean integer float].include?(rules['type'])
      end

      expect(block).to eq %w[visible author_name int_count float_count]
    end

  end

  protected

  def build_post_with_rules
    Post.new(title: 'Hello world').tap do |post|
      post.stubs(:custom_fields_recipe).returns({
        'rules' => [
          { 'name' => 'category',       'type' => 'select', 'required' => false, 'localized' => false },
          { 'name' => 'posted_at',      'type' => 'date', 'required' => false, 'localized' => false },
          { 'name' => 'visible',        'type' => 'boolean', 'required' => false, 'localized' => false },
          { 'name' => 'ghost_writer',   'type' => 'belongs_to', class_name: 'Person', 'required' => false, 'localized' => false },
          { 'name' => 'illustration',   'type' => 'file', 'required' => false, 'localized' => false },
          { 'name' => 'author_name',    'type' => 'string', 'required' => false, 'localized' => false },
          { 'name' => 'author_picture', 'type' => 'file', 'required' => false, 'localized' => false },
          { 'name' => 'contributors',   'type' => 'many_to_many', 'class_name' => 'Person', 'inverse_of' => 'posts', 'required' => false, 'localized' => false },
          { 'name' => 'projects',       'type' => 'has_many', 'class_name' => 'Project', 'inverse_of' => 'project', 'required' => false, 'localized' => false },
          { 'name' => 'illustrations',  'type' => 'has_many', 'class_name' => 'PostImage', 'inverse_of' => 'project', 'required' => false, 'localized' => false },
          { 'name' => 'int_count',      'type' => 'integer', 'required' => false, 'localized' => false },
          { 'name' => 'float_count',    'type' => 'float', 'required' => false, 'localized' => false },
          { 'name' => 'donation',       'type' => 'money', 'required' => false, 'localized' => false },
        ]
      })
    end
  end

end