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
end
