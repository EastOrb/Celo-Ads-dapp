// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CeloAds {
    address public owner;
    uint public adSpaceId;
    uint public adSpacePrice;
    mapping (uint => AdSpace) public adSpaces;

    struct AdSpace {
        address adSpaceOwner;
        uint price;
        bool isAvailable;
    }

    event AdSpaceRegistered(uint adSpaceId, address indexed adSpaceOwner, uint price);
    event AdSpacePurchased(uint adSpaceId, address indexed buyer);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    function registerAdSpace(uint _price) external {
        adSpaceId++;
        adSpaces[adSpaceId] = AdSpace(msg.sender, _price, true);
        emit AdSpaceRegistered(adSpaceId, msg.sender, _price);
    }

    function purchaseAdSpace(uint _adSpaceId) external payable {
        AdSpace memory adSpace = adSpaces[_adSpaceId];
        require(adSpace.isAvailable, "Ad space is not available for purchase.");
        require(msg.value == adSpace.price, "Incorrect amount sent for ad space purchase.");

        adSpaces[_adSpaceId].isAvailable = false;
        adSpaces[_adSpaceId].adSpaceOwner = msg.sender;
        emit AdSpacePurchased(_adSpaceId, msg.sender);
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
