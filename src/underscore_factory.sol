pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/ERC20.sol";

contract underscore_factory {

    mapping(address => ERC721A[]) public listings;
    mapping(address => uint256) public rating;
    mapping(address => uint256) public numOfReviews;
    mapping(address => mapping(ERC721A => uint256)) public userReviewStorage;

    event NewListing(address creator, string name, string symbol, string url, ERC20 assetRequested, uint256 pricePerItem, uint256 quantity);
    event ItemReviewed(address creator, ERC721A listing, address reviewer, uint256 reviewScore);

    function createListing(
        string memory name, 
        string memory symbol,
        string memory url,
        ERC20 assetRequested,
        uint256 pricePerItem,
        uint256 quantity 
    ) public {
        ERC721A newListing = new ERC721A(name, symbol, url, msg.sender);
        listings[msg.sender].push(newListing); 
        emit NewListing(msg.sender, name, symbol, url, assetRequested, pricePerItem, quantity);
    }

    function creatorMint(uint256 quantity, ERC721A listing) external {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        require(listing._creator() == msg.sender);
        listing._mint(msg.sender, quantity);
    }

    function reviewSeller(ERC721A listing, uint256 review) external {
        require(review == 1 || review == 2 || review == 3 || review == 4 || review == 5, "Review must be out of five");
        require(listing.balanceOf(msg.sender) >= 0, "Cannot review an item you do not own");
        require(userReviewStorage[msg.sender][listing] == 0, "Cannot review an item twice");
        userReviewStorage[msg.sender][listing] = 1;
        rating[listing._creator()] = review;
        emit ItemReviewed(listing._creator(), listing, msg.sender, review);
    }
}
