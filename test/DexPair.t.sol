// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/core/DexFactory.sol";
import "../src/core/DexPair.sol";
import "../src/tokens/MockERC20.sol";

contract DexPairTest is Test {
    DexFactory factory;
    MockERC20 tokenA;
    MockERC20 tokenB;
    DexPair pair;
    
    function setUp() public {
        factory = new DexFactory(address(this));
        tokenA = new MockERC20("Token A", "TKNA", 18, 1000000);
        tokenB = new MockERC20("Token B", "TKNB", 18, 1000000);
        
        factory.createPair(address(tokenA), address(tokenB));
        pair = DexPair(factory.getPair(address(tokenA), address(tokenB)));
    }
    
    function testPairCreation() public {
        assertTrue(address(pair) != address(0));
        assertEq(pair.token0(), address(tokenA) < address(tokenB) ? address(tokenA) : address(tokenB));
        assertEq(pair.token1(), address(tokenA) < address(tokenB) ? address(tokenB) : address(tokenA));
    }
    
    function testAddLiquidity() public {
        uint256 amountA = 1000e18;
        uint256 amountB = 1000e18;
        
        tokenA.transfer(address(pair), amountA);
        tokenB.transfer(address(pair), amountB);
        
        uint256 liquidity = pair.mint(address(this));
        assertTrue(liquidity > 0);
        assertEq(pair.balanceOf(address(this)), liquidity);
    }
    
    function testBurnLiquidity() public {
        uint256 amountA = 1000e18;
        uint256 amountB = 1000e18;
        
        // Add liquidity first
        tokenA.transfer(address(pair), amountA);
        tokenB.transfer(address(pair), amountB);
        uint256 liquidity = pair.mint(address(this));
        
        // Transfer LP tokens to pair for burning
        pair.transfer(address(pair), liquidity);
        
        uint256 balanceABefore = tokenA.balanceOf(address(this));
        uint256 balanceBBefore = tokenB.balanceOf(address(this));
        
        (uint256 amount0, uint256 amount1) = pair.burn(address(this));
        
        assertTrue(amount0 > 0 && amount1 > 0);
        assertTrue(tokenA.balanceOf(address(this)) > balanceABefore);
        assertTrue(tokenB.balanceOf(address(this)) > balanceBBefore);
    }
    
    function testSwap() public {
        uint256 amountA = 1000e18;
        uint256 amountB = 1000e18;
        
        // Add liquidity first
        tokenA.transfer(address(pair), amountA);
        tokenB.transfer(address(pair), amountB);
        pair.mint(address(this));
        
        // Perform swap
        uint256 swapAmountIn = 10e18;
        tokenA.transfer(address(pair), swapAmountIn);
        
        uint256 balanceBBefore = tokenB.balanceOf(address(this));
        pair.swap(0, 9e18, address(this), "");
        
        assertTrue(tokenB.balanceOf(address(this)) > balanceBBefore);
    }
    
    function testMinimumLiquidity() public {
        uint256 amountA = 1000e18;
        uint256 amountB = 1000e18;
        
        tokenA.transfer(address(pair), amountA);
        tokenB.transfer(address(pair), amountB);
        
        uint256 liquidity = pair.mint(address(this));
        
        // Check that minimum liquidity was burned to 0xdead
        assertEq(pair.balanceOf(address(0xdead)), 1000);
        // Total supply should be liquidity + minimum
        assertEq(pair.totalSupply(), liquidity + 1000);
    }
}