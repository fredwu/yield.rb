#!/usr/bin/env ruby

# Author: Fred Wu
# Source code: https://github.com/fredwu/yield.rb
# License: http://fredwu.mit-license.org/

require "json"
require "open-uri"
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: yield.rb [options]"

  opts.on("-w ADDRESS", "--wallet=ADDRESS", "Wallet address") do |w|
    options[:wallet] = w
  end

  opts.on("-f PATH", "--file=PATH", "Path to the YieldWatch JSON payload file") do |f|
    options[:file] = f
  end
end.parse!

class YieldWatchParser
  URI = "https://www.yieldwatch.net/api/all/"
  URI_ARGS = "?platforms=beefy,pancake,hyperjump,blizzard,bdollar,jetfuel,auto,bunny,acryptos,mdex,alpha,venus,cream"
  ROUNDING = 4

  attr_accessor :json

  def initialize(wallet: nil, file: nil)
    json = if file
      File.read(file)
    elsif wallet
      open("#{URI}#{wallet}#{URI_ARGS}") do |f|
        f.read
      end
    end

    @json = JSON.parse(json)
  end

  def output
    hash = Hash[parse.inject do |result, tokens|
      result.merge(tokens) { |_, x, y| (x + y).round(ROUNDING) }
    end.sort]

    hash.each { |k, v| puts "#{k}\t#{v}" }
  end

  private

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

  def parse_wallet(balances)
    balances.map do |balance|
      { balance["symbol"] => balance["balance"].round(ROUNDING) }
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
      token_name(lp["symbolToken0"]) => lp["currentToken0"].round(ROUNDING),
      token_name(lp["symbolToken1"]) => lp["currentToken1"].round(ROUNDING)
    }
  end

  def parse_pool(pool)
    return if pool["depositToken"] =~ /acs/

    {
      token_name(pool["depositToken"]) => pool["depositedTokens"].round(ROUNDING)
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

YieldWatchParser.new(options).output
