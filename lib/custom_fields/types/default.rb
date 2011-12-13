module CustomFields
  module Types
    module Default
      extend ActiveSupport::Concern

      module InstanceMethods

        def collect_default_diff(memo)
          if self.persisted?
            if self.destroyed?
              memo['$unset'][self.alias] = 1
            elsif self.changed?
              if self.changes.key?(:alias)
                old_name, new_name = self.changes[:alias]
                memo['$rename'][old_name] = new_name
              end
            end
          else
            memo['$set'][self.alias] = nil
          end

          (memo['$set']['custom_fields_recipe'] ||= []) << self.to_recipe
        end

        # def collect_default_diff
        #   if self.persisted?
        #     if self.changed?
        #
        #       if self.changes.has?(:alias)
        #         self.diff_list << { :action => :rename, :field => self, :changes => self.changes[:alias] }
        #       end
        #
        #       if self.changes.has?(:type)
        #         self.diff_list << { :action => :change_type, :field => self, :changes => self.changes[:type] }
        #       end
        #     end
        #   else
        #     self.diff_list << { :action => :add, :field => self }
        #   end
        # end
        #
        # def diff_to_attributes(memo)
        #   self.diff_list.each do |diff|
        #     puts "#{self.label}...process #{diff[:action]}"
        #
        #     case diff[:action] do
        #     when :add
        #       memo['$set'][self.alias] = nil
        #     else
        #       puts "#{self.label}...unknown #{diff[:action]}"
        #     end
        #   end
        # end

        # def apply_default_diff
        #   self.diff_list.each do |diff|
        #     puts "#{self.label}...process #{diff[:action]}"
        #     case diff[:action] do
        #     when :add then self.add_field(self.alias)
        #     else
        #       puts "#{self.label}...unknown #{diff[:action]}"
        #     end
        #   end
        # end

        # basic operations

        def add_field(name)

        end

      end

      module ClassMethods

      end
    end
  end
end