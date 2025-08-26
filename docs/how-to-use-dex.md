# How to Use the Manexus DEX

This guide provides comprehensive instructions on how to interact with the Manexus DEX smart contracts for trading, liquidity provision, and other DEX operations.

## Table of Contents

1. [Overview](#overview)
2. [Contract Addresses](#contract-addresses)
3. [Token Swapping](#token-swapping)
4. [Liquidity Provision](#liquidity-provision)
5. [ETH Integration](#eth-integration)
6. [Price Queries](#price-queries)
7. [Web3 Examples](#web3-examples)
8. [Security Considerations](#security-considerations)

## Overview

The Manexus DEX is a Uniswap V2-based decentralized exchange with the following key components:

- **DexFactory** (`DexFactory.sol`): Creates and manages trading pairs
- **DexRouter** (`DexRouter.sol`): User-facing interface for all operations
- **DexPair** (`DexPair.sol`): Core AMM logic for individual trading pairs
- **WETH Integration**: Native ETH support via WETH wrapper

## Contract Addresses

> **Note**: These contracts are deployed on Arbitrum Sepolia testnet. Update addresses after deployment.

```solidity
// Example addresses (update with actual deployed addresses)
DexFactory: 0x...
DexRouter: 0x...
WETH: 0x...
```

## Token Swapping

### 1. Token-to-Token Swaps

#### Exact Input Swap
Swap an exact amount of input tokens for output tokens:

```solidity
function swapExactTokensForTokens(
    uint256 amountIn,           // Amount of input tokens
    uint256 amountOutMin,       // Minimum output tokens expected
    address[] calldata path,    // Token swap path [tokenA, tokenB]
    address to,                 // Recipient address
    uint256 deadline           // Transaction deadline
) external returns (uint256[] memory amounts);
```

**Example Usage:**
```solidity
// Swap 100 TokenA for TokenB (minimum 95 TokenB expected)
address[] memory path = new address[](2);
path[0] = tokenA_address;
path[1] = tokenB_address;

// Approve router to spend TokenA
IERC20(tokenA_address).approve(router_address, 100 * 10**18);

// Execute swap
router.swapExactTokensForTokens(
    100 * 10**18,      // 100 TokenA
    95 * 10**18,       // Minimum 95 TokenB
    path,
    msg.sender,        // Send to caller
    block.timestamp + 300  // 5 minute deadline
);
```

#### Exact Output Swap
Swap tokens to get an exact amount of output tokens:

```solidity
function swapTokensForExactTokens(
    uint256 amountOut,          // Exact amount of output tokens wanted
    uint256 amountInMax,        // Maximum input tokens willing to spend
    address[] calldata path,    // Token swap path
    address to,                 // Recipient address
    uint256 deadline           // Transaction deadline
) external returns (uint256[] memory amounts);
```

### 2. Multi-hop Swaps

For tokens without direct pairs, use multi-hop swaps through intermediate tokens (typically WETH):

```solidity
// Swap TokenA → WETH → TokenB
address[] memory path = new address[](3);
path[0] = tokenA_address;
path[1] = WETH_address;
path[2] = tokenB_address;

router.swapExactTokensForTokens(
    amountIn,
    amountOutMin,
    path,
    to,
    deadline
);
```

## Liquidity Provision

### 1. Add Liquidity (Token Pairs)

```solidity
function addLiquidity(
    address tokenA,             // First token address
    address tokenB,             // Second token address  
    uint256 amountADesired,     // Desired amount of tokenA
    uint256 amountBDesired,     // Desired amount of tokenB
    uint256 amountAMin,         // Minimum tokenA (slippage protection)
    uint256 amountBMin,         // Minimum tokenB (slippage protection)
    address to,                 // LP token recipient
    uint256 deadline           // Transaction deadline
) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
```

**Example:**
```solidity
// Add liquidity to TokenA/TokenB pair
// Approve both tokens first
IERC20(tokenA).approve(router_address, 1000 * 10**18);
IERC20(tokenB).approve(router_address, 2000 * 10**18);

// Add liquidity
router.addLiquidity(
    tokenA,
    tokenB,
    1000 * 10**18,     // 1000 TokenA desired
    2000 * 10**18,     // 2000 TokenB desired
    950 * 10**18,      // Minimum 950 TokenA (5% slippage)
    1900 * 10**18,     // Minimum 1900 TokenB (5% slippage)
    msg.sender,        // Receive LP tokens
    block.timestamp + 300
);
```

### 2. Remove Liquidity

```solidity
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,          // Amount of LP tokens to burn
    uint256 amountAMin,         // Minimum tokenA to receive
    uint256 amountBMin,         // Minimum tokenB to receive
    address to,                 // Token recipient
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB);
```

**Example:**
```solidity
// Remove liquidity from TokenA/TokenB pair
address pair = factory.getPair(tokenA, tokenB);

// Approve router to spend LP tokens
IERC20(pair).approve(router_address, lpTokenAmount);

// Remove liquidity
router.removeLiquidity(
    tokenA,
    tokenB,
    lpTokenAmount,     // LP tokens to burn
    minTokenA,         // Minimum tokenA expected
    minTokenB,         // Minimum tokenB expected
    msg.sender,        // Receive tokens
    block.timestamp + 300
);
```

## ETH Integration

The DEX supports native ETH through WETH wrapper functions:

### 1. ETH to Token Swaps

```solidity
function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,    // Must start with WETH
    address to,
    uint256 deadline
) external payable returns (uint256[] memory amounts);
```

**Example:**
```solidity
// Swap 1 ETH for TokenA
address[] memory path = new address[](2);
path[0] = WETH_address;
path[1] = tokenA_address;

router.swapExactETHForTokens{value: 1 ether}(
    minTokenAOut,      // Minimum tokens expected
    path,
    msg.sender,
    block.timestamp + 300
);
```

### 2. Token to ETH Swaps

```solidity
function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,    // Must end with WETH
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts);
```

### 3. ETH Liquidity Operations

```solidity
// Add ETH liquidity
function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

// Remove ETH liquidity  
function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) external returns (uint256 amountToken, uint256 amountETH);
```

## Price Queries

### 1. Get Swap Amounts

```solidity
// Get output amount for exact input
function getAmountsOut(uint256 amountIn, address[] memory path)
    public view returns (uint256[] memory amounts);

// Get input amount needed for exact output
function getAmountsIn(uint256 amountOut, address[] memory path) 
    public view returns (uint256[] memory amounts);
```

### 2. Quote Liquidity Ratios

```solidity
function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) 
    public pure returns (uint256 amountB);
```

### 3. Check Pair Reserves

```solidity
// Get reserves from pair contract
address pair = factory.getPair(tokenA, tokenB);
(uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast) = 
    DexPair(pair).getReserves();
```

## Web3 Examples

### JavaScript (ethers.js)

```javascript
const { ethers } = require('ethers');

// Contract setup
const provider = new ethers.JsonRpcProvider('YOUR_RPC_URL');
const signer = new ethers.Wallet('YOUR_PRIVATE_KEY', provider);
const router = new ethers.Contract(ROUTER_ADDRESS, routerABI, signer);
const tokenA = new ethers.Contract(TOKEN_A_ADDRESS, erc20ABI, signer);

// Swap tokens
async function swapTokens() {
    const amountIn = ethers.parseEther("100");
    const path = [TOKEN_A_ADDRESS, TOKEN_B_ADDRESS];
    
    // Approve router
    await tokenA.approve(ROUTER_ADDRESS, amountIn);
    
    // Get expected output
    const amounts = await router.getAmountsOut(amountIn, path);
    const amountOutMin = amounts[1] * 95n / 100n; // 5% slippage
    
    // Execute swap
    const deadline = Math.floor(Date.now() / 1000) + 300; // 5 minutes
    const tx = await router.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        path,
        signer.address,
        deadline
    );
    
    console.log('Swap transaction:', tx.hash);
    await tx.wait();
}

// Add liquidity
async function addLiquidity() {
    const amountADesired = ethers.parseEther("1000");
    const amountBDesired = ethers.parseEther("2000");
    
    // Approve both tokens
    await tokenA.approve(ROUTER_ADDRESS, amountADesired);
    await tokenB.approve(ROUTER_ADDRESS, amountBDesired);
    
    // Add liquidity with 5% slippage tolerance
    const deadline = Math.floor(Date.now() / 1000) + 300;
    const tx = await router.addLiquidity(
        TOKEN_A_ADDRESS,
        TOKEN_B_ADDRESS,
        amountADesired,
        amountBDesired,
        amountADesired * 95n / 100n, // 5% slippage
        amountBDesired * 95n / 100n, // 5% slippage
        signer.address,
        deadline
    );
    
    console.log('Add liquidity transaction:', tx.hash);
    await tx.wait();
}
```

### Python (web3.py)

```python
from web3 import Web3
import json

# Setup
w3 = Web3(Web3.HTTPProvider('YOUR_RPC_URL'))
account = w3.eth.account.from_key('YOUR_PRIVATE_KEY')

# Contract instances
router = w3.eth.contract(address=ROUTER_ADDRESS, abi=router_abi)
token_a = w3.eth.contract(address=TOKEN_A_ADDRESS, abi=erc20_abi)

def swap_tokens():
    amount_in = w3.to_wei(100, 'ether')
    path = [TOKEN_A_ADDRESS, TOKEN_B_ADDRESS]
    
    # Approve router
    approve_tx = token_a.functions.approve(ROUTER_ADDRESS, amount_in).build_transaction({
        'from': account.address,
        'nonce': w3.eth.get_transaction_count(account.address),
        'gas': 100000,
        'gasPrice': w3.to_wei('20', 'gwei')
    })
    
    signed_approve = w3.eth.account.sign_transaction(approve_tx, account.key)
    w3.eth.send_raw_transaction(signed_approve.rawTransaction)
    
    # Execute swap
    amounts = router.functions.getAmountsOut(amount_in, path).call()
    amount_out_min = amounts[1] * 95 // 100  # 5% slippage
    
    deadline = w3.eth.get_block('latest')['timestamp'] + 300
    
    swap_tx = router.functions.swapExactTokensForTokens(
        amount_in,
        amount_out_min,
        path,
        account.address,
        deadline
    ).build_transaction({
        'from': account.address,
        'nonce': w3.eth.get_transaction_count(account.address),
        'gas': 200000,
        'gasPrice': w3.to_wei('20', 'gwei')
    })
    
    signed_swap = w3.eth.account.sign_transaction(swap_tx, account.key)
    tx_hash = w3.eth.send_raw_transaction(signed_swap.rawTransaction)
    
    print(f'Swap transaction: {tx_hash.hex()}')
```

## Security Considerations

### 1. Slippage Protection
Always set appropriate minimum amounts to protect against MEV attacks:

```solidity
// 5% slippage tolerance example
uint256 amountOutMin = expectedAmount * 95 / 100;
```

### 2. Deadline Protection
Use reasonable deadlines to prevent transactions from being executed at stale prices:

```solidity
uint256 deadline = block.timestamp + 300; // 5 minutes
```

### 3. Token Approvals
Only approve the exact amount needed for the transaction:

```solidity
// Approve exact amount instead of unlimited
token.approve(router, exactAmount);
```

### 4. Frontrunning Protection
- Use private mempools when available
- Consider using commit-reveal schemes for large trades
- Monitor for unusual price movements before executing

### 5. Smart Contract Risks
- Contracts are not audited - use at your own risk
- Test extensively on testnet before mainnet deployment
- Consider using established DEX protocols for production use

## Fee Structure

- **Trading Fee**: 0.3% (300 basis points) on all swaps
- **Protocol Fee**: Currently disabled (0%)
- **LP Rewards**: All trading fees go to liquidity providers

## Gas Optimization Tips

1. **Batch Operations**: Combine multiple operations when possible
2. **Path Optimization**: Use direct pairs instead of multi-hop when available  
3. **Gas Price**: Monitor network congestion and adjust gas prices
4. **Contract Size**: Use proxy patterns for large contracts

## Troubleshooting

### Common Errors

1. **"DEX: INSUFFICIENT_OUTPUT_AMOUNT"**
   - Increase slippage tolerance
   - Check if there's sufficient liquidity

2. **"DEX: EXPIRED"**
   - Increase deadline parameter
   - Resubmit transaction quickly

3. **"DEX: INSUFFICIENT_LIQUIDITY"**
   - Pool doesn't exist or has very low liquidity
   - Try different token pairs

4. **"DEX: IDENTICAL_ADDRESSES"**
   - Trying to create pair with same token twice
   - Check token addresses

### Getting Help

- Review the test files in `/test/` for working examples
- Check existing documentation in `/docs/`
- Examine contract source code in `/src/`

---

## Disclaimer

⚠️ **Warning**: These contracts are for development and testing purposes only. They have not been audited and should not be used in production without proper security review. Use at your own risk.