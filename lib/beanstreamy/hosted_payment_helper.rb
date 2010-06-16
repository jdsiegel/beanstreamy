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

      form = content_tag(:form, options.merge(:action => config.payment_url, :method => "post")) do
        concat hidden_field_tag("merchant_id", merchant_id)
        concat hidden_field_tag("trnOrderNumber", order_id)
        concat hidden_field_tag("trnAmount", amount)
        if approved_url.present?
          concat hidden_field_tag("approvedPage", approved_url)
        end
        if declined_url.present?
          concat hidden_field_tag("declinedPage", declined_url)
        end

        # Beansream's hosted page uses hash validation to prevent price modification. This hash is computed from
        # the url encoded string of the above inputs
        query_params = [
          ["merchant_id", merchant_id],
          ["trnOrderNumber", order_id],
          ["trnAmount", amount],
          ["approvedPage", approved_url],
          ["declinedPage", declined_url]
        ]
        query_string = query_params.reject { |k,v| v.blank? }.map { |k,v| v.to_query(k) }.join('&')
        hash_value = Digest::SHA1.hexdigest(query_string + hash_key)

        concat hidden_field_tag("hashValue", hash_value)

        block.call(:hash_value => hash_value, :query_string => query_string)
      end
      concat form
    end
  end
end
