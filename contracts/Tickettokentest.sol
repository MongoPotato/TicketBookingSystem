// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TicketStorage is ERC721URIStorage{
    
    using Counters for Counters.Counter;
    Counters.Counter private seatCounter;
    address contractAddress;
    
    constructor(address ticketStorageAddress) ERC721("Group 9 Ticket storage", "G9TS") {
        contractAddress = ticketStorageAddress;
    }
    
    
    
    function createTicketToken(string memory seatId) private returns (uint) {
        seatCounter.increment();
        uint256 ticketId = seatCounter.current();
        _mint(msg.sender, ticketId);
        _setTokenURI(ticketId, seatId);
        return ticketId;
        
    }
}

contract TicketSystem is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private ticketIds;
    
    address payable owner;
    uint256 ticketPrice = 0.1 ether;
    
    constructor() ERC721("Group 9 Ticket System", "G9TSys") {
        
        owner = payable(msg.sender);
        
    }
    
    struct Ticket {
        uint ticketId;
        address ticketContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 ticketPrice;
    }
    mapping(uint256 => Ticket) private idToTicket;
    
    function createTicket(address ticketContract, uint256 tokenId, uint256 price) public payable{
        
        ticketIds.increment();
        uint256 ticketId = ticketIds.current();
        
        idToTicket[ticketId] = Ticket(ticketId, ticketContract,tokenId, payable(msg.sender),payable(address(0)), price);
        
        
        
        
    }
}
