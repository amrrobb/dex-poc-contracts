// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/core/DexFactory.sol";
import "../src/core/DexPair.sol";
import "../src/periphery/DexRouter.sol";
import "../src/tokens/MockERC20.sol";
import "../src/tokens/MockWETH.sol";

contract DexRouterTest is Test {
    DexFactory factory;
    DexRouter router;
    MockWETH weth;
    MockERC20 tokenA;
    MockERC20 tokenB;
    MockERC20 tokenC;
    DexPair pair;

    address user = address(0x1);
    uint256 constant INITIAL_BALANCE = 10000e18;

    function setUp() public {
        factory = new DexFactory(address(this));
        weth = new MockWETH();
        router = new DexRouter(address(factory), address(weth));

        tokenA = new MockERC20("Token A", "TKNA", 18, INITIAL_BALANCE);
        tokenB = new MockERC20("Token B", "TKNB", 18, INITIAL_BALANCE);
        tokenC = new MockERC20("Token C", "TKNC", 18, INITIAL_BALANCE);

        // Transfer some tokens to user
        tokenA.transfer(user, 1000e18);
        tokenB.transfer(user, 1000e18);
        tokenC.transfer(user, 1000e18);

        // Create pair
        factory.createPair(address(tokenA), address(tokenB));
        pair = DexPair(factory.getPair(address(tokenA), address(tokenB)));
    }

    function testRouterDeployment() public view {
        assertEq(address(router.factory()), address(factory));
    }

    function testAddLiquidity() public {
        uint256 amountA = 100e18;
        uint256 amountB = 200e18;

        vm.startPrank(user);
        tokenA.approve(address(router), amountA);
        tokenB.approve(address(router), amountB);

        (uint256 actualAmountA, uint256 actualAmountB, uint256 liquidity) = router.addLiquidity(
            address(tokenA), address(tokenB), amountA, amountB, amountA, amountB, user, block.timestamp + 1
        );

        assertEq(actualAmountA, amountA);
        assertEq(actualAmountB, amountB);
        assertTrue(liquidity > 0);
        assertTrue(pair.balanceOf(user) > 0);
        vm.stopPrank();
    }

    function testAddLiquidityETH() public {
        uint256 tokenAmount = 100e18;
        uint256 ethAmount = 1 ether;

        vm.deal(user, 10 ether);
        vm.startPrank(user);

        tokenA.approve(address(router), tokenAmount);

        (uint256 actualTokenAmount, uint256 actualETHAmount, uint256 liquidity) = router.addLiquidityETH{
            value: ethAmount
        }(address(tokenA), tokenAmount, tokenAmount, ethAmount, user, block.timestamp + 1);

        assertEq(actualTokenAmount, tokenAmount);
        assertEq(actualETHAmount, ethAmount);
        assertTrue(liquidity > 0);
        vm.stopPrank();
    }

    function testSwapExactETHForTokens() public {
        // First add liquidity
        uint256 tokenAmount = 1000e18;
        uint256 ethAmount = 10 ether;

        vm.deal(user, 20 ether);
        vm.startPrank(user);

        tokenA.approve(address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(
            address(tokenA), tokenAmount, tokenAmount, ethAmount, user, block.timestamp + 1
        );

        // Now swap ETH for tokens
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(tokenA);

        uint256 balanceBefore = tokenA.balanceOf(user);

        router.swapExactETHForTokens{value: 1 ether}(0, path, user, block.timestamp + 1);

        assertTrue(tokenA.balanceOf(user) > balanceBefore);
        vm.stopPrank();
    }
}
