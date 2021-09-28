# yield.rb

This is a simple ruby script that pulls data from supported yield trackers and exchanges, and reconstructs them for one purpose: to get the aggregated amounts and values of underlying tokens.

## Why?

In YieldWatch, as much as I love the details it provides on yields, it lacks a consolidated view on how much underlying tokens I have. Imagine having deposited tokens into multiple liquidity pools (LPs) and having to manually find and add up the underlying tokens (not LP tokens) one by one...

Some other wallet trackers support this, but none of them supports all the yield farms I use.

As of July 2021, I've switched to using 0xTracker and ApeBoard. If a farm is supported in both then I'd use 0xTracker as it doesn't require a periodically updated auth token.

Here's what the output data looks like:

    BNB   6.9420     USD 1.23     AUD 2.34
    BTC   0.6969     USD 12.34    AUD 23.45
    ETH   4.2000     USD 3.45     AUD 5.67

    Total USD: 17.02
    Total AUD: 31.46

## Usage

Copy `config.sample.yml` to `config.yml`:

    cp config{.sample,}.yml

### Configurations

| Option         | Type           | Description
| -------------- | -------------- | -----------
| format         | string         | `json` or `text`
| currencies     | array(string)  | currency ISO codes, e.g. `USD`
| rounding       | integer        | decimal rounding, defaults to 6
| token_names    | string: string | token name mapping
| token_mappings | array(string)  | token code mapping, e.g. to map `BTCB` to `BTC`
| hide_tokens    | array(string)  | tokens that should be hidden from output
| include_tokens | string: float  | manually add tokens and their amounts

- <sup>In some cases token symbols are not unique (e.g. `BUNNY` can be `Pancake Bunny`, `BunnyToken` or `Rocket Bunny`), in this case they need to be added to the `token_names` mapping. Search [CoinGecko](https://www.coingecko.com/) for their names.</sup>

- <sup>The `hide_tokens` option is useful for hiding dusts and/or tokens you don't care about.</sup>

- <sup>The `include_tokens` option is useful for adding tokens from places without APIs, such as [Nexo](https://nexo.io/). Tokens are categorised under groups (exchanges or farms, etc).</sup>

#### 0xTracker

| Option  | Type          | Description
| ------- | ------------- | -----------
| wallet  | string        | wallet address
| wallets | array(string) | wallets, e.g. `eth`, `bsc` and `matic`, etc
| farms   | array(string) | farms, e.g. `mochiswap.io, bsc`

- <sup>Visit [0xTracker](https://0xtracker.app/) and take a look at the GET or POST requests to find all the supported farms.</sup>

- <sup>Farm entries are supplied by their name and network, e.g. `mochiswap.io, bsc`.</sup>

#### ApeBoard

| Option     | Type          | Description
| ---------- | ------------- | -----------
| ape-secret | string        | value from the request header `ape-secret`
| passcode   | string        | value from the request header `passcode`
| wallet     | string        | wallet address
| wallets    | array(string) | wallets, e.g. `eth`, `bsc` and `matic`, etc
| farms      | array(string) | farms, e.g. `pancakeswapBsc` and `polycat`, etc

- <sup>Visit [ApeBoard](https://apeboard.finance/) and take a look at the GET requests to find all the supported wallets and farms.</sup>

#### YieldWatch

| Option | Type   | Description
| ------ | ------ | -----------
| wallet | string | wallet address
| jwt    | string | YieldWatch JWT
| file   | string | relative path to the YieldWatch JSON payload file

- <sup>Please note that if you are using the wallet address, the wallet balances will be missing from the calculation. To include the wallet balances, go to YieldWatch, fetch your wallet, and open the browser console to copy the JSON payload.</sup>

- <sup>Alternatively, find the YieldWatch GET request and copy the JWT (the string after "Authorization: Bearer ") in the header.</sup>

#### Binance & Bittrex

| Option     | Type   | Description
| ---------- | ------ | -----------
| api_key    | string | API key
| secret_key | string | secret key
| file       | string | relative path to the JSON payload file from the API

- <sup>The `file` option is only needed if you don't want to supply the API and secret keys.</sup>

## Assumptions

1. You only care about the amounts of the underlying tokens - which changes all the time due to IL ([Impermanent Loss](https://www.google.com/search?q=impermanent+loss)).
1. Only tokens that have already been deposited into the vaults will be counted, those that are pending are ignored.
1. Coin names on different protocols are consolidated into one, e.g. `WBNB`, `iBNB` and `beltBNB` are all consolidated into `BNB`.
1. Only the farms and tokens I personally use have been tested.
1. Token prices are fetched from [CoinGecko](https://www.coingecko.com/).

## Supported Exchanges

- [Binance](https://www.binance.com/)
- [Bittrex](https://bittrex.com/)

## Tested Farms / Yield Aggregators

These are the farms I have used and therefore their outputs are tested.

- [ACryptoS](https://acryptos.com/) - BSC
- [Adamant](https://adamant.finance/) - Polygon
- [AutoFarm](https://autofarm.network/) - BSC, Polygon
- [Beefy](https://beefy.finance/) - BSC, Polygon
- [Darkside](https://darkside.finance/) - Polygon
- [EVOdefi](https://evo-matic.com/) - Polygon
- [Goose Finance](https://goosedefi.com/) - BSC
- [Moonpot](https://moonpot.com/) - BSC
- [KogeFarm](https://kogefarm.io/) - Polygon
- [PancakeBunny](https://pancakebunny.finance/) - BSC
- [PancakeSwap](https://pancakeswap.finance/) - BSC
- [PolyCat](https://polycat.finance/) - Polygon
- [PolyCrystal](https://polycrystal.finance/) - Polygon
- [PolygonFarm](https://polygonfarm.finance/) - Polygon
- [Sushi](https://sushi.com/) - Polygon

If a farm is supported on 0xTracker or ApeBoard, it should work fine.

## Wallet Trackers

These are the BSC (Binance Smart Chain) wallet trackers I have come across.

- [0xTracker](https://0xtracker.app/)
- [ApeBoard](https://apeboard.finance/)
- [DeBank](https://debank.com/)
- [Farm.Army](https://farm.army/)
- [Farmfol.io](https://farmfol.io/)
- [Growing.fi](https://www.growing.fi/)
- [SCV](https://scv.finance/)
- [tin.](https://tin.network/)
- [YieldWatch](https://www.yieldwatch.net/)

## License

Licensed under [MIT](http://fredwu.mit-license.org/).
