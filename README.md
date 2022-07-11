# Minter.wtf

Exploit as a Service (EaaS) which allows users to create "Minters" or custom contracts to mint NFT projects in an easy to use interface.

These "Minters" act as ethereum wallets, allowing the user to mint from multiple addresses under one transaction.
## V1 vs. V2

V2 of Minter.wtf brings plenty of gas optimization to the table over V1. The three gas guzzlers are **Creating Minters**, **Mass Mints**, and **Mass Transfers**.


| Function             | V1                                                                | V2                                                                | % Change                                                                |
| ----------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| Create Minters | 12,222,266 | 4,819,401 | -86.9% |
| Mass Mint | 2,120,938 | 651,069 | -106.1% |
| Mass Transfer | 433,460 | 292,798 | -38.7% |

Note: All tests are in multiples of 10 (example: Creating **10** Minters)

## Links

 - [Etherscan](https://etherscan.io/address/0x5695201ae931b0f667dc24397015f10bba76fd5e)