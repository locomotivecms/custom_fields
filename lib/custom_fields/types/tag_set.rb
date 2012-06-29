module CustomFields

  module Types

    module TagSet
      
      class Tag

        include Mongoid::Document

        field :name,      :localize => true
        field :_id,       :type => BSON::ObjectId, :localize => false
        
        validates_presence_of :name
        validates_uniqueness_of :name, :_id

        def as_json(options = nil)
          super :methods => %w(_id name)
        end
        
        
        def self.available_tags
          locale = Mongoid::Fields::I18n.locale.to_s
          
          Tag.all().asc("name.#{locale}".to_sym).to_ary
        end
        
        def self.find_tag_by_name(tag_name, locale = Mongoid::Fields::I18n.locale.to_s)
          Tag.where("name.#{locale}" => /^#{tag_name.strip}$/i ).first
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
           available_tags
        end
        
        def available_tags
           Tag.available_tags
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
            
            inverse_name ="#{klass.to_s.sub('::', '_')}_#{name}"
            raw_name = "raw_#{name}"
            
            
            Tag.has_and_belongs_to_many inverse_name, :class_name => klass.to_s, :inverse_of => raw_name
            
            klass.has_and_belongs_to_many raw_name, :class_name => "CustomFields::Types::TagSet::Tag", :inverse_of =>  inverse_name
            
            # other methods
            klass.send(:define_method, name.to_sym) { _get_tags(name) }
            klass.send(:define_method, :"#{name}=") { |value| _set_tags(name, value) }
            klass.class_eval("alias :#{name.singularize}_ids :raw_#{name.singularize}_ids")
            klass.class_eval("alias :#{name.singularize}_ids= :raw_#{name.singularize}_ids=")
            
            
            klass.class_eval <<-EOV

              def self.#{base_collection_name}
                self._available_tags('#{name}')
              end
              
              def self.tag_inverse_relation_#{name}
                "#{inverse_name}"
              end

            EOV
            
            if rule['required']
              klass.validates_length_of name, :minimum => 1
            end
          end

          # Returns a list of documents groups by select values defined in the custom fields recipe
          #
          # @param [ Class ] klass The class to modify
          # @return [ Array ] An array of hashes (keys: select option and related documents)
          #
          def group_by_tag(name, order_by = nil)
            ids_field = "raw_#{name.to_s.singularize}_ids"
            groups = self.only(ids_field.to_sym).group
 
            Tag.available_tags.map do |tag|
              group = groups.select { |g| g[ids_field].include?(tag['_id']) }
              list  = group ? group.collect{|g| g['group'][0]} : []
 
               groups.delete(group) if group
 
               { :name => get_localized_name(tag), :entries => self._order_tagged_entries(list, order_by) }.with_indifferent_access
            end.tap do |array|
              empty_group = groups.select { |g| g[ids_field].empty? }
                 
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
          self.send(:"raw_#{name.singularize}_ids")
        end

        #finds tags based on their names, or create it if it doesn't exist
        def _find_tags(names)
          names.collect{|tag_name| Tag.find_or_create_by(name: tag_name)}
        end

        #gets an array of tag names based on the how the object is tagged
        def _get_tags(field_name)
          _tags_ids(field_name).collect { |id| Tag.where(:_id => id).first.name}
          
        end

        #sets the tags (and makes new ones!) based on the value given.. ?
        def _set_tags(field_name, value)
          if(value.blank?)
            tag_name_array = []
          else
            tag_name_array = value.kind_of?(Array) ? value : value.split(",")
            tag_name_array.map!(&:strip).reject!(&:blank?)
          end
          self.send(:"raw_#{field_name}").clear
          locale = Mongoid::Fields::I18n.locale.to_s
          
          tag_name_array.each do |tag_name|
            tag = Tag.find_tag_by_name(tag_name, locale)
            self.send(:"raw_#{field_name}") << (tag.nil? ? Tag.create(:name => tag_name) : tag)
          end
        end
        
        
      end

    end

  end

end