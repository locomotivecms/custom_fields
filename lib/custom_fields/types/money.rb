module CustomFields
  module Types
    module Money

      module Field
        extend ActiveSupport::Concern

        included do
          # allow_currency_from_symbol means that the user is able
          # to provide another currency instead of the the default
          # e.g. default is 'EUR' and User sets '100.11 USD'
          field :default_currency
          field :allow_currency_from_symbol, type: ::Boolean, default: false

          before_validation :set_default

          protected

          def set_default
            self.default_currency ||= CustomFields.options[:default_currency]
          end

          def check_currency
            ::Money::Currency.find( self.default_currency )
          end

        end # included

        def money_to_recipe
          { 'default_currency' => self.default_currency,
            'allow_currency_from_symbol' => self.allow_currency_from_symbol }
        end

        def money_as_json(options = {})
          money_to_recipe
        end

      end # module Field


      module Target
        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a Money field
          #
          # uses the money gem (https://github.com/RubyMoney/money)
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          # if allow_currency_from_symbol is set the formatted_name_field will return the amount
          # and the currency

          def apply_money_custom_field(klass, rule)

            # the field names
            name = rule['name']
            names = {
              name:                       name.to_sym,
              cents_field:                "#{name}_cents".to_sym,
              currency_field:             "#{name}_currency".to_sym,
              formatted_name_field:       "formatted_#{name}".to_sym,
              allow_currency_from_symbol: "#{name}_allow_currency_from_symbol".to_sym,
              default_currency:           "#{name}_default_currency".to_sym
            }

            # fields
            klass.field names[:cents_field],    type: ::Integer, localize: false
            klass.field names[:currency_field], type: ::String,  localize: false

            # getters and setters
            klass.send( :define_method, name ) { _get_money(names) }
            klass.send( :define_method, :"#{name}=" ) { |value| _set_money(value, names) }

            klass.send( :define_method, names[:formatted_name_field] ) { _get_formatted_money(names) }
            klass.send( :define_method, :"#{names[:formatted_name_field]}=" ) { |value| _set_money(value, names) }

            klass.send( :define_method, names[:allow_currency_from_symbol] ) { rule['allow_currency_from_symbol'] }
            klass.send( :define_method, names[:default_currency] ) { rule['default_currency'] }

            # validations
            klass.validate { _check_money( names ) }  if rule['required']
            klass.validates_presence_of( names[:cents_field], names[:currency_field] ) if rule['required']
            klass.validates_numericality_of names[:cents_field], only_integer: true, if: names[:cents_field]

          end

          def money_attribute_get(instance, name)
            if value = instance.send(:"formatted_#{name}")
              { name => value, "formatted_#{name}" => value }
            else
              {}
            end
          end

         def money_attribute_set(instance, name, attributes)
            return unless attributes.key?(name) || attributes.key?("formatted_#{name}")
            value = attributes[name] || attributes["formatted_#{name}"]
            instance.send(:"formatted_#{name}=", value)
          end


        end

        protected

        def _set_money_defaults( names )
          ::Money.assume_from_symbol = self.send( names[:allow_currency_from_symbol] )
          ::Money.default_currency = self.send( names[:default_currency] )
        end

        def _get_money( names )
          _set_money_defaults( names )
          ::Money.new( self.read_attribute( names[:cents_field] ), self.read_attribute( names[:currency_field] ) || ::Money.default_currency )
        end

        def _check_money( names )
          if [nil, ''].include? self.read_attribute.names[:cents_field]
            raise ArgumentError.new 'Unrecognized amount'
          end
          _get_money( names )
        rescue
          self.errors.add( names[:name], "#{$!}" )
          false
        end

        def _set_money( _money, names )
          return if _money.blank?
          _set_money_defaults( names )
          money = _money.kind_of?( Money ) ? _money : ::Money.parse( _money )
          self.write_attribute( names[:cents_field], money.cents )
          self.write_attribute( names[:currency_field], money.currency.iso_code )
        rescue
          self.errors.add( names[:name], "#{$!}" )
        end

        def _get_formatted_money( names )
          _get_money( names ).format( symbol: self.send( names[:allow_currency_from_symbol] ), no_cents_if_whole: true ) rescue nil
        end

      end
    end
  end
end
