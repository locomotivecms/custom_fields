module CustomFields
  module Validators
    class EmailAddressValidator < ActiveModel::Validator
      EMAIL_REGEXP = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
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
        input_email = r[f]
        e = EmailAddress.new(input_email, host_validation: :syntax, local_format: :standard)
        return r.errors.add(f, :invalid) unless e.valid?
        
        # double check for trailing spaces and unicodes
        return r.errors.add(f, :invalid) unless input_email.match(EMAIL_REGEXP)
      end
    end
  end
end