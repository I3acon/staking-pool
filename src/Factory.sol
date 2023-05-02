//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "./Stakingpool.sol";
import "./Xedon.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Factory {
    address internal launchpad;

    using Counters for Counters.Counter;
    Counters.Counter private _poolIds;

    event PoolCreated(uint poolId, address indexed pool, address indexed token);

    constructor(address _launchpad) {
        launchpad = _launchpad;
        _poolIds.increment();
    }

    function createPool() public {
        Xedon token = new Xedon();
        console.log(launchpad);
        Stakingpool pool = new Stakingpool(launchpad,address(token));
        uint256 poolId = _poolIds.current();
        emit PoolCreated(poolId, address(pool), address(token));
        _poolIds.increment();
    }
    
}
