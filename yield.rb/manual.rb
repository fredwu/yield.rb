class Manual
  attr_accessor :data
  attr_accessor :rounding

  def initialize(settings = {})
    @data     = settings["include_tokens"]
    @rounding = settings["rounding"]
  end

  def parse
    data.map do |group, group_data|
      group_data.map do |token, amount|
        { token => amount.round(rounding) }
      end
    end.flatten.inject do |memo, el|
      memo.merge(el) do |token, amount, new_amount|
        amount + new_amount
      end
    end
  end
end
