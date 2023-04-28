//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15; 

interface IETHlaunchpad{
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;
}