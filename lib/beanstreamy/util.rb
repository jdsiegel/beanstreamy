module Beanstreamy
  module Util

    def self.hash_value(key, message)
      Digest::SHA1.hexdigest(message + key)
    end

    def self.amount(cents)
      sprintf("%.2f", cents.to_f / 100)
    end

    def self.hash_expiry(expire_at)
      # Beanstream uses PST/PDT for all their timestamps. Time stamps only have minute resolution,
      # so the seconds need chopping off.
      expire_at.in_time_zone("Pacific Time (US & Canada)").to_s(:number)[0..-3]
    end

    def self.add_address(params, options)
      prepare_address_for_non_american_countries(options)
      
      if billing_address = options[:billing_address] || options[:address]
        params[:ordName]          = billing_address[:name]
        params[:ordEmailAddress]  = options[:email]
        params[:ordPhoneNumber]   = billing_address[:phone]
        params[:ordAddress1]      = billing_address[:address1]
        params[:ordAddress2]      = billing_address[:address2]
        params[:ordCity]          = billing_address[:city]
        params[:ordProvince]      = billing_address[:province]    || billing_address[:state]
        params[:ordPostalCode]    = billing_address[:postal_code] || billing_address[:zip]
        params[:ordCountry]       = billing_address[:country]
      end

      if shipping_address = options[:shipping_address]
        params[:shipName]         = shipping_address[:name]
        params[:shipEmailAddress] = options[:email]
        params[:shipPhoneNumber]  = shipping_address[:phone]
        params[:shipAddress1]     = shipping_address[:address1]
        params[:shipAddress2]     = shipping_address[:address2]
        params[:shipCity]         = shipping_address[:city]
        params[:shipProvince]     = shipping_address[:province]    || shipping_address[:state]
        params[:shipPostalCode]   = shipping_address[:postal_code] || shipping_address[:zip]
        params[:shipCountry]      = shipping_address[:country]
        params[:shippingMethod]   = shipping_address[:shipping_method]
        params[:deliveryEstimate] = shipping_address[:delivery_estimate]
      end
    end

    def self.prepare_address_for_non_american_countries(options)
      [ options[:billing_address], options[:shipping_address] ].compact.each do |address|
        unless ['US', 'CA'].include?(address[:country])
          address[:province] = '--'
          address[:postal_code]   = '000000' unless address[:postal_code] || address[:zip]
        end
      end
    end

    def self.add_invoice(params, options)
      params[:trnOrderNumber]   = options[:order_id]
      params[:trnComments]      = options[:description]
      params[:ordItemPrice]     = amount(options[:subtotal])
      params[:ordShippingPrice] = amount(options[:shipping])
      params[:ordTax1Price]     = amount(options[:tax1] || options[:tax])
      params[:ordTax2Price]     = amount(options[:tax2])
      params[:ref1]             = options[:custom]
    end
  end
end
