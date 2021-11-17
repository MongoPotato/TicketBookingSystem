// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TicketStorage is ERC721URIStorage{
    
    using Counters for Counters.Counter;
    Counters.Counter private seatCounter;
    address contractAddress;
    
    constructor(address ticketSystemAddress) ERC721("Group 9 Ticket storage", "G9TS") {
        contractAddress = ticketSystemAddress;
    }
    
    mapping(string => bool) public tokenURIExists;
    mapping(string => bool) public seatNameExists;
    
    function createTicketToken(string memory seatId) public returns (uint) {
        seatCounter.increment();
        uint256 ticketId = seatCounter.current();
        
        require(!_exists(ticketId));
        require(!tokenURIExists[seatId]);
        require(!seatNameExists[seatId]);
        
        _mint(msg.sender, ticketId);
        _setTokenURI(ticketId, seatId);
        setApprovalForAll(contractAddress, true);
        
        tokenURIExists[seatId] = true;
        return ticketId;
        
    }
}

contract TicketSystem is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private ticketIds;
    Counters.Counter private boughtTickets;
    
    address payable owner;
    uint256 ticketPrice = 0.1 ether;
    
    constructor() ERC721("Group 9 Ticket System", "G9TSys") {
        
        owner = payable(msg.sender);
        
    }
    
    struct Ticket {
        uint ticketId;
        address ticketContract;
        uint256 tokenId;
        string seatName;
        address payable seller;
        address payable owner;
        uint256 ticketPrice;
    }
    
    event TicketCreated ( uint indexed tickedId, address indexed ticketContract, uint256 indexed tokenId, address seller, address owner, uint256 price);
    mapping(uint256 => Ticket) private idToTicket;
    
    mapping(uint256 => string) private idToSeatName;
    
    function createTicket(address ticketContract, uint256 tokenId,string memory seatName, uint256 price) public payable returns (uint256){
        
        ticketIds.increment();
        uint256 ticketId = ticketIds.current();
        //string memory seatId = tokenURI(tokenId);
        idToTicket[ticketId] = Ticket(ticketId, ticketContract,tokenId,seatName,payable(msg.sender),payable(address(0)), price);
        idToSeatName[ticketId] = seatName;
        IERC721(ticketContract).transferFrom(msg.sender, address(this), tokenId);
        
        emit TicketCreated(ticketId,ticketContract,tokenId,msg.sender, address(0),price);
        
        return tokenId;
        
        
        
        
    }
    
    function buyTicket(address contractAddress, string memory seatName) public payable {
        //fetch tickedID and buy that specific token. 
        require(msg.value == ticketPrice, "The price for one ticket is 0.1 Ether");
        
        uint tokenId = fetchTokenIdFromSeatName(seatName);
        IERC721(contractAddress).transferFrom(address(this), msg.sender,tokenId);
        boughtTickets.increment();
        idToTicket[tokenId].owner = payable(msg.sender);
        payable(owner).transfer(ticketPrice);
        
        
    }
    
    function verifyOwner(uint256 tokenId) public view returns (address) {
        return idToTicket[tokenId].owner;
    }
    
    //Returns index of specified seatId. To be used in buyTicket.
    function fetchTokenIdFromSeatName(string memory seatName) public view returns (uint) {
        
        uint totalTickets = ticketIds.current();
        //string memory seatNumber = seatId;
        for (uint i = 0; i < totalTickets; i++){
            string memory temp = idToSeatName[i];
            if ( compareStringsByBytes(temp, seatName) == true){
                return i;
            }
        }
        return totalTickets;
        
        
    }
    
    function compareStringsByBytes(string memory s1, string memory s2) public pure returns (bool) {
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
    //Returns list of created and available tickets. 
    function fetchAvailableTickets() public view returns (Ticket[] memory) {
        
        uint totalTickets = ticketIds.current();
        uint ticketCount = ticketIds.current() - boughtTickets.current(); 
        uint currentIndex = 0;
        
        Ticket[] memory avaiableTickets = new Ticket[](ticketCount);
        
        for (uint i = 0; i < totalTickets; i++) {
            if (idToTicket[i+1].owner == address(0)) {
                uint currentId = i+1;
                Ticket storage currentTicket = idToTicket[currentId];
                avaiableTickets[currentIndex] = currentTicket;
                currentIndex += 1;
            }
            
        }
        return avaiableTickets;
    }
}
