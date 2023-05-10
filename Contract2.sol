// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title AdMarketplace Contract
/// @notice This contract is used to create and purchase advertisement spaces
contract AdMarketplace {

    // Struct for the advertisement space
    struct AdSpace {
        address owner;
        string name;
        string image;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        bool purchased;
    }

    // Owner of the marketplace
    address public owner;

    //adSpace Counter
    uint public AdSpacesCount;

    // Mapping of advertisement spaces
    mapping (uint256 => AdSpace) public adSpaces;

    // Address of the ERC20 token contract
    address internal cUSDContractAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Mapping for authorized advertisers
    mapping (address => bool) internal Authorized;

    // Event for purchasing an advertisement space
    event AdSpacePurchased(uint256 adSpaceId, address purchaser, uint256 price);

    /// @dev Constructor to set the owner of the marketplace
    constructor() {
        owner = msg.sender;
    }

    /// @dev Modifier to only allow the owner of the marketplace to perform certain actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner of the marketplace can perform this action.");
        _;
    }

    /// @dev Function for authorized advertisers to create an advertisement space
    /// @param name Name of the advertisement space
    /// @param image URL of the image for the advertisement space
    /// @param price Price of the advertisement space
    /// @param startTime Start time of the advertisement space
    function createAdSpace(string calldata name, string calldata image, uint256 price, uint256 startTime) public {
        // Only allow authorized advertisers to create advertisement spaces
        require(Authorized[msg.sender] , "Only authorized advertisers can create advertisement spaces.");

        // Create the advertisement space struct
        AdSpace memory adSpace = AdSpace({
            owner: msg.sender,
            name: name,
            image: image,
            price: price,
            startTime: startTime,
            endTime: startTime + 30 days, // advertisement space can be used for 30 days
            purchased: false
        });

        // Add the advertisement space to the mapping
        adSpaces[AdSpacesCount] = adSpace;
        AdSpacesCount++;
    }

    /// @dev Function for authorized companies to purchase an advertisement space
    /// @param adSpaceId ID of the advertisement space being purchased
    function purchaseAdSpace(uint256 adSpaceId) public payable {
        // Only allow authorized companies to purchase advertisement spaces
        require(msg.sender == owner, "Only authorized companies can purchase advertisement spaces.");

        // Get the advertisement space from the mapping
        AdSpace storage adSpace = adSpaces[adSpaceId];

        // Check that the advertisement space has not already been purchased
        require(!adSpace.purchased, "This advertisement space has already been purchased.");

        // Check that the purchase is being made at least 6 hours before the start time of the advertisement space
        require(adSpace.startTime - block.timestamp >= 6 hours, "This advertisement space cannot be purchased less than 6 hours before the start time.");

        // Check that the correct amount of ether is being sent
        require(msg.value == adSpace.price, "Incorrect amount of ether sent.");

        // Transfer the ether to the owner of the advertisement space
       
