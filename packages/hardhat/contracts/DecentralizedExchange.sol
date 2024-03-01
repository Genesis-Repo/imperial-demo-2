// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import necessary contracts and interfaces from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DecentralizedExchange {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // This structure represents a token pair
    struct TokenPair {
        address token1;
        address token2;
    }

    // This structure represents a limit order
    struct LimitOrder {
        address trader;
        address tokenGive;
        address tokenGet;
        uint256 amountGive;
        uint256 amountGet;
    }

    // An array to store all registered tokens
    address[] public registeredTokens;
    
    // An array to store all created token pairs
    TokenPair[] public tokenPairs;
    
    // Mapping to track the balance of each token for each user
    mapping(address => mapping(address => uint256)) public balance;

    // Mapping to store limit orders
    LimitOrder[] public limitOrders;

    // Event to track token registration
    event TokenRegistered(address indexed tokenAddress);
    
    // Event to track the creation of a token pair
    event TokenPairCreated(address indexed token1, address indexed token2);
    
    // Event to track token swap between two tokens
    event TokenSwap(address indexed token1, address indexed token2, address indexed sender, uint256 amount);

    // Event to track a limit order creation
    event LimitOrderCreated(address indexed trader, address indexed tokenGive, address indexed tokenGet, uint256 amountGive, uint256 amountGet);

    // Function to register a new ERC20 token
    function registerToken(address _tokenAddress) external {
        // Ensure the token is not already registered
        require(isTokenRegistered(_tokenAddress) == false, "Token is already registered");

        // Add the token to the registeredTokens array
        registeredTokens.push(_tokenAddress);

        emit TokenRegistered(_tokenAddress);
    }

    // Function to check if a token is already registered
    function isTokenRegistered(address _tokenAddress) internal view returns (bool) {
        for (uint256 i = 0; i < registeredTokens.length; i++) {
            if (registeredTokens[i] == _tokenAddress) {
                return true;
            }
        }
        return false;
    }
    
    // Function to create a new token pair
    function createTokenPair(address _token1, address _token2) external {
        // Ensure both tokens are registered
        require(isTokenRegistered(_token1) == true, "Token1 is not registered");
        require(isTokenRegistered(_token2) == true, "Token2 is not registered");
        
        // Create a new TokenPair struct and add it to the tokenPairs array
        TokenPair memory newTokenPair = TokenPair(_token1, _token2);
        tokenPairs.push(newTokenPair);

        emit TokenPairCreated(_token1, _token2);
    }
    
    // Function to swap one token for another token
    function swapToken(address _token1, address _token2, uint256 _amount) external {
        // Ensure the token pair exists
        require(isTokenPairCreated(_token1, _token2) == true, "Token pair does not exist");
        
        // Ensure the sender has enough balance
        require(balance[msg.sender][_token1] >= _amount, "Insufficient balance");
        
        // Calculate the amount of _token2 based on the current exchange rate
        // In this example, we are assuming a 1:1 exchange rate
        uint256 token2Amount = _amount;
        
        // Transfer _amount of _token1 from the sender to the contract
        IERC20(_token1).safeTransferFrom(msg.sender, address(this), _amount);
        
        // Transfer token2Amount of _token2 from the contract to the sender
        IERC20(_token2).safeTransfer(msg.sender, token2Amount);
        
        // Update the balance of the sender
        balance[msg.sender][_token1] = balance[msg.sender][_token1].sub(_amount);
        
        emit TokenSwap(_token1, _token2, msg.sender, _amount);
    }

    // Function to create a limit order
    function createLimitOrder(address _tokenGive, address _tokenGet, uint256 _amountGive, uint256 _amountGet) external {
        // Ensure the tokens in the limit order exist in the tokenPairs
        require(isTokenPairCreated(_tokenGive, _tokenGet) == true, "Token pair does not exist");

        // Create a new LimitOrder struct and add it to the limitOrders array
        LimitOrder memory newLimitOrder = LimitOrder(msg.sender, _tokenGive, _tokenGet, _amountGive, _amountGet);
        limitOrders.push(newLimitOrder);

        emit LimitOrderCreated(msg.sender, _tokenGive, _tokenGet, _amountGive, _amountGet);
    }

    // Additional Features Suggestions:
    // 1. Automated Market Making (AMM) Pools
    // 2. Token withdrawal by the contract owner
    // 3. Trade history tracking for users
    // 4. Fee implementation for each swap
    // 5. Integration with a decentralized oracle for exchange rates
}