//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/Stakingpool.sol";
import "../src/Xedon.sol";

contract FactoryTest is Test {
    Factory public factory;
    Stakingpool public stakingpool;
    Xedon public token;
    uint256 goerliFork;
    string GOERLI_URL = vm.envString("GOERLI_URL");
    address payable public alice =
        payable(0x01a56263e8c5B3F51a8a2fD37faa463523C1d604);
    address payable public bob =
        payable(0x02a6CBf724be0824c8f6E764D34F495Ccf62A98d);
    address payable public carol =
        payable(0x03ab15f59fb568Ce901cB1e0f6C11e7DDd53B535);
    address payable public david =
        payable(0x04ab67759693c0b7cCBE4fF219777c911a4b9541);

    function setUp() public {
        factory = new Factory(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b);
        // goerliFork = vm.createFork(GOERLI_URL);
        // vm.selectFork(goerliFork);
    }

    // function testFork() public {
    //     emit log_uint(block.chainid);
    //     assertEq(vm.activeFork(), goerliFork);
    // }

    function testCreatePool() public {
        factory.createPool();
    }

    function testStakingpool() public {
        vm.record();
        goerliFork = vm.createFork(GOERLI_URL);
        vm.selectFork(goerliFork);

        // alice create token and pool and stake
        startHoax(alice);
        token = new Xedon();
        stakingpool = new Stakingpool(
            payable(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b),
            address(token)
        );
        token.giveAccess(address(stakingpool));
        bytes
            memory pubkey = hex"84bf1094cec37dc1f990956718f4bdcaa4d85d11398e18e870b13993b21f19df75f10fa0b769c9a704b3bd5bc4b87e06";
        bytes
            memory withdrawal_credent = hex"010000000000000000000000afcca70fde030f521ed7ab99bfa80749ceeeb8be";
        bytes
            memory sig = hex"8a1587f908664ee1360951525cfbe196ca699d17e2a211307119e556595b8bc0a31329727a15b61eeb49dbdaa8edce4607cd3e74890773fd1c2e3c0d4283d048b3fb9610f692806a3a00cad424116fb894f085eb65a481fe645def2fb8e4e413";
        bytes32 deposit_data_root = 0x39811f3ff5ee67efe8d91312c08bef0933196a11528a19e74b521086ca143107;
        stakingpool.uploadDepositData(
            pubkey,
            withdrawal_credent,
            sig,
            deposit_data_root
        );
        stakingpool.stake{value: 8 ether}();
        assertEq(address(stakingpool).balance, 8 ether);
        assertEq(token.ownerOf(1), alice);
        vm.stopPrank();

        // bob stake
        startHoax(bob);
        stakingpool.stake{value: 8 ether}();
        assertEq(address(stakingpool).balance, 16 ether);
        assertEq(token.ownerOf(2), bob);
        vm.stopPrank();

        // carol stake
        hoax(carol);
        stakingpool.stake{value: 8 ether}();
        assertEq(address(stakingpool).balance, 24 ether);
        assertEq(token.ownerOf(3), carol);

        // david stake and withdraw
        startHoax(david);
        stakingpool.stake{value: 8 ether}();
        assertEq(token.ownerOf(4), david);

        //assume reward is 1 ether
        assertEq(address(stakingpool).balance, 0);
        payable(address(stakingpool)).transfer(1 ether);
        assertEq(address(stakingpool).balance, 1 ether);

        stakingpool.withdraw(4);
        assertEq(address(stakingpool).balance, 750000000000000000);
        stakingpool.withdraw(4);
        assertEq(address(stakingpool).balance, 750000000000000000);
        vm.stopPrank();

        // carol withdraw
        vm.startPrank(carol);
        stakingpool.withdraw(3);
        assertEq(address(stakingpool).balance, 500000000000000000);
        vm.stopPrank();

        // bob withdraw
        vm.startPrank(bob);
        stakingpool.withdraw(2);
        assertEq(address(stakingpool).balance, 250000000000000000);
        vm.stopPrank();

        // alice withdraw
        vm.startPrank(alice);
        stakingpool.withdraw(1);
        assertEq(address(stakingpool).balance, 0);
        vm.stopPrank();
    }
}
