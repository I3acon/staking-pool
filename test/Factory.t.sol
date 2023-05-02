//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/Factory.sol";

contract FactoryTest is Test {
    Factory public factory;
    uint256 goerliFork;
    string GOERLI_URL = vm.envString("GOERLI_URL");


    function setUp() public {
        factory = new Factory();
        goerliFork = vm.createFork(GOERLI_URL);
    }

    function testFork()public{
        vm.selectFork(goerliFork);
        emit log_uint(block.chainid);
        assertEq(vm.activeFork(), goerliFork); 
    }

    function testCreateToken() public {
        vm.startPrank(address(0x01))
        bytes32 salt = factory.stringToBytes32(
            "hello this is sound from dekwat"
        );
        address launchpad = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
        factory.createToken(salt, launchpad);
        address token = factory.tokens(1);
        bytes memory bytecode = factory.getBytecode(launchpad, token);
        address predicted = factory.getAddress(bytecode, salt);
        assertEq(predicted, token);
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

    function testCreatePool() public {
        bytes32 salt = factory.stringToBytes32(
            "hello this is sound from dekwat"
        );
        address launchpad = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
        factory.createToken(salt, launchpad);
        address token = 0x104fBc016F4bb334D775a19E8A6510109AC63E00;
        factory.getAddress(factory.getBytecode(launchpad, token), salt);
        bytes
            memory pubkey = "0x84bf1094cec37dc1f990956718f4bdcaa4d85d11398e18e870b13993b21f19df75f10fa0b769c9a704b3bd5bc4b87e06";
        bytes
            memory signature = "0xae440bd6d8fe806410c62a882d853ab2afc15a05c7f0372138b7f276a69028089e65fe2be018127090f883e1c3754447098b7dcf014c71fee5855567efa8ac89ef8129f5535f78a6af36e60d5ef74bea19f7c3774502997a241202b51f0da947";
        bytes32 deposit_data_root = 0x492d7d9ce701beffd5da73657afd7b2aa8eaad4a6dd88e3d4a0271deba792f34;
        bytes
            memory crend = "0x01000000000000000000000094e525b7c97d5f394c56c633562aa5ee7a2c5894";
        //  0x01000000000000000000000094e525b7c97d5f394c56c633562aa5ee7a2c5894
        factory.createPool(
            launchpad,
            token,
            salt,
            pubkey,
            crend,
            signature,
            deposit_data_root
        );
    }
}
