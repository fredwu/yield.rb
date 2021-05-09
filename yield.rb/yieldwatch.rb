class YieldWatch
  URI      = "https://www.yieldwatch.net/api/all/"
  URI_ARGS = "?platforms=beefy,pancake,hyperjump,blizzard,bdollar,jetfuel,auto,bunny,acryptos,mdex,alpha,venus,cream"

  attr_accessor :json
  attr_accessor :rounding

  def initialize(options = {})
    json = if file = options["file"]
      File.read(file)
    elsif wallet = options["wallet"]
      open("#{URI}#{wallet}#{URI_ARGS}") do |f|
        f.read
      end
    end

    @json = JSON.parse(json)
    @rounding = options["rounding"]
  end

  def parse
    @json["result"].flat_map do |_name, farm|
      farm.flat_map do |type, stake|
        case type
        when "balances"
          parse_wallet(stake)
        when "vaults", "LPVaults", "staking", "LPStaking"
          parse_vaults(type, stake["vaults"])
        end
      end.compact.reject(&:empty?)
    end
  end

  private

  def parse_wallet(balances)
    balances.map do |balance|
      { balance["symbol"] => balance["balance"].round(rounding) }
    end
  end

  def parse_vaults(type, vaults)
    vaults.map { |vault| parse_vault(vault) }
  end

  def parse_vault(vault)
    if lp = vault["LPInfo"]
      parse_lp(lp)
    else
      parse_pool(vault)
    end
  end

  def parse_lp(lp)
    {
      token_name(lp["symbolToken0"]) => lp["currentToken0"].round(rounding),
      token_name(lp["symbolToken1"]) => lp["currentToken1"].round(rounding)
    }
  end

  def parse_pool(pool)
    return if pool["depositToken"] =~ /^acs/ # "acs" tokens are pending rewards

    {
      token_name(pool["depositToken"]) => pool["depositedTokens"].round(rounding)
    }
  end

  def token_name(name)
    case name
    when "WBNB", "iBNB", "beltBNB"
      "BNB"
    when "beltBTC", "BTCB"
      "BTC"
    when "beltETH"
      "ETH"
    else
      name
    end
  end
end
