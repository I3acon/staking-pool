//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "./Stakingpool.sol";
import "./Xedon.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Factory {
    address[] public pools;
    mapping(uint256 => address) public tokens;
    mapping(address => uint256) public poolId;
    mapping(uint256 => address) public predictedPool;

    Xedon public Itoken;

    using Counters for Counters.Counter;
    Counters.Counter private _poolIds;

    event PoolCreated(uint poolId, address indexed pool, address indexed token);
    event TokenCreated(address indexed token, address indexed pool);
    event Deployed(address addr, uint salt);

    constructor() {
        _poolIds.increment();
    }

    function getBytecode(
        address _launchpad,
        address _token
    ) public pure returns (bytes memory) {
        bytes memory bytecode = type(Stakingpool).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_launchpad, _token));
    }

    function getAddress(
        bytes memory bytecode,
        bytes32 _salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );
        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    function createToken(bytes32 _salt, address _lauchpad) public {
        Xedon token = new Xedon();
        address predicted = getAddress(
            getBytecode(_lauchpad, address(token)),
            _salt
        );
        tokens[_poolIds.current()] = address(token);
        poolId[address(token)] = _poolIds.current();
        predictedPool[_poolIds.current()] = predicted;
        _poolIds.increment();
        emit TokenCreated(address(token), predicted);
    }

    function stringToBytes32(
        string memory str
    ) public pure returns (bytes32 result) {
        bytes memory temp = bytes(str);
        if (temp.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(temp, 32))
        }
    }

    function createPool(
        address _launchpad,
        address _token,
        bytes32 _salt,
        bytes memory _pubkey,
        bytes memory _withdrawal_credentials,
        bytes memory _signature,
        bytes32 _deposit_data_root
    ) public {
        // bytes memory bytecode = getBytecode(_launchpad, _token);
        // address predicted = getAddress(bytecode, _salt);
        // require(
        //     keccak256(toWithdrawalCred(predicted)) ==
        //         keccak256(_withdrawal_credentials),
        //     "Invalid withdrawal credentials"
        // );
        Stakingpool pool = new Stakingpool{salt: _salt}(
            _launchpad,
            _token,
            _pubkey,
            _withdrawal_credentials,
            _signature,
            _deposit_data_root
        );
        uint256 id = poolId[_token];
        emit PoolCreated(id, address(pool), _token);
    }

    function toWithdrawalCred(
        address _withdrawal
    ) public pure returns (bytes memory) {
        uint uintFromAddress = uint256(uint160(_withdrawal));
        bytes memory withdralDesired = abi.encodePacked(
            uintFromAddress +
                0x0100000000000000000000000000000000000000000000000000000000000000
        );
        return withdralDesired;
    }
}
