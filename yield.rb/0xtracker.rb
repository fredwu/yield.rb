class ZeroxTracker
  API_URI       = "https://api.0xtracker.app/farms/"
  FARM_LIST_URI = "https://api.0xtracker.app/farms-list/"
  WALLET_URI    = "https://api.0xtracker.app/wallet/"

  attr_accessor :data
  attr_accessor :wallet

  def initialize(options = {})
    @wallet = options["wallet"]

    wallets_data = options["wallets"]&.map do |w|
      get_wallet_payload(w)
    end&.map(&:value)&.flatten

    farm_list = JSON.parse(Utils.http_get(FARM_LIST_URI))
    farms_data = options["farms"]&.map do |f|
      get_farm_payload(f, farm_list)
    end&.map(&:value)

    @data = wallets_data + farms_data
  end

  def parse
    data.map do |e|
      if e == {}
        nil
      elsif e.keys[0] == "token_address"
        parse_wallet(e)
      else
        parse_farm(e)
      end
    end.compact
  end

  private

  def parse_wallet(wallet)
    return nil if wallet["tokenPrice"] == 0

    { Utils.token_name(wallet["symbol"]) => wallet["tokenBalance"] }
  end

  def parse_farm(farm)
    name = farm.keys[0]

    farm[name]["userData"].map do |_key, data|
      if data["token1"]
        parse_lp(data)
      else
        parse_single(data)
      end
    end
  rescue
    puts "One of the 0xTracker farms returned invalid data:"
    puts farm.inspect
  end

  def parse_single(data)
    balance = data["lpTotal"] || data["staked"]

    { Utils.token_name(data["tokenPair"]) => balance }
  end

  def parse_lp(data)
    lpTotal = data["elevenBalance"]&.tr("(", "")&.tr(")", "") || data["lpTotal"]

    symbols  = data["tokenPair"].split("/")
    balances = lpTotal.split("/")

    [
      { Utils.token_name(symbols[0]) => balances[0].to_f },
      { Utils.token_name(symbols[1]) => balances[1].to_f },
    ]
  end

  def get_farm_payload(name, farm_list)
    Thread.new do
      begin
        retries ||= 0
        JSON.parse(
          Utils.http_get("#{API_URI}#{wallet}/#{farm_address(name, farm_list)}")
        )
      rescue
        if (retries += 1) < 3
          retry
        else
          puts "0xtracker: cannot fetch farm payload for #{name} (#{farm_address(name, farm_list)})."
          {}
        end
      end
    end
  end

  def get_wallet_payload(network)
    Thread.new do
      begin
        retries ||= 0
        JSON.parse(
          Utils.http_get("#{WALLET_URI}#{wallet}/#{network}")
        )
      rescue
        if (retries += 1) < 3
          retry
        else
          puts "0xtracker: cannot fetch wallet payload for #{network}."
          {}
        end
      end
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
