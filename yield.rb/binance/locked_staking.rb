module Binance
  class LockedStaking < Exchange
    API_URI = "https://api.binance.com/sapi/v1/staking/position"

    def parse
      data.map do |balance|
        { balance["asset"] => balance["amount"].to_f }
      end
    end

    private

    def get_from_api(api_key, secret_key)
      Utils.binance_http_get(API_URI, api_key, secret_key, "product=STAKING")
    end
  end
end
