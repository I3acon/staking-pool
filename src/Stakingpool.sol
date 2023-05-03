//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IETHlaunchpad.sol";
import "forge-std/console.sol";
import "./Xedon.sol";

contract Stakingpool is AccessControl {
    mapping(address => bool) private stakers;
    mapping(address => uint256) public balances;
    mapping(uint256 => uint256) public tokenid_balances;
    uint256 public prev_balances = 0;
    bool public isUpload = false;
    bool public isDeposit = false;

    IETHlaunchpad internal launchpad;
    Xedon internal token;
    bytes public pubkey;
    bytes public withdrawal_credentials;
    bytes public signature;
    bytes32 public deposit_data_root;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor(address _launchpad, address _token) {
        console.log(_launchpad);
        require(_launchpad != address(0), "Invalid launchpad address");
        require(_token != address(0), "Invalid token address");
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        launchpad = IETHlaunchpad(_launchpad);
        token = Xedon(_token);
    }

    function uploadDepositData(
        bytes calldata _pubkey,
        bytes calldata _withdrawal_credentials,
        bytes calldata _signature,
        bytes32 _deposit_data_root
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes memory credFromAdr = _toWithdrawalCred(address(this));
        require(
            keccak256(credFromAdr) == keccak256(_withdrawal_credentials),
            "Invalid withdrawal credentials"
        );
        pubkey = _pubkey;
        withdrawal_credentials = _withdrawal_credentials;
        signature = _signature;
        deposit_data_root = _deposit_data_root;
        isUpload = true;
    }

    function stake() public payable {
        require(msg.value == 8 ether, "Amount must be equal to 8 ETH");
        require(isUpload);
        require(!isDeposit, "Already deposit");
        balances[msg.sender] += msg.value;
        stakers[msg.sender] = true;
        token.mint(msg.sender);

        if (address(this).balance == 32 ether) {
            depositToLaunchpad();
        }
        emit Deposit(msg.sender, msg.value);
    }

    function _toWithdrawalCred(address a) public pure returns (bytes memory) {
        uint uintFromAddress = uint256(uint160(a));
        bytes memory withdralDesired = abi.encodePacked(
            uintFromAddress +
                0x0100000000000000000000000000000000000000000000000000000000000000
        );
        return withdralDesired;
    }

    function withdraw(uint256 _tokenid) public {
        require(msg.sender == token.ownerOf(_tokenid), "Not owner of token");
        require(isDeposit, "Not deposit yet");
        uint256 pool_amount = address(this).balance;
        uint256 left_over = pool_amount - prev_balances;
        uint256 share = (left_over) / 4;
        tokenid_balances[1] += share;
        tokenid_balances[2] += share;
        tokenid_balances[3] += share;
        tokenid_balances[4] += share;
        uint256 user_share = tokenid_balances[_tokenid];
        payable(token.ownerOf(_tokenid)).transfer(user_share);
        tokenid_balances[_tokenid] = 0;
        prev_balances = address(this).balance;
        emit Withdraw(token.ownerOf(_tokenid), user_share);
    }

    function depositToLaunchpad() public {
        launchpad.deposit{value: 32 ether}(
            pubkey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
        isDeposit = true;
    }

    // This function is used for testing purpose only
    function rugpool() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}
