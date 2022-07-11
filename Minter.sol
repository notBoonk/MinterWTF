// SPDX-License-Identifier: Unlicense

//   __  __ _       _                     _    __ 
//  |  \/  (_)     | |                   | |  / _|
//  | \  / |_ _ __ | |_ ___ _ ____      _| |_| |_ 
//  | |\/| | | '_ \| __/ _ \ '__\ \ /\ / / __|  _|
//  | |  | | | | | | ||  __/ |_  \ V  V /| |_| |  
//  |_|  |_|_|_| |_|\__\___|_(_)  \_/\_/  \__|_|  

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Minter is Ownable {

    modifier isAllowed {
        require(Allowed[msg.sender] || msg.sender == owner());
        _;
    }

    // Variables

    struct TokenTransfer {
        uint256 minterId;
        uint256[] tokenIds;
    }

    mapping(address => bool) public Allowed;
    mapping(address => SubMinter[]) public Minters;

    uint256 public salePrice  = 1000000000000000000;
    bool public saleActive = false;

    // Owner Functions

    function spawnMintersAdmin(address[] memory _users, uint256[] memory _qtys) external onlyOwner {
        uint256 usersLength = _users.length;

        for (uint256 i; i < usersLength; i++) {
            address user = _users[i];
            uint256 qty = _qtys[i];

            SubMinter[] storage minters = Minters[user];

            for (uint256 x; x < qty; x++) {
                SubMinter minter = new SubMinter(user);
                minters.push(minter);
            }

            Allowed[user] = !Allowed[user];
            Minters[user] = minters;
        }
    }

    function destroy() external onlyOwner {
        address payable addr = payable(msg.sender);
        selfdestruct(addr);
    }

    function withdrawEther() external onlyOwner {
        address payable addr = payable(msg.sender);
        addr.transfer(address(this).balance);
    }

    function setAllowed(address _user) external onlyOwner {
        Allowed[_user] = !Allowed[_user];
    }

    function setSalePrice(uint256 _price) external onlyOwner {
        salePrice = _price;
    }

    function toggleSaleActive() external onlyOwner {
        saleActive = !saleActive;
    }

    // Read Functions

    function getMintersByUser(address _user) external view returns(SubMinter[] memory) {
        return Minters[_user];
    }

    // Main Functions

    function buy() external payable {
        require(saleActive);
        require(!Allowed[msg.sender]);
        require(msg.value == salePrice);

        Allowed[msg.sender] = true;
    }

    function spawnMinters(uint256 _qty) external isAllowed {
        SubMinter[] storage minters = Minters[msg.sender];

        for (uint256 i; i < _qty; i++) {
            SubMinter minter = new SubMinter(msg.sender);
            minters.push(minter);
        }

        Minters[msg.sender] = minters;
    }

    function destroyMinters() external isAllowed {
        SubMinter[] storage minters = Minters[msg.sender];
        uint256 mintersLength = minters.length;

        for (uint256 x = 0; x < mintersLength; x++) {
            minters[x].destroy();
        }
        delete Minters[msg.sender];
    }

    function drainMinters() external isAllowed {
        SubMinter[] storage minters = Minters[msg.sender];
        uint256 mintersLength = minters.length;

        for (uint256 x = 0; x < mintersLength; x++) {
            if (address(minters[x]).balance > 0) {
                minters[x].drainEther();
            }
        }
    }

    function transferTokens(address _tokenAddress, address _receiver, TokenTransfer[] memory _tokenTransfers) external isAllowed {
        SubMinter[] memory minters = Minters[msg.sender];
        uint256 transferLength = _tokenTransfers.length;

        for (uint256 x; x < transferLength; x++) {
            uint256 minterId = _tokenTransfers[x].minterId;
            uint256[] memory tokenIds = _tokenTransfers[x].tokenIds;
            uint256 tokenIdsLength = tokenIds.length;

            for (uint256 y; y < tokenIdsLength; y++) {
                minters[minterId].transferToken(_tokenAddress, tokenIds[y], _receiver);
            }
        }
    }
    
    function mint(address _target, uint256 _cost, bytes memory _data, uint256 _iterations, uint256 _minters) external payable isAllowed {
        require(_minters <= Minters[msg.sender].length);

        SubMinter[] memory userMinters = Minters[msg.sender];
        for (uint256 i; i < _minters; i++) {
            userMinters[i].mint{value: _cost}(_iterations, _target, _cost, _data);
        }
    }

}

contract SubMinter is Ownable, IERC721Receiver {

    // [REDACTED]

}