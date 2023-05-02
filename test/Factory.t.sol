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

    function setUp() public {
        factory = new Factory(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b);
        // goerliFork = vm.createFork(GOERLI_URL);
    }

    // function testFork() public {
    //     vm.selectFork(goerliFork);
    //     emit log_uint(block.chainid);
    //     assertEq(vm.activeFork(), goerliFork);
    // }

    function testCreatePool() public {
        factory.createPool();
    }

    function testUploadData() public {
        token = new Xedon();
        stakingpool = new Stakingpool(
            payable(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b),
            address(token)
        );
        bytes
            memory pubkey = hex"84bf1094cec37dc1f990956718f4bdcaa4d85d11398e18e870b13993b21f19df75f10fa0b769c9a704b3bd5bc4b87e06";
        bytes
            memory withdrawal_credent = hex"010000000000000000000000f62849f9a0b5bf2913b396098f7c7019b51a820a";
        bytes
            memory sig = hex"a0e6950e9373b1a7b30ca923ba0e1ca06afaaca64650a34d891f75c9cc76995c3b88efdb22a74be4c9b59d2918993ac30f114aebd0e360505eda81348611ed5ab0b4edea11b5334f27c4c1475bcf7a6d9daa5a16c27d8ade863781456d95bd42";
        bytes32 deposit_data_root = 0xd56eaadba77aaee1bcc9edc08e204a1b6777bb85523bcc257f8c208e1386e5d8;
        stakingpool.uploadDepositData(
            pubkey,
            withdrawal_credent,
            sig,
            deposit_data_root
        );

        // stakingpool._toWithdrawalCred(address(stakingpool));

        // console.log(keccak256(stakingpool._toWithdrawalCred(address(stakingpool))));
        // console.log(string(keccak256(withdrawal_credent)));
        // console.log(
        //     keccak256(stakingpool._toWithdrawalCred(address(stakingpool))) ==
        //         keccak256(withdrawal_credent)
        // );
    }

    // function testBalance()public {
    //     vm.Prank(alice);
    // }

    // function testStrToBytes(string memory _str) public view returns (bytes32) {
    //     _str = "hello this is sound from dekwat";
    //     bytes32 result = factory.stringToBytes32(_str);
    //     return result;
    // }

    // function testCreateTokenReturnPoolAdr() public {
    //     bytes32 salt = factory.stringToBytes32(
    //         "hello this is sound from dekwat"
    //     );
    //     address launchpad = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
    //     factory.createToken(salt, launchpad);
    //     address token = factory.tokens(1);
    //     bytes memory bytecode = factory.getBytecode(launchpad, token);
    //     address predicted = factory.getAddress(bytecode, salt);
    //     factory.toWithdrawalCred(predicted);
    // }
}
