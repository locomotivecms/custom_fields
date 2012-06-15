module CustomFields

  module Types

    module TagSet
      
      class Tag

        include Mongoid::Document

        field :name,      :localize => true
        
        embedded_in :custom_field, :inverse_of => :tags_used

        validates_presence_of :name

        def as_json(options = nil)
          super :methods => %w(_id name)
        end
        

      end

      module Field

        extend ActiveSupport::Concern

        included do

          embeds_many :tags_used, :class_name => 'CustomFields::Types::TagSet::Tag'

          validates_associated :tags_used

          accepts_nested_attributes_for :tags_used, :allow_destroy => true

        end

        def ordered_tags_used
          self.tags_used.sort { |a, b| (a.name) <=> (b.name) }.to_a
        end

        def tag_set_to_recipe
          {
            'tags_used' => self.ordered_tags_used.map do |tag|
              { '_id' => tag._id, 'name' => tag.name_translations }
            end
          }
        end

        def tag_set_as_json(options = {})
          { 'tags_used' => self.ordered_tags_used.map(&:as_json) }
        end

      end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods




        def get_localized_name(tag_hash)
          
          locale = Mongoid::Fields::I18n.locale.to_s
              
          if !tag_hash['name'].respond_to?(:merge)
            tag_hash['name']
          elsif Mongoid::Fields::I18n.fallbacks?
            tag_hash['name'][Mongoid::Fields::I18n.fallbacks[locale.to_sym].map(&:to_s).find { |loc| !tag_hash['name'][loc].nil? }]
          else
            tag_hash['name'][locale.to_s]
          end
        end

          # Adds a tags field
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_tag_set_custom_field(klass, rule)
            name, base_collection_name = rule['name'], "#{rule['name']}_tags_used".to_sym

            klass.field :"#{name}_ids", :type => Array, :localize => rule['localized'], default: [] || false

            klass.cattr_accessor "_raw_#{base_collection_name}"
            
            klass.send :"_raw_#{base_collection_name}=", rule['tags_used'].sort  {|a, b| klass.get_localized_name(a) <=> klass.get_localized_name(b) }
              
            
            # other methods
            klass.send(:define_method, name.to_sym) { _get_tags(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_tags(name, value) }
          
            klass.class_eval <<-EOV

              def self.#{base_collection_name}
                self._tags_used('#{name}')
              end

            EOV

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Returns a list of documents groups by select values defined in the custom fields recipe
          #
          # @param [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: select option and related documents)
          #
          def group_by_tag(name, order_by = nil)
            groups = self.only(:"#{name}_ids").group

            _tags_used(name).map do |tag|
              group = groups.select { |g| g["#{name}_ids"].include?(tag['_id']) }
              
              list  = group ? group.collect{|g| g['group'][0]} : []

              groups.delete(group) if group

              { :name => tag['name'], :entries => self._order_tagged_entries(list, order_by) }.with_indifferent_access
            end.tap do |array|
              empty_group = groups.select { |g| g["#{name}_ids"].empty? }
                
              if not empty_group.empty? # orphan entries ?
                empty = { :name => nil, :entries => [] }.with_indifferent_access
                list  = empty_group.collect{|g| g['group'][0]}
                empty[:entries] = self._order_tagged_entries(list, order_by)
                array << empty
              end
            end
          end

          def _tags_used(name)
            self.send(:"_raw_#{name}_tags_used").map do |tag|

        
              name = get_localized_name(tag)
      
              { '_id' => tag['_id'], 'name' => name }
            end
          end

          def _order_tagged_entries(list, order_by = nil)
            return list if order_by.nil?

            column, direction = order_by.flatten

            list = list.sort { |a, b| (a.send(column) && b.send(column)) ? (a.send(column) || 0) <=> (b.send(column) || 0) : 0 }

            direction == 'asc' ? list : list.reverse

            list
          end

        end

        def _tags_ids(name)
          self.send(:"#{name}_ids")
        end

        #finds tags based on their ids or names
        def _find_tags(name, id_array_or_name_array, auto_build = false)
          found_array = []
          id_array_or_name_array.each do |id_or_name|
            found = self.class._tags_used(name).detect{|tag| tag['_id'] == id_or_name || tag['name'] == id_or_name}
            if auto_build and found.blank?
              locale = Mongoid::Fields::I18n.locale.to_s
          
              tag_hash = { '_id' => BSON::ObjectId.new, 'name' => {locale => id_or_name} }
              self._raw_topics_tags_used.append(tag_hash)     
              localized_tag = { '_id' =>tag_hash['_id'], 'name' => id_or_name }
              found_array.append(localized_tag)         
            elsif !found.nil?
              
              found_array.append(found)
            else
              debugger
            end
          end
          found_array
        end

        #gets an array of tags based on the how the object is tagged
        def _get_tags(name)
          tag_list = self._find_tags(name, self._tags_ids(name))
          
          !tag_list.empty? ? tag_list.collect{|tag| tag['name']} : ""
        end

        #sets the tags (and makes new ones!) based on the value given.. ?
        def _set_tags(name, value)
          tag_array = value.split(",")
          tag_array.map!(&:strip).map!(&:downcase)
          tags = self._find_tags(name, tag_array, true)
          self.send(:"#{name}_ids=", tags ? tags.collect{|tag| tag['_id']} : [])
        end
        
        
        
       
 
      end

    end

  end

end