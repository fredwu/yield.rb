class ApeBoard
  API_URI = "https://api.apeboard.finance"

  attr_accessor :data
  attr_accessor :wallet

  def initialize(options = {})
    @wallet = options["wallet"]

    wallets_data = options["wallets"].map do |w|
      get_payload(w, "wallet")
    end.map(&:value)

    farms_data = options["farms"].map do |f|
      get_payload(f, "farm")
    end.map(&:value)

    @data = wallets_data + farms_data
  end

  def parse
    data.map do |chunk|
      chunk.map do |type, balances|
        case type
        when /^wallet/
          parse_positions(type, balances)
        when /^farm/
          parse_farm(type, balances)
        end
      end
    end
  end

  private

  def parse_positions(_type, balances)
    balances.map do |balance|
      { Utils.token_name(balance["symbol"].upcase) => balance["balance"].to_f }
    end
  end

  def parse_farm(type, balances)
    balances.map do |_key, farms|
      case farms
      when 500
        puts "!!! Error fetching from ApeBoard (#{type}), please try again."
        []
      when 404
        puts "!!! The ApeBoard request (#{type}) is no longer working, please fix."
        []
      when String
        []
      else
        farms.map do |farm|
          farm.map do |key, tokens|
            if key == "tokens"
              parse_positions(type, tokens)
            end
          end.compact
        end
      end
    end
  end

  def get_payload(name, prefix = "")
    url_prefix = case prefix
      when "wallet"
        "wallet"
      when "farm"
        ""
      end

    Thread.new do
      {
        "#{prefix} #{name}" => JSON.parse(
          Utils.http_get(
            [API_URI, url_prefix, name, wallet].reject(&:empty?).join("/"),
            {
              "origin" => "apeboard.finance",
              "ape-secret" => "U2FsdGVkX1+cTatAJ47gsc43jtt8TKOCcHtjQ0jLCkIxOe/0zas5drvoaftIOQ7u2YCJ+A3qe3/OE0NuNMCqVXGoigeV8Ddbuwsqp/1F4NdUE3evdLplm5GWHMpOLfbOfw+d1si/XfHRl/31sgJEPg==",
              "passcode" => "5a102a34f60fa8ec9d643e8a0e72cab9"
            }
          )
        )
      }
    end
  end
end
