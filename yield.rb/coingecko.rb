class CoinGecko
  LIST_URI = "https://api.coingecko.com/api/v3/coins/list?include_platform=false"
  COIN_URI = "https://api.coingecko.com/api/v3/coins/markets?&order=market_cap_desc&sparkline=false&per_page=1"

  attr_accessor :settings
  attr_accessor :list
  attr_accessor :coins

  def initialize(settings)
    @settings = settings
    @coins    = {}
  end

  def fetch!(names)
    @list  = JSON.parse(http_get(LIST_URI))
    ids    = names.map { |n| detect_token_id(n) }
    @coins = settings["currencies"].map do |c|
      [
        c,
        JSON.parse(
          http_get("#{COIN_URI}&vs_currency=#{c}&ids=#{ids.join(',')}")
        )
      ]
    end.to_h
  end

  def values(name, amount)
    settings["currencies"].map do |c|
      [c, do_value(name, c, amount)]
    end.to_h
  end

  private

  def do_value(name, currency, amount)
    id    = detect_token_id(name)
    price = coins[currency].detect { |c| c["id"] == id }["current_price"]

    amount * price
  rescue
    0
  end

  def detect_token_id(name)
    names = list.select do |i|
      if mapped_name = settings["token_names"][name]
        i["name"].downcase == mapped_name.downcase
      else
        i["symbol"].downcase == name.downcase
      end
    end

    if names.length > 1
      puts "Token #{name} is ambigious, found #{names.length} different ones, please map the correct one."

      names.each do |i|
        puts "  - #{i["name"]} (id: #{i["id"]})"
      end

      exit
    elsif names.length == 0
      puts "Token #{name} cannot be found on CoinGecko, consider hiding it."
    else
      names.first["id"]
    end
  end

  def http_get(uri)
    uri          = URI(uri)
    req          = Net::HTTP::Get.new(uri)
    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res          = http.request(req)

    res.body
  end
end
