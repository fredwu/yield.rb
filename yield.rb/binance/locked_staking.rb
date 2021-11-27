module Binance
  class LockedStaking < Exchange
    def parse
      data["data"].map do |balance|
        { balance["asset"] => balance["amount"].to_f }
      end
    end
  end
end
