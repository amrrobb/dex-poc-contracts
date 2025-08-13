// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/core/DexFactory.sol";
import "../src/core/DexPair.sol";
import "../src/tokens/MockERC20.sol";

contract DexFactoryTest is Test {
    DexFactory factory;
    MockERC20 tokenA;
    MockERC20 tokenB;
    address feeToSetter = address(0x1);
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    
    function setUp() public {
        factory = new DexFactory(feeToSetter);
        tokenA = new MockERC20("Token A", "TKNA", 18, 1000000);
        tokenB = new MockERC20("Token B", "TKNB", 18, 1000000);
    }
    
    function testFactoryDeployment() public view {
        assertEq(factory.feeToSetter(), feeToSetter);
        assertEq(factory.feeTo(), address(0));
        assertEq(factory.allPairsLength(), 0);
    }
    
    function testCreatePair() public {
        address pair = factory.createPair(address(tokenA), address(tokenB));
        
        assertTrue(pair != address(0));
        assertEq(factory.allPairsLength(), 1);
        assertEq(factory.allPairs(0), pair);
        assertEq(factory.getPair(address(tokenA), address(tokenB)), pair);
        assertEq(factory.getPair(address(tokenB), address(tokenA)), pair);
    }
    
    function testCreatePairReverseOrder() public {
        address pair1 = factory.createPair(address(tokenA), address(tokenB));
        
        // Creating the same pair in reverse order should fail
        vm.expectRevert("DEX: PAIR_EXISTS");
        factory.createPair(address(tokenB), address(tokenA));
    }
    
    function testCreatePairFailsForIdenticalTokens() public {
        vm.expectRevert("DEX: IDENTICAL_ADDRESSES");
        factory.createPair(address(tokenA), address(tokenA));
    }
    
    function testCreatePairFailsForZeroAddress() public {
        vm.expectRevert("DEX: ZERO_ADDRESS");
        factory.createPair(address(0), address(tokenA));
    }
    
    function testCreatePairFailsForExistingPair() public {
        factory.createPair(address(tokenA), address(tokenB));
        
        vm.expectRevert("DEX: PAIR_EXISTS");
        factory.createPair(address(tokenA), address(tokenB));
    }
    
    function testSetFeeTo() public {
        address newFeeTo = address(0x2);
        
        vm.prank(feeToSetter);
        factory.setFeeTo(newFeeTo);
        
        assertEq(factory.feeTo(), newFeeTo);
    }
    
    function testSetFeeToFailsForUnauthorized() public {
        vm.expectRevert("DEX: FORBIDDEN");
        factory.setFeeTo(address(0x2));
    }
    
    function testSetFeeToSetter() public {
        address newFeeToSetter = address(0x3);
        
        vm.prank(feeToSetter);
        factory.setFeeToSetter(newFeeToSetter);
        
        assertEq(factory.feeToSetter(), newFeeToSetter);
    }
    
    function testSetFeeToSetterFailsForUnauthorized() public {
        vm.expectRevert("DEX: FORBIDDEN");
        factory.setFeeToSetter(address(0x3));
    }
}