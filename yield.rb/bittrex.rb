class Bittrex < Exchange
  URI = "https://api.bittrex.com/v3/balances"

  def parse
    data.reject do |balance|
      balance["currencySymbol"] == "BTXCRD" || balance["total"].to_f == 0
    end.map do |balance|
      { balance["currencySymbol"] => balance["total"].to_f }
    end
  end

  private

  def get_from_api(api_key, secret_key)
    uri = URI(URI)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req                     = Net::HTTP::Get.new(uri)
      req["Api-Key"]          = api_key
      req["Api-Timestamp"]    = Time.now.to_i * 1000
      req["Api-Content-Hash"] = Digest::SHA512.hexdigest("")
      req["Api-Signature"]    = OpenSSL::HMAC.hexdigest(
                                  "sha512",
                                  secret_key,
                                  [
                                    req["Api-Timestamp"],
                                    URI,
                                    "GET",
                                    req["Api-Content-Hash"]
                                  ].join("")
                                )
      http.request(req)
    end

    res.body
  end
end
