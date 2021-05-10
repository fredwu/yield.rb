class Exchange
  attr_accessor :data

  def initialize(options = {})
    json = if file = options["file"]
      File.read(file)
    elsif (api_key, secret_key = options["api_key"], options["secret_key"])
      get_from_api(api_key, secret_key)
    end

    @data = JSON.parse(json)
  end
end
