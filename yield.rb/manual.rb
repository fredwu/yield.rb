class Manual
  attr_accessor :data
  attr_accessor :rounding

  def initialize(settings = {})
    @data     = settings["include_tokens"]
    @rounding = settings["rounding"]
  end

  def parse
    data.map { |_group, group_data| group_data }.inject do |memo, el|
      memo.merge(el) do |token, amount, new_amount|
        (amount + new_amount).round(rounding)
      end
    end
  end
end
