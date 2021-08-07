require 'bigdecimal'

module Utils
  class << self
    def http_get(uri, headers={})
      uri = URI(uri)
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req["Content-Type"] = "application/json"

        headers.each do |key, value|
          req[key] = value
        end

        http.request(req)
      end

      res.body
    end

    def http_post(uri, data)
      uri = URI(uri)
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req["Content-Type"] = "application/json"
        req.body = data.to_json

        http.request(req)
      end

      res.body
    end

    def binance_http_get(api_uri, api_key, secret_key)
      timestamp = Time.now.to_i * 1000
      params = "timestamp=#{timestamp}"
      signature = OpenSSL::HMAC.hexdigest("sha256", secret_key, params)
      params = "#{params}&signature=#{signature}"
      uri = URI("#{api_uri}?#{params}")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req["X-MBX-APIKEY"] = api_key

        http.request(req)
      end

      res.body
    end

    def round(value, rounding_setting)
      BigDecimal(value.to_s).round(rounding_setting).to_s("F")
    end

    def token_name(name)
      mapping ||= begin
        options = YAML.load_file(File.join(__dir__, "../config.yml"))
        options["settings"]["token_mappings"].map { |k, v| [v, k] }.to_h
      end

      mapping.each do |names, real_name|
        name = name.sub(/^acs(\w+)/, '\1')

        if names.include?(name)
          return real_name
        end
      end

      name
    end
  end
end
