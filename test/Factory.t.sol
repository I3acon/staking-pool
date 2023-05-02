//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/Factory.sol";
import "../src/Stakingpool.sol";

contract FactoryTest is Test {
    Factory public factory;
    uint256 goerliFork;
    string GOERLI_URL = vm.envString("GOERLI_URL");


    function setUp() public {
        factory = new Factory(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b);
        goerliFork = vm.createFork(GOERLI_URL);
    }

    function testFork()public{
        vm.selectFork(goerliFork);
        emit log_uint(block.chainid);
        assertEq(vm.activeFork(), goerliFork); 
    }

    function testCreatePool() public {
        factory.createPool();
    }

    function  testUploadData() public {

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
