class Manual
  attr_accessor :data
  attr_accessor :rounding

  def initialize(settings = {})
    @data     = settings["include_tokens"]
    @rounding = settings["rounding"]
  end

  def parse
    data.map do |token, amount|
      { token => amount.round(rounding) }
    end
  end
end
