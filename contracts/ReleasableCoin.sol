// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./SimpleCoin.sol";
import "./Pausable.sol";
import "./Destructible.sol";

contract ReleasableCoin is SimpleCoin, Pausable, Destructible {
    bool public released = false;

    modifier isReleased() {
        if (!released) {
            revert();
        }
        _;
    }

    constructor(uint256 _initialSupply) public SimpleCoin(_initialSupply) {}

    function release() public onlyOwner {
        released = true;
    }

    function transfer(address _to, uint256 _amount)
        public
        isReleased
        whenNotPaused
    {
        super.transfer(_to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public isReleased whenNotPaused returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }
}
