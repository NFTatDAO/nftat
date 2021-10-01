# NFTAT

<br/>
<p align="center">
<a href="https://chain.link" target="_blank">
<img src="./img/brand/NFTat.png" width="500" alt="NFTat">
</a>
</p>
<br/>


# Installation

1. [Install Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html), if you haven't already. Here is a simple way to install brownie.


```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# restart your terminal
pipx install eth-brownie
```
Or, if that doesn't work, via pip
```bash
pip install eth-brownie
```

2. Download the mix and install dependancies.

```bash
git clone https://github.com/NFTatDAO/nftat
cd nftat
```

## Environment Variables
If you want to be able to deploy to testnets, do the following.

Set your `WEB3_INFURA_PROJECT_ID`, and `PRIVATE_KEY` [environment variables](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html).

You can get a `WEB3_INFURA_PROJECT_ID` by getting a free trial of [Infura](https://infura.io/). At the moment, it does need to be infura with brownie. If you get lost, you can [follow this guide](https://ethereumico.io/knowledge-base/infura-api-key-guide/) to getting a project key. You can find your `PRIVATE_KEY` from your ethereum wallet like [metamask](https://metamask.io/).

You can add your environment variables to a `.env` file. You can use the [.env.exmple](https://github.com/smartcontractkit/chainlink-mix/blob/master/.env.example) as a template, just fill in the values and rename it to '.env'. Then, uncomment the line `# dotenv: .env` in `brownie-config.yaml`

Here is what your `.env` should look like:
```
export WEB3_INFURA_PROJECT_ID=<PROJECT_ID>
export PRIVATE_KEY=<PRIVATE_KEY>
```


![WARNING](https://via.placeholder.com/15/f03c15/000000?text=+) **WARNING** ![WARNING](https://via.placeholder.com/15/f03c15/000000?text=+)

DO NOT SEND YOUR PRIVATE KEY WITH FUNDS IN IT ONTO GITHUB

# Interacting with NFTat

## To buy a pixel

Go to [opensea](https://opensea.io/collection/nftatpixel?search[sortAscending]=true&search[sortBy]=CREATED_DATE).

The `0, 0` pixels are "special". One controls the background color and grayscale. One controls the big circle in the back. 

## Add polygon 

```
brownie networks add Ethereum polygon host=<YOUR_POLYGON_RPC_URL> chainid=137
```

## To change a color
Go into `change_color.py` and change `MY_TOKEN_ID` to whatever token you own, and `MY_COLOR` to any hex or string color you like. You can see a list of tokens you own on opensea or [on the website.](https://shw4wlcgirnu.moralishost.com/ChangeColor). Then run:
```
brownie run scripts/interactive_scripts/change_color.py --network polygon 
```
You can also change your color through the UI. 


# Testing
```
brownie test
```

Thanks to (TheLinkMarines)[https://twitter.com/TheLinkMarines] for the logo!!

