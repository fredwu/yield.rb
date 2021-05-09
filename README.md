# yield.rb

This is a simple ruby script that pulls data from [YieldWatch](https://www.yieldwatch.net/) and [Binance](https://www.binance.com/), and reconstructs them for one purpose: to get the aggregated amounts of underlying tokens.

## Why?

In YieldWatch, as much as I love the details it provides on yields, it lacks a consolidated view on how much underlying tokens I have. Imagine having deposited tokens into multiple liquidity pools (LPs) and having to manually find and add up the underlying tokens (not LP tokens) one by one...

Some other wallet trackers support this, but none of them supports all the yield farms I use, namely ACryptoS.

Here's what the output data looks like:

    BNB   6.9420     USD 1.23     AUD 2.34
    BTC   0.6969     USD 12.34    AUD 23.45
    ETH   4.2000     USD 3.45     AUD 5.67

    Total USD: 17.02
    Total AUD: 31.46

## Usage

Copy or rename `config.sample.yml` to `config.yml`:

    mv config{.sample,}.yml

### Configurations

| Option         | Type           | Description
| -------------- | -------------- | -----------
| rounding       | integer        | decimal rounding, defaults to 6
| token_names    | string: string | token name mapping
| hide_tokens    | array(string)  | tokens that should be hidden from output
| include_tokens | string: float  | manually add tokens and their amounts

- <sup>In some cases token symbols are not unique (e.g. `BUNNY` can be `Pancake Bunny`, `BunnyToken` or `Rocket Bunny`), in this case they need to be added to the `token_names` mapping. Search [CoinGecko](https://www.coingecko.com/) for their names.</sup>

- <sup>The `hide_tokens` option is useful for hiding dusts and/or tokens you don't care about.</sup>

- <sup>The `include_tokens` option is useful for adding tokens from places without APIs, such as [Nexo](https://nexo.io/).</sup>

#### Binance

| Option     | Type          | Description
| ---------- | ------------- | -----------
| api_key    | string        | API key
| secret_key | string        | Secret key
| file       | string        | relative path to the Binance JSON payload file (`Daily Account Snapshot (USER_DATA)`)

- <sup>The `file` option is only needed if you don't want to supply the API and secret keys.</sup>

#### YieldWatch

| Option | Type          | Description
| ------ | ------------- | -----------
| wallet | string        | BSC wallet address
| file   | string        | relative path to the YieldWatch JSON payload file

- <sup>Please note that if you are using the wallet address, the wallet balances will be missing from the calculation. To include the wallet balances, go to YieldWatch, fetch your wallet, and open the browser console to copy the JSON payload.</sup>

## Assumptions

1. You only care about the amounts of the underlying tokens - which changes all the time due to IL ([Impermanent Loss](https://www.google.com/search?q=impermanent+loss)).
1. Only tokens that have already been deposited into the vaults will be counted, those that are pending are ignored.
1. Coin names on different protocols are consolidated into one, e.g. `WBNB`, `iBNB` and `beltBNB` are all consolidated into `BNB`.
1. Only the farms and tokens I personally use have been tested.
1. Token prices are fetched from [CoinGecko](https://www.coingecko.com/).

## Supported Exchanges

- [Binance](https://www.binance.com/)

## Tested Farms / Yield Aggregators

These are the farms I use and therefore their outputs are tested.

- [ACryptoS](https://acryptos.com/)
- [AutoFarm](https://autofarm.network/)
- [PancakeBunny](https://pancakebunny.finance/)

## Wallet Trackers

These are the BSC (Binance Smart Chain) wallet trackers I have come across.

- [DeBank](https://debank.com/)
- [Farm.Army](https://farm.army/)
- [Farmfol.io](https://farmfol.io/)
- [Growing.fi](https://www.growing.fi/)
- [tin.](https://tin.network/)
- [YieldWatch](https://www.yieldwatch.net/)

## License

Licensed under [MIT](http://fredwu.mit-license.org/).
