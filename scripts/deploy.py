from brownie import network, config, TokenFarm, DappToken
from scripts.helpful_scripts import get_account, get_contract
from web3 import Web3

# Constants
KEPT_VAL = Web3.toWei(100, "ether")

# Functions
def main():
    deploy_token()


# Deploy the token
def deploy_token():
    account = get_account()
    dapp_token = DappToken.deploy({"from": account})
    token_farm = TokenFarm.deploy(
        dapp_token.address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    transaction = dapp_token.transfer(
        token_farm.address, dapp_token.totalSupply() - KEPT_VAL, {"from": account}
    )
    transaction.wait(1)
    weth_token = get_contract("weth_token")
    fau_token = get_contract("fau_token")
    allowed_tokens = {
        dapp_token: get_contract("dai_usd_price_feed"),
        fau_token: get_contract("dai_usd_price_feed"),
        weth_token: get_contract("eth_usd_price_feed"),
    }
    add_allowed_tokens(token_farm, allowed_tokens, account)
    return token_farm, dapp_token

# Add tokens to allowed token list
def add_allowed_tokens(token_farm, allowed_tokens, account):
    for token in allowed_tokens:
        add_tx = token_farm.addAllowedTokens(token.address, {"from": account})
        add_tx.wait(1)
        set_tx = token_farm.setPriceFeedContract(
            token.address, allowed_tokens[token], {"from": account}
        )
        set_tx.wait(1)
    return token_farm
