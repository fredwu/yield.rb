class ZeroxTracker
  API_URI = "https://api.0xtracker.app/pool-data/"

  attr_accessor :data
  attr_accessor :wallet

  def initialize(options = {})
    @wallet = options["wallet"]

    @data = options["farms"].map do |f|
      get_payload(f)
    end.map(&:value)
  end

  def parse
    data.map do |farm|
      parse_farm(farm)
    end
  end

  private

  def parse_farm(farm)
    name = farm.keys[0]

    farm[name]["userData"].map do |_key, data|
      case data["type"]
      when "single"
        parse_single(data)
      when "lp"
        parse_lp(data)
      end
    end
  end

  def parse_single(data)
    { data["tokenPair"] => data["staked"] }
  end

  def parse_lp(data)
    symbols  = data["tokenPair"].split("/")
    balances = data["lpTotal"].split("/")

    [
      { symbols[0] => balances[0].to_f },
      { symbols[1] => balances[1].to_f },
    ]
  end

  def get_payload(name)
    Thread.new do
      JSON.parse(
        Utils.http_post(API_URI, {
          "wallet" => wallet,
          "farms" => [name],
        })
      )
    end
  end
end
