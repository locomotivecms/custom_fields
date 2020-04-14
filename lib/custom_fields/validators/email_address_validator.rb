module CustomFields
  module Validators
    class EmailAddressValidator < ActiveModel::Validator
      def initialize(options={})
        @opt = options
      end

      def validate(r)
        if @opt[:fields]
          @opt[:fields].each {|f| validate_email(r, f) }
        elsif @opt[:field]
          validate_email(r, @opt[:field])
        elsif r.respond_to? :email
          validate_email(r, :email)
        elsif r.respond_to? :email_address
          validate_email(r, :email_address)
        end
      end

      def validate_email(r,f)
        return if r[f].blank?
        e = EmailAddress.new(r[f], host_validation: :syntax, local_format: :standard)
        unless e.valid?
          r.errors.add(f, :invalid)
        end
      end
    end
  end
end