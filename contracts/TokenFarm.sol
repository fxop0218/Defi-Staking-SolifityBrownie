// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {
    // Mapping token address to staker address to ammout
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokenStaked;
    mapping(address => address) public tokenPriceFeed;
    address[] public stakers;
    address[] allowedTokens;
    IERC20 public dappToken;

    constructor(address _dappTokenAddress) {
        dappToken = IERC20(_dappTokenAddress);
    }

    // Stake token
    function stakeToken(uint256 _amount, address _token) public {
        // what token can they stake
        require(_amount > 0, "Amount must be more than 0");
        // Comprovate if the token is allowed
        require(tokenAllowed(_token), "This token is not allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount); // Send to this tokenFarm contract
        // Add more balance to one addess
        updataUniqueTokenStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] =
            stakingBalance[_token][msg.sender] +
            _amount;

        // If don't have tokens staked, add to the stakers list
        if (uniqueTokenStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    function issuesToken() public {
        // Issur tokens to all stakers
        for (
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++
        ) {
            address recipient = stakers[stakersIndex];
            uint256 userTotalValue = getUserTotalValue(recipient);
            dappToken.transfer(recipient, userTotalValue);
            // Send them a token reward
            // dappToken.transfer(recipients, userTotalValue);
            // basen on their total value locked
        }
    }

    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokenStaked[_user] > 0, "No tokens staked");
        for (
            uint256 tokenIndex = 0;
            tokenIndex < allowedTokens.length;
            tokenIndex++
        ) {
            totalValue =
                totalValue +
                getUserSingleTokenValue(_user, allowedTokens[tokenIndex]);
        }
        return totalValue;
    }

    function getUserSingleTokenValue(address _user, address _token)
        public
        view
        returns (uint256)
    {
        if (uniqueTokenStaked[_user] <= 0) {
            return 0;
        }
        // price of the token * stakingBalance[_token][user]
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        return ((stakingBalance[_token][_user] * price) / 10**decimals); // !0 ETH / ETH/USD -> 100 = 1000 usd
    }

    function getTokenValue(address _token)
        public
        view
        returns (uint256, uint256)
    {
        address preiceFeedAddress = tokenPriceFeed[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            preiceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals); //TODO
    }

    function updataUniqueTokenStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0) {
            uniqueTokenStaked[_user] = uniqueTokenStaked[_user] + 1;
        }
    }

    // Add token to the allowed list, only owner can add tokens
    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    // Search if the token is in the list
    function tokenAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokenIndex = 0;
            allowedTokenIndex < allowedTokens.length;
            allowedTokenIndex++
        ) {
            if (allowedTokens[allowedTokenIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function setPriceFeedContract(address _token, address _priceFeed)
        public
        onlyOwner
    {
        tokenPriceFeed[_token] = _priceFeed;
    }

    function unstakeTokens(address _token) public {
        uint256 balance = stakingBalance[msg.sender][_token];
        require(balance > 0, "You don't have balance staked");
        // Transfer actual balance to msg.sender
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[msg.sender][_token] = 0;
        uniqueTokenStaked[msg.sender] = uniqueTokenStaked[msg.sender] - 1;
    }
}
