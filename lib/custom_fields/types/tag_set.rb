module CustomFields

  module Types

    module TagSet
      
      class Tag

        include Mongoid::Document

        field :name,      :localize => true
        field :_id,       :type => BSON::ObjectId, :localize => false
        
       
        validates_presence_of :name
        validates_uniqueness_of :name

        def as_json(options = nil)
          super :methods => %w(_id name)
        end
        
        
        def self.available_tags
          Tag.all().asc(:name).to_ary
        end
        
        
        

      end

      module Field

        extend ActiveSupport::Concern

        included do

       
        end
        
        def tag_class
          Tag
        end

        def ordered_available_tags
           Tag.available_tags
        end
        
        def available_tags
          ordered_available_tags
        end

        def tag_set_to_recipe
          {
            'available_tags' => self.ordered_available_tags.map do |tag|
              { '_id' => tag._id, 'name' => tag.name_translations }
            end
          }
        end

        def tag_set_as_json(options = {})
          { 'available_tags' => self.ordered_available_tags.map(&:as_json) }
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
            name, base_collection_name = rule['name'], "#{rule['name']}_available_tags".to_sym

          
            klass.field :"#{name}_ids", :type => Array, :localize => false, :default=>[] || false

            klass.cattr_accessor "_raw_#{base_collection_name}"
            klass.send :"_raw_#{base_collection_name}=", rule['available_tags']
            
            # other methods
            klass.send(:define_method, name.to_sym) { _get_tags(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_tags(name, value) }
          
            klass.class_eval <<-EOV

              def self.#{base_collection_name}
                self._available_tags('#{name}')
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

            groups_array = _available_tags(name).map do |tag|
              
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

          def _available_tags(name)
            Tag.available_tags.map do |tag|
              tag_name = get_localized_name(tag)
              { '_id' => tag['_id'], 'name' => tag_name }
            end.sort_by{ |x| x['name']}
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
          locale = Mongoid::Fields::I18n.locale.to_s
          
          id_array_or_name_array.each do |id_or_name|
            found = Tag.where({ "name.#{locale}" => /^#{id_or_name}$/i }).first
            if(found.blank?)
              found = Tag.where( _id: id_or_name).first
            end            

            if auto_build and found.blank?
              new_tag = Tag.create!(name: id_or_name)#, _id: BSON::ObjectId.new)
              localized_tag = { '_id' =>new_tag._id, 'name' => id_or_name }
              found_array.append(localized_tag)         
            elsif !found.nil?
              localized_tag = { '_id' =>found._id, 'name' => found.name }
              found_array.append(localized_tag)
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
          if(value.nil?)
            tag_array = []
          else
            tag_array = value.kind_of?(Array) ? value : value.split(",")
            tag_array.map!(&:strip).reject!(&:blank?)
          end
          tags = self._find_tags(name, tag_array, true)
          
          self.send(:"#{name}_ids=", tags ? tags.collect{|tag| tag['_id']} : [])
        end
        
        
      end

    end

  end

end