require 'active_merchant/billing/gateways/beanstream'

module Beanstreamy
  module QueryAction
    EXTRA_TRANSACTIONS = { :query => 'Q' }

    CVD_CODES = ActiveMerchant::Billing::BeanstreamCore::CVD_CODES
    AVS_CODES = ActiveMerchant::Billing::BeanstreamCore::AVS_CODES

    def response_from_query(query_string)
      response = parse(query_string)
      build_response(success?(response), message_from(response), response,
        :test => test? || response[:authCode] == "TEST",
        :authorization => authorization_from(response),
        :cvv_result => CVD_CODES[response[:cvdId]],
        :avs_result => { :code => (AVS_CODES.include? response[:avsId]) ? AVS_CODES[response[:avsId]] : response[:avsId] }
      )
    end

    def query(amount, options={})
      requires!(options, :order_id)
      
      post = {}
      add_order_number(post, options[:order_id])
      add_amount(post, amount)
      add_transaction_type(post, :query)
      commit(post)
    end

    private

    def parse(body)
      results = super

      if results[:errorMessage]
        results[:errorMessage].gsub!(/<LI>/, "")
        results[:errorMessage].gsub!(/(\.)?<br>/, ". ")
        results[:errorMessage].strip!
      end

      results
    end

    def add_transaction_type(post, action)
      post[:trnType] = EXTRA_TRANSACTIONS[action] || super
    end

    def add_order_number(post, order_id)
      post[:trnOrderNumber] = order_id
    end
  end

  module HashValidation
    private

    def post_data(params)
      params = super

      hash_key = @options[:hash_key]
      if hash_key
        params += "&hashValue=#{CGI.escape(Util.hash_value(hash_key, params))}"
      end
      params
    end
  end

  ActiveMerchant::Billing::BeanstreamGateway.class_eval do
    include QueryAction
    include HashValidation
  end
end
