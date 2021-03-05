pragma solidity ^0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.7/contracts/token/ERC1155/ERC1155.sol"

contract NileMarket is ERC1155, Ownable {
    
    //variables 
    address payable public storefront;
    address customer;
    uint public cost;
    bool public OutofStock;
    
    event NotAvailable(bool OutofStock);
    
    
    constructor() ERC1155("NileMarket", "NILE") public {}
    
    constructor(address payable _storefront) public {
        customer = msg.sender;
        address payable storefront = _storefront;
    }
    
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    mapping(uint => NileMarket) public Inventory;
    
    function registerBook(string memory uri) public payable onlyOwner {
        token_ids.increase
    }
}


// Contract for tokenizing IP
// Marketplace contract
// Auction Contract 
