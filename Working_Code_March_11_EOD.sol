pragma solidity ^0.5.5;
// Importing SafeMath 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
// Importing ERC721 from OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
// Importing Counters from OpenZeppelin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
contract IPRegistry is ERC721Full {
    using SafeMath for uint256;
    constructor() ERC721Full("IPToken", "IP") public { }
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    struct Intellectual_Property {
        string ip_name;
        string creator;
        uint appraisal_value;
    }
    mapping(uint => Intellectual_Property) public ip_collection;
    event Appraisal(uint token_id, uint appraisal_value, string token_uri);
    function registerIP(address owner, string memory ip_name, string memory creator, uint appraisal_value, string memory token_uri) public returns(uint) {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(owner, token_id);
        _setTokenURI(token_id, token_uri);
        ip_collection[token_id] = Intellectual_Property(ip_name, creator, appraisal_value);
        return token_id;
    }
    function newAppraisal(uint token_id, uint new_value, string memory token_uri) public returns(uint) {
        ip_collection[token_id].appraisal_value = new_value;
        emit Appraisal(token_id, new_value, token_uri);
        return ip_collection[token_id].appraisal_value;
    }
}
contract Auction {
    address owner;
    address payable private beneficiary; 
    string ip_name;
    uint public newAppraisal;
    string public token_uri;
    bool public auctionEnded;
    uint public highestPrice;
    uint public highestBid;
    address payable public highestBidder;
    mapping(address => uint) public ListOfBids;
    event BidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    constructor(address payable _owner, string memory _title, uint _startPrice, string memory _description) public {
        owner = msg.sender;
        beneficiary = _owner;
        ip_name = _title;
        newAppraisal= _startPrice;
        token_uri = _description;
    }
    modifier notOwner(){
        require(msg.sender != beneficiary);
        _;
    }
    function bid(address payable bidder) public payable {
        require(!auctionEnded, "IPs are no longer available for auction.");
        require(msg.value > highestBid, "Your bid is lower than the current highest price.");
        if (highestBid != 0) {
            ListOfBids[highestBidder] = highestBid;
        }
        highestBidder = bidder;
        highestBid = msg.value;
        emit BidIncrease(highestBidder, highestBid);
    }    
    // Placing bid; owner is umable to place bid, prevents articifical inflation of price 
    function getListOfBids(address bidder) public view returns(uint) {
        return ListOfBids[bidder];
    }
    function withdraw() public returns(bool) {
        uint amount = ListOfBids[msg.sender];
        if (amount > 0) {
            ListOfBids[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                ListOfBids[msg.sender] = amount;
                return false;
            }
        } 
        return true; 
    }
    function endAuction() public {
        require(!auctionEnded, "You too late! Auction been done.");
        require(msg.sender == owner, "You are not the beneficiary.");
        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}