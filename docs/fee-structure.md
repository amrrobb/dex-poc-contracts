# DEX Fee Structure Documentation

## Current Implementation: V2 Single Fee Model

### Fee Rate
- **Trading Fee**: 0.3% (30 basis points)
- **Fee Distribution**: 100% to liquidity providers
- **Protocol Fee**: 0% (can be enabled later)

### Technical Implementation

The 0.3% fee is implemented in `DexPair.sol` during the swap function:

```solidity
function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external lock {
    // ... validation logic ...
    
    // Fee calculation: 0.3% = 3/1000
    uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
    uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
    
    // Ensure x*y=k invariant with fees
    require(balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * _reserve1 * (1000**2), "DEX: K");
}
```

### Fee Mechanism

1. **Input Amount**: User wants to swap X tokens
2. **Fee Deduction**: 0.3% fee is deducted from input
3. **Effective Input**: 99.7% of input goes to swap calculation
4. **LP Rewards**: 0.3% stays in pool, increasing LP token value

### Example Transaction

**Swap 1000 USDC for ETH:**
- Input: 1000 USDC
- Fee: 3 USDC (0.3%)
- Effective swap: 997 USDC → ETH
- LP benefit: Pool reserves increase by 3 USDC

## Comparison with Other DEXes

| DEX | Fee Structure | Notes |
|-----|---------------|-------|
| **Our DEX** | 0.3% fixed | Simple, predictable |
| **Uniswap V2** | 0.3% fixed | Same model |
| **Uniswap V3** | 0.01%, 0.05%, 0.3%, 1% | Multiple tiers |
| **SushiSwap** | 0.3% fixed | V2 fork |
| **Curve** | ~0.04% | Specialized for stablecoins |
| **Balancer** | 0.1% - 10% | Customizable |

## Fee Distribution

### Current Model (V2)
```
Trading Fee (0.3%)
└── 100% → Liquidity Providers
```

### Future Protocol Fee Option
```
Trading Fee (0.3%)
├── 83.3% → Liquidity Providers (0.25%)
└── 16.7% → Protocol Treasury (0.05%)
```

## Revenue Calculation

### For Liquidity Providers

**Daily Volume Example: $100,000**
- Daily fees collected: $300 (0.3%)
- Distributed to all LP tokens proportionally
- APR depends on total liquidity in pool

**Formula:**
```
LP Annual Return = (Daily Volume × 0.003 × 365) / Total Liquidity
```

### For Protocol (Future)

If protocol fee is enabled (0.05%):
```
Annual Protocol Revenue = Daily Volume × 0.0005 × 365
```

## Gas Optimization

The single fee tier reduces gas costs by:
- No fee tier selection logic
- Simplified routing calculations
- Single fee calculation per swap
- No complex fee distribution

## Future Enhancements

### Phase 1: Protocol Fee Toggle
```solidity
bool public protocolFeeOn;
address public feeTo;
uint256 public constant PROTOCOL_FEE = 5; // 0.05%
```

### Phase 2: Dynamic Fees
- Volume-based fee adjustments
- Time-based fee variations
- Governance-controlled fee updates

### Phase 3: Multiple Fee Tiers
- 0.05% for stable pairs
- 0.3% for standard pairs  
- 1% for exotic pairs

## Security Considerations

1. **Fee Precision**: Using basis points prevents rounding errors
2. **Integer Math**: All calculations use integers to avoid floating point
3. **Overflow Protection**: Checks prevent arithmetic overflow
4. **Reentrancy**: Lock modifier prevents reentrancy attacks

## Testing Fee Calculations

Example test cases in `test/DexPair.t.sol`:

```solidity
function testSwapFee() public {
    // Test 0.3% fee is correctly applied
    uint256 amountIn = 1000e18;
    uint256 expectedFee = 3e18; // 0.3%
    // ... test implementation
}
```

This documentation will be updated as fee structures evolve in future versions.