class ZeroxTracker
  API_URI       = "https://api.0xtracker.app/pool-data/"
  FARM_LIST_URI = "https://api.0xtracker.app/farmlist/"

  attr_accessor :data
  attr_accessor :wallet

  def initialize(options = {})
    @wallet = options["wallet"]

    farm_list = JSON.parse(Utils.http_get(FARM_LIST_URI))

    @data = options["farms"].map do |f|
      get_payload(f, farm_list)
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

  def get_payload(name, farm_list)
    Thread.new do
      JSON.parse(
        Utils.http_post(API_URI, {
          "wallet" => wallet,
          "farms" => [farm_address(name, farm_list)],
        })
      )
    end
  end

  def farm_address(name, farm_list)
    name, network = name.split(",")

    farm_list.find do |f|
      f["name"] == name.strip && f["network"] == network.strip
    end["sendValue"]
  rescue
    puts "Farm #{name.strip} (#{network.strip}) cannot be found on 0xTracker."
    exit
  end
end
