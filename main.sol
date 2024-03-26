// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BalancerFlashLoan.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract main {

    address public constant vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; 
    address public constant keeper = 0x3a3eE61F7c6e1994a2001762250A5E17B2061b6d;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(address(0));

    IERC20  token0 = IERC20(0x03ab458634910AaD20eF5f1C8ee96F1D6ac54919);
    IERC20  token1 = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory
    ) external {
        work(); 
        
        for (uint256 i; i < tokens.length; ) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            
            disadvantage(token, amount);

            console.log("borrowed amount:", amount);
            uint256 feeAmount = feeAmounts[i];
            console.log("flashloan fee: ", feeAmount);

            // Return loan
            token.transfer(vault, amount);

            unchecked {
                ++i;
            }
        }
    }

    function flashLoan() external {
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);

        tokens[0] = token1;
        amounts[0] = 100_001 ether;
        
        token1.approve(address(uniswapV2Router), type(uint256).max);
        token0.approve(address(uniswapV2Router), type(uint256).max);

    
        //how many jumps of work you need
        uint interactions = 1;
        for(uint i; i < interactions; ){
            IBalancerVault(vault).flashLoan(
                IFlashLoanRecipient(address(this)),
                tokens,
                amounts,
                ""
            );

            unchecked {
                ++i;
            }
        } 
    }

    function work() public {

        // uniswapV2Router.addLiquidity();







    }

    function disadvantage(IERC20 token, uint256 amount) internal {
        uint256 currentAmount = token.balanceOf(address(this));

        if(currentAmount < amount) {
            uint256 missingQuantity = amount - currentAmount;

            token.transferFrom(keeper, address(this), missingQuantity);
        }
    }





}
