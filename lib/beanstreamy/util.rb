module Beanstreamy
  module Util
    def self.hash_value(key, message)
      Digest::SHA1.hexdigest(message + key)
    end

    def self.hash_expiry(expire_at)
      # Beanstream uses PST/PDT for all their timestamps. Time stamps only have minute resolution,
      # so the seconds need chopping off.
      expire_at.in_time_zone("Pacific Time (US & Canada)").to_s(:number)[0..-3]
    end
  end
end
