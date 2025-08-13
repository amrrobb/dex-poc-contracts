# AMM & CLAMM Mathematical Documentation

## 1. Constant Product AMM (V2 - Current Implementation)

### Core Formula: x × y = k

The fundamental invariant that governs all trades and liquidity operations.

**Where:**
- `x` = Reserve of Token A
- `y` = Reserve of Token B  
- `k` = Constant product (invariant)

### Mathematical Properties

#### 1.1 Price Discovery
```
Price of Token A = y/x
Price of Token B = x/y
```

#### 1.2 Swap Calculation
Given input amount `Δx`, output amount `Δy` is calculated as:

```
Before trade: x × y = k
After trade: (x + Δx) × (y - Δy) = k

Therefore: Δy = y - (k / (x + Δx))
Simplified: Δy = (y × Δx) / (x + Δx)
```

#### 1.3 With Trading Fees (0.3%)
```
Effective input = Δx × 0.997 (after 0.3% fee)
Δy = (y × Δx × 0.997) / (x + Δx × 0.997)
```

**Code Implementation:**
```solidity
// In DexRouter.sol
function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
    public pure returns (uint256 amountOut)
{
    uint256 amountInWithFee = amountIn * 997; // 0.3% fee
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = (reserveIn * 1000) + amountInWithFee;
    amountOut = numerator / denominator;
}
```

### 1.4 Liquidity Mathematics

#### Initial Liquidity Provision
```
L₀ = √(x × y) - MINIMUM_LIQUIDITY
```

**Where:**
- `L₀` = Initial LP tokens minted
- `MINIMUM_LIQUIDITY = 1000` (burned to prevent manipulation)

#### Subsequent Liquidity Additions
```
New LP tokens = min(
    (Δx × Total_LP_Supply) / x_reserves,
    (Δy × Total_LP_Supply) / y_reserves
)
```

#### Liquidity Removal
```
Token A returned = (LP_tokens_burned × x_reserves) / Total_LP_Supply
Token B returned = (LP_tokens_burned × y_reserves) / Total_LP_Supply
```

### 1.5 Slippage Analysis

#### Price Impact
```
Price Impact = (Δy_actual - Δy_ideal) / Δy_ideal × 100%

Where:
Δy_ideal = current_price × Δx (linear approximation)
Δy_actual = AMM calculated output
```

#### Slippage for Large Orders
For input amount `Δx`:
```
Slippage ≈ Δx / (2x) × 100% (approximation for small trades)
```

## 2. Concentrated Liquidity AMM (CLAMM - V3 Future)

### 2.1 Tick-Based Price Ranges

Instead of `x × y = k` across all prices, liquidity is concentrated in specific ranges.

#### Tick Mathematics
```
Price(i) = 1.0001^i

Where i is the tick index
```

**Example Ticks:**
- Tick 0: Price = 1.0000
- Tick 100: Price = 1.0100503
- Tick -100: Price = 0.9900498

#### 2.2 Virtual Reserves in Active Range

For liquidity concentrated between ticks `i` and `j`:

```
x_virtual = L / √P_current
y_virtual = L × √P_current

Where:
L = Real liquidity amount
P_current = Current price
```

#### 2.3 CLAMM Swap Formula

Within an active tick range:
```
Δy = Δ√P × L

Where:
Δ√P = √P_new - √P_old
L = Liquidity in the range
```

#### 2.4 Multiple Fee Tiers

V3 supports multiple fee tiers with different tick spacings:

| Fee Tier | Tick Spacing | Price Increment |
|----------|--------------|-----------------|
| 0.01% | 1 | 0.01% per tick |
| 0.05% | 10 | 0.1% per tick |
| 0.30% | 60 | 0.6% per tick |
| 1.00% | 200 | 2% per tick |

### 2.5 Position Mathematics

#### Individual Position Value
```
Position Value = (L × (√P - √P_a)) / √P + L × (√P_b - √P)

Where:
L = Position liquidity
P_a = Lower price bound
P_b = Upper price bound  
P = Current price
```

#### Capital Efficiency
```
Capital Efficiency = Price_Range_Width / Full_Range_Width

V2 efficiency = 1 (full range)
V3 efficiency = up to 4000x (narrow ranges)
```

## 3. Mathematical Comparisons

### 3.1 Capital Utilization

**V2 (Current):**
```
Utilization = Active_Liquidity / Total_Liquidity ≈ 0.5% - 2%
```

**V3 (Future):**
```
Utilization = Active_Liquidity / Total_Liquidity ≈ 50% - 100%
```

### 3.2 Impermanent Loss

#### V2 Impermanent Loss
```
IL = 2√(P_ratio) / (1 + P_ratio) - 1

Where P_ratio = P_final / P_initial
```

#### V3 Impermanent Loss
More complex - depends on time spent outside position range:

```
IL_v3 = IL_v2 × Range_Utilization_Factor
```

### 3.3 Fee Yield Comparison

**V2 Fee APR:**
```
APR = (Daily_Volume × 0.003 × 365) / Total_Liquidity
```

**V3 Fee APR:**
```
APR = (Daily_Volume × Fee_Rate × 365) / Active_Liquidity
Higher due to concentrated liquidity
```

## 4. Implementation Considerations

### 4.1 Precision and Rounding

**V2 (Current):**
- Uses 18 decimal precision
- Simple integer arithmetic
- Minimal rounding errors

**V3 (Future):**
- Requires high-precision sqrt calculations
- Complex tick arithmetic
- Potential precision loss in tick conversions

### 4.2 Gas Complexity

**V2 Operations:**
```
Swap: O(1) - Simple calculation
Add Liquidity: O(1) - Proportional math
Remove Liquidity: O(1) - Proportional math
```

**V3 Operations:**
```
Swap: O(log n) - May cross multiple ticks
Add Liquidity: O(1) - Range specific
Remove Liquidity: O(1) - Range specific
```

## 5. Migration Mathematics

### 5.1 Converting V2 to V3 Positions

For migrating V2 LP position to V3:

```
V2_LP_Value = (LP_tokens / Total_LP) × Pool_TVL
V3_Range_Selection = User_Defined_Range
V3_Position_Size = V2_LP_Value / Range_Width_Factor
```

### 5.2 Price Range Optimization

Optimal range width for V3 positions:
```
Optimal_Range = f(Volatility, Fee_Tier, Rebalancing_Cost)

Generally:
High volatility → Wider range
High fees → Narrower range  
High gas costs → Wider range
```

## 6. Code Examples

### 6.1 Current V2 Implementation

```solidity
// x * y = k invariant check
require(
    balance0Adjusted * balance1Adjusted >= 
    uint256(_reserve0) * _reserve1 * (1000**2), 
    "DEX: K"
);
```

### 6.2 Future V3 Tick Calculations

```solidity
// Placeholder for V3 implementation
function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160) {
    // Complex mathematical implementation
    // Returns sqrt(1.0001^tick) * 2^96
}

function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24) {
    // Inverse calculation for price to tick conversion
}
```

## Conclusion

The V2 constant product formula provides a mathematically elegant and simple foundation for our DEX. The transition to V3's concentrated liquidity will require significant mathematical complexity but offers superior capital efficiency.

This mathematical foundation ensures our DEX can handle:
- ✅ Accurate price discovery
- ✅ Fair liquidity rewards  
- ✅ Minimal slippage for appropriate trade sizes
- ✅ Future upgrade to advanced AMM models