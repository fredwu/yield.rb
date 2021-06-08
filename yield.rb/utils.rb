require 'bigdecimal'

module Utils
  def self.http_get(uri)
    uri = URI(uri)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req                 = Net::HTTP::Get.new(uri)
      req["Content-Type"] = "application/json"

      http.request(req)
    end

    res.body
  end

  def self.round(value, rounding_setting)
    BigDecimal(value.to_s).round(rounding_setting).to_s("F")
  end

  def self.token_name(name)
    case name
    when "beltBNB", "iBNB", "WBNB"
      "BNB"
    when "beltBTC", "BTCB", "WBTC"
      "BTC"
    when "beltETH", "WETH"
      "ETH"
    when "WMATIC"
      "MATIC"
    when "IRON"
      "USDC"
    else
      name
    end
  end
end
