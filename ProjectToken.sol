pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";

contract IPRegistry is ERC721Full {

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