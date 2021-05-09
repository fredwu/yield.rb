require "net/http"
require "openssl"

class Binance
  URI = "https://api.binance.com/sapi/v1/accountSnapshot"

  attr_accessor :json
  attr_accessor :rounding

  def initialize(options = {})
    json = if file = options["file"]
      File.read(file)
    elsif (api_key, secret_key = options["api_key"], options["secret_key"])
      get_from_api(api_key, secret_key)
    end

    @json = JSON.parse(json)
    @rounding = options["rounding"]
  end

  def parse
    # uses yesterday's snapshot, as the latest snapshot sometimes misses certain tokens
    json["snapshotVos"][-2]["data"]["balances"].reject do |balance|
      balance["free"] == "0"
    end.map do |balance|
      { token_name(balance["asset"]) => balance["free"].to_f.round(rounding) }
    end
  end

  private

  def get_from_api(api_key, secret_key)
    timestamp           = Time.now.to_i * 1000
    params              = "type=SPOT&timestamp=#{timestamp}"
    signature           = OpenSSL::HMAC.hexdigest("sha256", secret_key, params)
    params              = "#{params}&signature=#{signature}"
    uri                 = URI("#{URI}?#{params}")
    req                 = Net::HTTP::Get.new(uri)
    req["X-MBX-APIKEY"] = api_key
    http                = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl        = true
    res                 = http.request(req)

    res.body
  end

  def token_name(name)
    name.sub(/^LD/, "") # Binance Earn (Flexible Savings, etc)
  end
end
