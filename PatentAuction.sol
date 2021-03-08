pragma solidity ^0.5.5;

// Importing SafeMath from OpenZeppelin
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

contract AuctionBox{
    
    Auction[] public auctions; 
   
    function createAuction (string memory _title, uint _startPrice, string memory _description) public {
        // Create instance for auctioining of each new item
        Auction newAuction = new Auction(msg.sender, _title, _startPrice, _description);
        // Push address of new auction to array
        auctions.push(newAuction);
    }
    
    function returnAllAuctions() public view returns(Auction[] memory) {
        return auctions;
    }
}

contract Auction {
    
    using SafeMath for uint256;
    
    address payable private creator; 
    string ip_name;
    uint public newAppraisal;
    string public token_uri;

    enum Phase{Default, Running, Finalized}
    Phase public auctionPhase;

    uint public highestPrice;
    address payable public highestBidder;
    mapping(address => uint) public bids;
    
      
    constructor(address payable _owner, string memory _title, uint _startPrice, string memory _description) public {
        // initialize auction
        creator = _owner;
        ip_name = _title;
        newAppraisal= _startPrice;
        token_uri = _description;
        auctionPhase = Phase.Running;
    }
    
    modifier notOwner(){
        require(msg.sender != creator);
        _;
    }
    
    // Placing bid; owner is umable to place bid, prevents articifical inflation of price 
    
    function placeBid() public payable notOwner returns(bool) {
        require(auctionPhase == Phase.Running);
        require(msg.value > 0);
        // update the current bid
        uint currentBid = bids[msg.sender].add(msg.value);
        require(currentBid > highestPrice);
        // set the currentBid links with msg.sender
        bids[msg.sender] = currentBid;
        // update the current highest price
        highestPrice = currentBid;
        highestBidder = msg.sender;
        
        return true;
    }
    
    function finalizeAuction() public {
        //the owner and bidders can finalize the auction.
        require(msg.sender == creator || bids[msg.sender] > 0);
        
        address payable recipient;
        uint value;
        
        // owner can get highestPrice
        if(msg.sender == creator){
            recipient = creator;
            value = highestPrice;
        }
        // highestBidder can get no money
        else if (msg.sender == highestBidder){
            recipient = highestBidder;
            value = 0;
        }
        // Other bidders can get back the money 
        else {
            recipient = msg.sender;
            value = bids[msg.sender];
        }
        // initialize the value
        bids[msg.sender] = 0;
        recipient.transfer(value);
        auctionPhase = Phase.Finalized;
    }
    

    function returnContents() public view returns(string memory, uint, string memory, Phase) {
        return (ip_name, newAppraisal, token_uri, auctionPhase);
    }
}















