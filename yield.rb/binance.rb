class Binance < Exchange
  API_URI = "https://api.binance.com/api/v3/account"

  def parse
    data["balances"].reject do |balance|
      balance["asset"] =~ /\w+(UP|DOWN)$/ || balance["free"].to_f == 0
    end.map do |balance|
      { token_name(balance["asset"]) => balance["free"].to_f }
    end
  end

  private

  def get_from_api(api_key, secret_key)
    timestamp = Time.now.to_i * 1000
    params    = "timestamp=#{timestamp}"
    signature = OpenSSL::HMAC.hexdigest("sha256", secret_key, params)
    params    = "#{params}&signature=#{signature}"
    uri       = URI("#{API_URI}?#{params}")

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req                 = Net::HTTP::Get.new(uri)
      req["X-MBX-APIKEY"] = api_key

      http.request(req)
    end

    res.body
  end

  def token_name(name)
    name.sub(/^LD/, "") # Binance Earn (Flexible Savings, etc)
  end
end
