module Binance
  class LiquidSwap < Exchange
    API_URI = "https://api.binance.com/sapi/v1/bswap/liquidity"

    def parse
      data.select do |pool|
        pool["share"]["shareAmount"].to_f > 0
      end.flat_map do |pool|
        assets = pool["share"]["asset"]

        k1, k2 = assets.keys
        v1, v2 = assets.values

        [
          k1 => v1.to_f,
          k2 => v2.to_f,
        ]
      end
    end

    private

    def get_from_api(api_key, secret_key)
      Utils.binance_http_get(API_URI, api_key, secret_key)
    end
  end
end
