# yield.rb

This is a simple ruby script that pulls data from [YieldWatch](https://www.yieldwatch.net/) and reconstructs them for one purpose: to get the aggregated amounts of underlying tokens.

In YieldWatch, as much as I love the details it provides on yields, it lacks a consolidated view on how much underlying tokens I have. Imagine having deposited tokens into multiple liquidity pools (LPs) and having to manually find and add up the underlying tokens (not LP tokens) one by one...

Some other wallet trackers support this, but none of them supports all the yield farms I use, namely ACryptoS.

Here's what the output data looks like:

    BNB   6.9420
    BTC   0.6969
    ETH   4.2000

## Usage

Pass in either the wallet address or the path to the YieldWatch JSON payload file.

    $ ./yield.rb -h

    Usage: yield.rb [options]
        -w, --wallet=ADDRESS             Wallet address
        -f, --file=PATH                  Path to the YieldWatch JSON payload file

Please note that if you are using the wallet address, the wallet balances will be missing from the calculation.

To include the wallet balances, go to YieldWatch, fetch your wallet, and open the browser console to copy the JSON payload.

## Assumptions

1. You only care about the amounts of the underlying tokens - which changes all the time due to IP ([Impermanent Loss](https://www.google.com/search?q=impermanent+loss)).
1. Only tokens that have already been deposited into the vaults will be counted, those that are pending are ignored.
1. Coin names on different protocols are consolidated into one, e.g. `WBNB`, `iBNB` and `beltBNB` are all consolidated into `BNB`.
1. Only the farms and tokens I personally use have been tested.

## Tested Farms

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
