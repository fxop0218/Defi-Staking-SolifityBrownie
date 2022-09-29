import pytest

from brownie import TokenFarm, network, config, exceptions
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account, get_contract, INITIAL_PRICE_FEED_VALUE
from scripts.deploy import deploy_token

def test_set_price_feed_contract():
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    account = get_account()
    not_owner = get_account(index=-1)
    token_farm, dapp_token = deploy_token()
    # Act
    token_farm.setPriceFeedContract(dapp_token.address, get_contract("eth_usd_price_feed"), {"from" : account})
    # asset
    assert token_farm.tokenPriceFeed(dapp_token.address) == get_contract("eth_usd_price_feed")
    
    with pytest.raises(exceptions.VirtualMachineError):
        token_farm.setPriceFeedContract(dapp_token.address, get_contract("eth_usd_price_feed"), {"from" : not_owner})


def test_issue_token(amount_staked):
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    account = get_account()
    token_farm, dapp_token = test_stake_tokens(amount_staked)
    starting_balance = dapp_token.balanceOf(account.address)
    # act
    token_farm.issuesToken({"from" : account})
    # arrange
    # We are stakign 1 dapp_token in price to 1 eth
    # we get 1500 dapp tokens reward
    # when the price is 1500$
    assert dapp_token.balanceOf(account.address) == starting_balance + INITIAL_PRICE_FEED_VALUE


def test_stake_tokens(amount_staked):
    # Arrange
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")

    account = get_account()
    token_farm, dapp_token = deploy_token()
    # Act
    dapp_token.approve(token_farm.address, amount_staked, {"from": account})
    token_farm.stakeToken(amount_staked, dapp_token.address, {"from": account})
    # assert
    assert token_farm.stakingBalance(dapp_token.address, account.address) == amount_staked
    assert token_farm.uniqueTokenStaked(dapp_token.address) == 0 # See this
    assert token_farm.stakers(0) == account.address
    return token_farm, dapp_token
