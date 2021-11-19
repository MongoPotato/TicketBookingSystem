// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";


contract Show is ERC721 {
    
    struct Ticket {
        uint256 tokenId;
        address seller;
        address owner;
        uint256 ticketPrice;
        bool sold;
        Seat seat;
    }
    
    struct Seat{
        string title;
        uint timestamp;
        string date;
        uint256 seatNumber;
        uint256 row;
        string linkSeatView;
    }
    
    struct Poster {
        uint256 posterTokenId;
        address seller;
        address owner; 
        string posterTitle;
        bool printed;
    }
    
    
    string private title;
    Seat[] public seats;
    Ticket[] public tickets;
    Poster[] private posters;
    string private linkSeatView;
    uint private amountOfSeatpPerRow;
    address payable public owner;
    Seat private seat;
    uint256 private ticketPrice = 1 ether;
    uint private showId;
   
    
    /**
     * constructor that takes in the showId, title, amountOfSeatpPerRow, the amount of rows, the date of the show, then the link for the seat
     * It generates every seat available for that show.
     * 
    **/
    
    constructor(uint _showId, string memory _title, uint _amountOfSeatpPerRow, uint _rows, uint _timestamp, string memory _date, string memory _linkSeatView, address payable creatorAddress) ERC721("Group 9 Ticket System", "G9TSys"){
        title = _title; 
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        linkSeatView = _linkSeatView;
        owner = creatorAddress;
        showId = _showId;
        setApprovalForAll(address(this), true);
        
        for(uint i = 0; i < _rows; i++){
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                seats.push(Seat({title: title, timestamp: _timestamp, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
            }
        }
    }

    
    function getTitle() public view returns(string memory){
        return title;
    }
     
    function getShowId() public view returns(uint){
        return showId;
    }
    
    function getAmountOfticket() public view returns(uint){
        return tickets.length;
    }
    
    function setOwner(uint tokenid, address newaddr) public{
        tickets[tokenid].owner = newaddr;
    }

    function getOwner(uint tokenid) public view returns(address){
        return tickets[tokenid].owner;
    }

    function getTicketPrice(uint tokenid) public view returns(uint256){
        return tickets[tokenid].ticketPrice;
    }

    function getSoldStatus(uint tokenid) public view returns(bool){
        return tickets[tokenid].sold;
    }
    
    function getTokenid(uint tokenid) public view returns(uint256){
        return tickets[tokenid].tokenId;
    }
    
    function getAddressSeller(uint tokenid) public view returns(address){
        return tickets[tokenid].seller;
    }
    
    function getPosterOwner(uint tokenid) public view returns(address) {
        return posters[tokenid].owner;
    }
    
    function getShowValidationTime() public view returns(uint) {
        return tickets[0].seat.timestamp;
    }
    
    function burnValidatedTicket(uint tokenid, address receiverOfPoster) public {
        _burn(tokenid);
        releasePoster(tokenid, receiverOfPoster);
    }
    
    /**
     * createTickets takes in the price of each ticket 
     * and creates a ticket for every seat.
     * It transfers ownership of every ticket to the organizer of the show
     *  
    **/
    
    function createTickets() public payable {
        //(msg.sender == owner, 'Not owner to of Ticket system');
        //ticketPrice = msg.value;
        for(uint256 i = 0; i < seats.length; i++){
            tickets.push(Ticket({tokenId: i, seller: owner, owner: owner, ticketPrice: ticketPrice, sold: false, seat: seats[i]}));
            posters.push(Poster({posterTokenId: i, seller: owner, owner: owner, posterTitle: seats[i].title, printed: false}));
        }
        
        for(uint256 i = 0; i < tickets.length; i++){
            _mint(owner, tickets[i].tokenId);
        }
    }
    
    
    /**
     * buyTicket function that checks available tickets and you get a random ticket
     *  that is in the amount of available free tickets.
     * The sender transfers funds to the organizer of the show
     * returns the TokenId
    **/
    
    function buyTicket(uint counter, address buyer) public payable returns(uint256){
        _transfer(tickets[counter].seller, buyer, tickets[counter].tokenId);
        tickets[counter].owner = buyer;
        tickets[counter].sold = true;
        return tickets[counter].tokenId;
    }
    
    /**
     * Returns the ticket you have bought at a show
     * else returns -1
     * 
    **/
    
    function getTicket() view public returns(int) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == tickets[i].owner){
                return int(tickets[i].seat.seatNumber);
            }
        }
        return -1;
    }
    
    function getTickets() public view returns(Ticket[] memory){
        
        return tickets;
    }
    
    /**
     * Returns the price of ticket if it has been initialized 
     * 
    **/
    
    function getTicketPrice() view public returns(uint256){
        require(tickets.length != 0, "Tickets are not initialized");
        return ticketPrice;
    }
    
    /**
     * Returns the tokenId of the ticket you have bought at a show
     * else returns -1
     * 
    **/
    
    function getTokenId() view public returns(int) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == tickets[i].owner){
                return int(tickets[i].tokenId);
            }
        }
        return -1;
    }
    
    /**
     * Returns the Poster you have retrieved after validating
     * else returns false with a error message. 
     * 
    **/
    
    function getPoster() view public returns(string memory, bool) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == posters[i].owner){
                return (posters[i].posterTitle, posters[i].printed);
            }
        }
        return ("You havent validated ticket", false);
    }
    
    /**
     * Returns the tokenId of the poster you have retrieved after a show
     * else returns -1
     * 
    **/
    
    function getPosterId() view public returns(int) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == posters[i].owner){
                return int(posters[i].posterTokenId);
            }
        }
        return -1;
    }
    
    /**
     * Takes in the tokenId and verifies if it the owner of the token ticket
     * 
    **/
    
    function verifyOwner(uint256 tokenId) public view returns (address) {
        return tickets[tokenId].owner;
    }
    
    /**
     * 
     * Check amount of tickets sold to then input amount in refundTickets function
     * 
    **/
    
    function checkTicketSold() public view returns(uint){
        uint counter = 0;
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == true){
                counter = counter + 1;
            }
        }
        return counter;
    }
    
    /**
     * Function refundTickets requires that the organizer of the show 
     * is the sender. Then it goes through the whole function and transfer
     * ownership of the token to the organizer and transfer the value
     * of the tickets back to each person that have bought a ticket.
     * 
    **/
    
    function refundTickets(uint tokenid, address customer) payable public{
        _transfer(customer, owner, tickets[tokenid].tokenId);
        tickets[tokenid].owner = owner;
        tickets[tokenid].sold = false;
    }
    
    
    function tradeTicket(address toaddress, address customer, uint tokenid) payable public{
        _transfer(toaddress, customer, tokenid);
    }
    
    function Approves(address customer, address toaddress, uint256 tokenid) external payable{
        emit Approval(customer, toaddress, tokenid);
    }
    
    /**
     * Function validateTicket takes in a tokenId of a ticket and a current timestamp in unix-format(normally handled with other external tools)
     * and verifies that token exists, is owned by msg.sender and thats its not already validated. 
     * The token can only be validated between 30 minutes before show-start and 15 min after show-start. 
     * If all these requirements are met, the ticket is burned and a private releasePoster function is called. 
     * 
     **/ 
     
     function validateTicket(uint256 tokenId, uint validationTimestamp) public {
        require(_exists(tokenId) == true, "Not valid tokenId");
        require(msg.sender != posters[tokenId].owner, "Ticket already validated");
        require(msg.sender == tickets[tokenId].owner, "You do not own this token");
        
        require((tickets[tokenId].seat.timestamp -1800 <= validationTimestamp) || (tickets[tokenId].seat.timestamp + 900 >= validationTimestamp), "Not within timeslot of validation");
        if(tickets[tokenId].sold == true) {
            _burn(tokenId);
            releasePoster(tokenId, msg.sender);
        }
        
        
    }
    
    /**
     * the private function releasePoster takes in the tokenId from validateTicket and mints a new token with the Poster structure. 
     * After minting, the poster is transfering its ownership from the owner of the booking system, to the msg.sender validating the ticket. 
     * Internal storage updates accordingly. 
     * Returns the posterTokenId of the released poster. 
     * 
     **/ 
    
    function releasePoster(uint256 tokenId, address receiver) private returns (string memory, uint256) {
        
        _mint(owner,posters[tokenId].posterTokenId);
        _transfer(ownerOf(posters[tokenId].posterTokenId), receiver, posters[tokenId].posterTokenId);
        delete tickets[tokenId];
        
        
        posters[tokenId].owner = receiver;
        posters[tokenId].printed = true;
        
        return (posters[tokenId].posterTitle,posters[tokenId].posterTokenId);
        
    }
    
    function verifyPrinted(uint256 tokenId) public view returns(bool, string memory) {
        return (posters[tokenId].printed, posters[tokenId].posterTitle);
    }
    
    
}
