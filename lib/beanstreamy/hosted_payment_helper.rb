module Beanstreamy
  module HostedPaymentHelper

    mattr_accessor :config
    @@config = Beanstreamy.config

    def beanstream_hosted_payment_form(options = {}, &block)

      order_id = options.delete(:order_id) or raise("Missing order id")
      amount = options.delete(:amount) or raise("Missing amount")
      merchant_id = options.delete(:merchant_id) || config.merchant_id
      hash_key = options.delete(:hash_key) || config.hash_key
      approved_url = options.delete(:approved_url) || config.approved_url
      declined_url = options.delete(:declined_url) || config.declined_url
      error_url = options.delete(:error_url)

      skip_hash = options.delete(:skip_hash)
      extra_params = options.delete(:params)

      hashed_params = [["merchant_id", merchant_id],
                       ["trnOrderNumber", order_id],
                       ["trnAmount", amount]]
      hashed_params << ["approvedPage", approved_url] if approved_url.present?
      hashed_params << ["declinedPage", declined_url] if declined_url.present?
      hashed_params << ["errorPage", error_url] if error_url.present?

      if expire_at = options.delete(:expire_at)
        hashed_params << ["hashExpiry", Util.hash_expiry(expire_at)]
      end

      hashed_params += Array(extra_params)

      form = content_tag(:form, options.merge(:action => config.payment_url, :method => "post")) do
        hashed_params.each do |key, value|
          concat hidden_field_tag(key, value)
        end

        hash_value = nil
        if hash_key.present? && !skip_hash
          # Beansream's hosted page uses hash validation to prevent price modification. This hash is computed from
          # the url encoded string of the above inputs
          query_string = hashed_params.reject { |k,v| v.blank? }.map { |k,v| v.to_query(k) }.join('&')
          hash_value = Util.hash_value(hash_key, query_string)

          concat hidden_field_tag("hashValue", hash_value)
        end

        block.call(:hash_value => hash_value, :query_string => query_string)
      end

      concat form
    end
  end
end
