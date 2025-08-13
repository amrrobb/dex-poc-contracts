# DEX Smart Contracts

Solidity smart contracts for the Manexus DEX - a Uniswap V2-based decentralized exchange.

## 🚀 Features

- **Token Swapping**: AMM with constant product formula (x × y = k)
- **ETH Integration**: Native ETH support via WETH wrapper
- **Liquidity Provision**: Add/remove liquidity to earn 0.3% trading fees
- **Multiple Tokens**: Support for any ERC20 token pairs
- **Low Gas Costs**: Optimized V2 architecture
- **Comprehensive Testing**: 100% test coverage with 19 passing tests
- **Future-Ready**: Architecture designed for V3/V4 migration

## 🛠 Tech Stack

- **Solidity**: 0.8.20
- **Framework**: Foundry
- **Network**: Arbitrum Sepolia (testnet)
- **Dependencies**: OpenZeppelin Contracts

## 📁 Structure

```
smart-contracts/
├── src/
│   ├── core/          # Factory & Pair contracts
│   ├── periphery/     # Router contract  
│   ├── interfaces/    # IWETH interface
│   └── tokens/        # Mock ERC20 & WETH tokens
├── script/            # Deployment scripts
├── test/              # Contract tests (19 passing tests)
├── lib/               # Git submodules (OpenZeppelin, forge-std)
├── foundry.toml       # Foundry configuration
└── README.md
```

## ⚡ Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### 1. Clone & Install

```bash
git clone <this-repo>
cd smart-contracts
git submodule update --init --recursive  # Initialize submodules
forge install
```

### 2. Build & Test

```bash
forge build
forge test
```

### 3. Deploy to Arbitrum Sepolia

```bash
# Set environment variables
export PRIVATE_KEY=your_private_key
export ARBITRUM_SEPOLIA_RPC_URL=your_rpc_url
export ARBISCAN_API_KEY=your_api_key

# Deploy contracts
forge script script/Deploy.s.sol --rpc-url arbitrum_sepolia --broadcast --verify
```

## 📊 Contract Architecture

### Key Contracts

| Contract | Description |
|----------|-------------|
| `DexFactory` | Creates and manages trading pairs |
| `DexPair` | Core AMM logic with swap/mint/burn functions |
| `DexRouter` | User-facing interface for swaps and liquidity |
| `IWETH` | Interface for Wrapped ETH functionality |
| `MockWETH` | Test implementation of WETH for development |
| `MockERC20` | Test tokens for development |

### V2 AMM Implementation

- **Constant Product Formula**: x × y = k
- **Single Fee Tier**: 0.3% for all trading pairs
- **Full Range Liquidity**: Liquidity spread across all price ranges
- **Fungible LP Tokens**: ERC20 tokens representing pool shares

## 🔬 Testing

Comprehensive test suite with **19 passing tests** covering all functionality:

### Test Coverage
- **DexFactory**: 10 tests (pair creation, access control, validation)
- **DexPair**: 5 tests (liquidity, swaps, minimum liquidity protection)  
- **DexRouter**: 4 tests (token swaps, ETH integration, liquidity management)

### Run Tests
```bash
forge test                   # Run all 19 tests
forge test -vv               # Run with verbose output
forge test --summary         # Show test summary
forge test --match-test testCreatePair  # Run specific test
forge coverage               # Generate coverage report
```

### ETH Integration Tests
- ✅ ETH wrapping/unwrapping via MockWETH
- ✅ ETH-to-token swaps (`swapExactETHForTokens`)
- ✅ Token-to-ETH swaps (`swapExactTokensForETH`)
- ✅ ETH liquidity provision (`addLiquidityETH`)

## 🚨 Security

- ✅ Reentrancy protection (`ReentrancyGuard`)
- ✅ Integer overflow checks (Solidity 0.8+)
- ✅ Access control for admin functions
- ✅ Input validation and error handling
- ✅ Minimum liquidity protection against first depositor attacks
- ✅ ETH handling via secure WETH wrapper
- ⚠️ **Testnet only** - Not audited for mainnet

## 🏗️ Development Setup

### Git Submodules
Dependencies are managed as git submodules for better version control:

```bash
# Initialize submodules after cloning
git submodule update --init --recursive

# Update submodules to latest versions
git submodule update --remote --merge
```

### Dependencies
- `lib/forge-std` - Foundry testing framework
- `lib/openzeppelin-contracts` - Secure contract implementations

## 🔧 Configuration

Environment variables required for deployment:

```bash
PRIVATE_KEY=your_wallet_private_key
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ARBISCAN_API_KEY=your_arbiscan_api_key
```

## 📄 License

MIT License

---

Part of the [Manexus DEX POC](https://github.com/your-org/manexus-dex-poc) project.