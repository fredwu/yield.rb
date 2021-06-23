module Binance
  class Spot < Exchange
    API_URI = "https://api.binance.com/api/v3/account"

    def parse
      data["balances"].reject do |balance|
        balance["asset"] =~ /\w+(UP|DOWN)$/ || balance["free"].to_f == 0
      end.map do |balance|
        { token_name(balance["asset"]) => balance["free"].to_f }
      end
    rescue
      []
    end

    private

    def get_from_api(api_key, secret_key)
      Utils.binance_http_get(API_URI, api_key, secret_key)
    end

    def token_name(name)
      name.sub(/^LD/, "") # Binance Earn (Flexible Savings, etc)
    end
  end
end
