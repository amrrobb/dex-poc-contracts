// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/core/DexFactory.sol";
import "../src/periphery/DexRouter.sol";
import "../src/tokens/MockERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Factory
        DexFactory factory = new DexFactory(deployer);
        console.log("Factory deployed to:", address(factory));

        // Deploy mock WETH (using MockERC20)
        MockERC20 weth = new MockERC20("Wrapped Ether", "WETH", 18, 1000000);
        console.log("WETH deployed to:", address(weth));

        // Deploy Router
        DexRouter router = new DexRouter(address(factory), address(weth));
        console.log("Router deployed to:", address(router));

        // Deploy test tokens
        MockERC20 tokenA = new MockERC20("Token A", "TKNA", 18, 1000000);
        MockERC20 tokenB = new MockERC20("Token B", "TKNB", 18, 1000000);
        
        console.log("Token A deployed to:", address(tokenA));
        console.log("Token B deployed to:", address(tokenB));

        // Create initial pair
        factory.createPair(address(tokenA), address(tokenB));
        address pair = factory.getPair(address(tokenA), address(tokenB));
        console.log("Pair created:", pair);

        vm.stopBroadcast();

        // Save deployment addresses
        string memory deploymentInfo = string(abi.encodePacked(
            "FACTORY_ADDRESS=", vm.toString(address(factory)), "\n",
            "ROUTER_ADDRESS=", vm.toString(address(router)), "\n",
            "WETH_ADDRESS=", vm.toString(address(weth)), "\n",
            "TOKEN_A_ADDRESS=", vm.toString(address(tokenA)), "\n",
            "TOKEN_B_ADDRESS=", vm.toString(address(tokenB)), "\n",
            "PAIR_ADDRESS=", vm.toString(pair)
        ));
        
        vm.writeFile(".env.deployment", deploymentInfo);
        console.log("Deployment addresses saved to .env.deployment");
    }
}