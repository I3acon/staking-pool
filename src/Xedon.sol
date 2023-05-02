//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "./erc721a/ERC721A.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Xedon is ERC721A, AccessControl {
    bytes32 public constant STAKER = keccak256("STAKER");
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721A("Xedon", "XEDON") {
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _tokenIds.increment();
    }

    function mint(address _to) public onlyRole(STAKER) {
        uint256 tokenid = _tokenIds.current();
        require(ownerOf(tokenid) != msg.sender, "Already minted");
        _mint(_to, tokenid);
        _tokenIds.increment();
    }

    function burn(uint256 _tokenId) public onlyRole(STAKER) {
        require(ownerOf(_tokenId) == msg.sender, "Not owner");
        _burn(_tokenId);
    }

    function giveAccess(address _to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(STAKER, _to);
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
        return super.ownerOf(_tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
