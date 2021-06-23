module Binance
  class Savings < Exchange
    API_URI = "https://api.binance.com/sapi/v1/lending/union/account"

    def parse
      data["positionAmountVos"].reject do |balance|
        balance["amount"].to_f == 0
      end.map do |balance|
        { balance["asset"] => balance["amount"].to_f }
      end
    rescue
      []
    end

    private

    def get_from_api(api_key, secret_key)
      Utils.binance_http_get(API_URI, api_key, secret_key)
    end
  end
end
