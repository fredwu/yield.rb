class Yield
  CURRENCY_ROUNDING = 2

  attr_accessor :amounts
  attr_accessor :settings

  def initialize(amounts, settings)
    @amounts  = amounts
    @settings = settings
  end

  def output
    totals = {}

    amounts_with_pricing.each do |name, v|
      amount = v[:amount].round(settings["rounding"])
      value  = v[:values].map { |k, v| "#{k} #{v.round(CURRENCY_ROUNDING)}" }.join("\t")

      puts "#{name}\t#{amount}\s\t#{value}"

      settings["currencies"].each do |c|
        totals[c] ||= 0
        totals[c] += v[:values][c]
      end
    end

    puts "\n"

    settings["currencies"].each do |c|
      puts "Total #{c}: #{totals[c].round(CURRENCY_ROUNDING)}"
    end
  end

  private

  def amounts_with_pricing
    prices = CoinGecko.new(settings)
    prices.fetch!(merged_amounts.keys)

    merged_amounts.map do |name, amount|
      [name, { amount: amount, values: prices.values(name, amount) }]
    end
  end

  def merged_amounts
    @merged_amounts ||= Hash[amounts.flatten.inject do |result, tokens|
      result.merge(tokens) { |_, n1, n2| n1 + n2 }
    end.reject{ |k, v| settings["hide_tokens"].include?(k) }.sort]
  end
end
