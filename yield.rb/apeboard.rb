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
        when "wallet"
          parse_positions(balances)
        when "farm"
          parse_farm(balances)
        end
      end
    end
  end

  private

  def parse_positions(balances)
    balances.map do |balance|
      { Utils.token_name(balance["symbol"].upcase) => balance["balance"] }
    end
  end

  def parse_farm(balances)
    balances.map do |_key, farms|
      case farms
      when 500
        puts "Error fetching from ApeBoard, please try again."
        exit
      when 404
        puts "One or more ApeBoard requests are no longer working, please fix."
        exit
      end
      farms.map do |farm|
        farm.map do |key, tokens|
          if key == "tokens"
            parse_positions(tokens)
          end
        end.compact
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
        prefix => JSON.parse(
          Utils.http_get(
            [API_URI, url_prefix, name, @wallet].reject(&:empty?).join("/")
          )
        )
      }
    end
  end
end
