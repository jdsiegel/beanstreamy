module Beanstreamy
  module HostedPaymentHelper

    mattr_accessor :config
    @@config = Beanstreamy.config

    # Generate a form that will submit payment information to Beanstream's payment gateway 
    # using the http POST method.
    #
    # === Hash Validation
    #
    # It's highly recommended you enable hash validation. Otherwise end-users will be able 
    # to modify any information submitted to Beanstream, including the amount to be charged.
    # You can specify the hash key with the +:hash_key+ option.
    #
    # (*Note*: Currently only SHA1 hashing is supported.)
    #
    # The +amount+ argument is expected to be an +Integer+ in cents, just like in ActiveMerchant.
    #
    # === Options
    #
    # [:merchant_id]
    #   The merchant id of your Beanstream account. This is required. You can specify this in 
    #   the beanstreamy initializer file
    # [:hash_key]
    #   The key used for SHA1 hash validation. You can specify this in the beanstreamy initializer file
    # [:skip_hash]
    #   If +true+, turn off hash validation. Default is +false+.
    # [:approved_url]
    #   The url that beanstream will redirect to for approved transactions
    # [:declined_url]
    #   The url that beanstream will redirect to for declined transactions
    # [:error_url]
    #   The url that beanstream will redirect to when there's validation errors with any of the submitted fields
    # [:options]
    #   A hash of extra gateway parameters such as billing address and subtotals. Uses the same 
    #   format as gateway options in ActiveMerchant. You'll most likely want to specify the +:order_id+ option 
    #   at a minimum.
    #
    # === Example
    #
    # <%= beanstream_hosted_payment_form 3456, :merchant_id => 454353534, :hash_key => "FK49Clk34Jd",
    #                                          :options => {
    #                                            :order_id => "R5564396848",
    #                                            :email => "customer@example.com",
    #                                            :billing_address => {
    #                                              :name => "Reginald DeBillings",
    #                                              :address1 => "15 Over There Rd",
    #                                              :city => "Somecity",
    #                                              :province => "AB",
    #                                              :country => "CA",
    #                                              :postal_code => "T6G1K7"
    #                                            }
    #                                          } %>
    #   # Render fields needed for CC info
    # <% end -%>
    #
    # In this example, it is assumed the billing information has been captured in a previous step. If you wanted to
    # capture both billing information along with the CC info in one step, you would exclude it from the +:options+
    # and render the appropriate fields.
    #
    # === TODO
    #
    # For rendered inputs, you need to specify the exact parameter names that Beanstream 
    # expects (e.g. +trnCardNumber+). There should be some extra helper methods that abstracts these to be
    # similar to the +options+ hash.
    def beanstream_hosted_payment_form(amount, options = {}, &block)
      amount = Util.amount(amount) # convert from cents to dollars

      merchant_id = options.delete(:merchant_id) || config.merchant_id
      hash_key = options.delete(:hash_key) || config.hash_key
      skip_hash = options.delete(:skip_hash)

      approved_url = options.delete(:approved_url) || config.approved_url
      declined_url = options.delete(:declined_url) || config.declined_url
      error_url = options.delete(:error_url)

      gateway_options = options.delete(:options) || {}
      gateway_params = {}
      Util.add_address(gateway_params, gateway_options)
      Util.add_invoice(gateway_params, gateway_options)

      extra_params = options.delete(:params)

      # construct the parameter list
      hashed_params = [["merchant_id", merchant_id],
                       ["trnAmount", amount]]
      hashed_params << ["approvedPage", approved_url] if approved_url.present?
      hashed_params << ["declinedPage", declined_url] if declined_url.present?
      hashed_params << ["errorPage", error_url] if error_url.present?

      if expire_at = options.delete(:expire_at)
        hashed_params << ["hashExpiry", Util.hash_expiry(expire_at)]
      end

      hashed_params += Array(gateway_params)
      hashed_params += Array(extra_params)

      form = content_tag(:form, options.merge(:action => config.payment_url, :method => "post")) do
        hashed_params.each do |key, value|
          concat hidden_field_tag(key, value) if value
        end

        hash_value = nil
        if hash_key.present? && !skip_hash
          # Beansream's hosted page uses hash validation to prevent price modification. This hash is computed from
          # the url encoded string of the above inputs
          query_string = hashed_params.reject { |k,v| !v }.map { |k,v| v.to_query(k) }.join('&')
          hash_value = Util.hash_value(hash_key, query_string)

          concat hidden_field_tag("hashValue", hash_value)
        end

        block.call(:hash_value => hash_value, :query_string => query_string)
      end

      concat form
    end
  end
end
