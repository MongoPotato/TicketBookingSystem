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
    
    
    //lacks concatenation of strings for linkSeatView
    string private title;
    Seat[] public seats;
    Ticket[] public tickets;
    Poster[] private posters;
    string private linkSeatView;
    uint private amountOfSeatpPerRow;
    address payable public owner;
    Seat private seat;
    uint256 ticketPrice = 1 ether;
    uint showId;
    
    mapping (uint => address) TicketApproval;
   
    
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
    
    /**
     * Returns title of this show. 
     * 
     * 
     **/ 
    
    function getTitle() public view returns(string memory){
        return title;
    }
    
    /**
     * Returns id of this show. 
     * 
     * 
     **/
     
     
    
    function getShowId() public view returns(uint){
        return showId;
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
    
    function buyTicket() public payable returns(uint256){
        uint counter = 0;
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == false){
                counter = i;
                i = tickets.length;
            }
        }
        
        address buyer = msg.sender;
        require(msg.value == ticketPrice);
        _transfer(ownerOf(tickets[counter].tokenId), buyer, tickets[counter].tokenId);
        (bool sent, bytes memory data) = payable(tickets[counter].seller).call{value: ticketPrice}("");
        require(sent, "Failed to send ether");
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
    
    function refundTickets() payable public{
        require(msg.sender == owner);
        uint counter = 0;
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == true){
                counter = counter + 1;
            }
        }
        require(msg.value == ticketPrice * counter);
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == true){
                _transfer(ownerOf(tickets[i].tokenId), owner, tickets[i].tokenId);
                (bool sent, bytes memory data) = payable(tickets[i].owner).call{value: ticketPrice}(""); 
                require(sent, "Failed to send ether");
                tickets[i].owner = owner;
                tickets[i].sold = false;
            }
        }
    }
    
    /**
     * Function tradeticket takes in the address of the person you want to trade with and your tokenid
     * you want to trade to that address. 
     * 
     * Requires that you have an Approval from the other person and that you own the token that
     * you have in your input.
     * 
     * Then we transfer the token ticket to the toaddress and the sender receives the amount of 
     * ether he used to buy his ether token ticket.
     * 
     * takes in address of the person that has approved the trade (D) and the tockenId of that ticket that is traded.
    **/
    
    function tradeTicket(address toaddress, uint256 tokenid) payable public{
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){ //checks if you have a ticket
            if(customer == tickets[i].owner && tokenid == tickets[i].tokenId){
                i = tickets.length;
            }
        }
        require(toaddress == tickets[tokenid].owner && TicketApproval[tokenid] == customer); 
        require(msg.value == ticketPrice);
        _transfer(toaddress, customer, tickets[tokenid].tokenId);
        (bool sent, bytes memory data) = payable(toaddress).call{value: ticketPrice}("");
        require(sent, "Failed to send ether");
        tickets[tokenid].owner = customer;
    }
    
    /**
     * Function Approves takes in the address of the person you want to trade the ticket with and get money. 
     * If we take an example where C request the ticket of D. Then D sends this request and C approves the 
     * request in tradeTicket and accepts the trade with C. C obtains the token from D while D gains his ether back for the 
     * price of the ticket he bought.
     * 
     * Your tockenId you want to give away and the address of the person you want to trade with (example on top D tockenId and C address)
    **/
    
    function Approves(address toaddress, uint256 tokenid) external payable{
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){ //checks if the sender has a ticket and if the token he sends in is valid
            if(customer == tickets[i].owner && tokenid == tickets[i].tokenId){
                i = tickets.length;
            }
        }
        require(customer == tickets[tokenid].owner && customer != toaddress); //we require that the address of sender is 
        //different from the address you want to send to and that the token you send in belongs to the address you send in
        TicketApproval[tokenid] = toaddress; //we then send an approval
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
    
    function releasePoster(uint256 tokenId, address receiver) private returns (uint256) {
        
        _mint(owner,posters[tokenId].posterTokenId);
        _transfer(ownerOf(posters[tokenId].posterTokenId), receiver, posters[tokenId].posterTokenId);
        delete tickets[tokenId];
        
        
        posters[tokenId].owner = receiver;
        posters[tokenId].printed = true;
        
        return posters[tokenId].posterTokenId;
        
    }
    /*function verifyPrinted(uint256 tokenId) public view returns(bool, string memory) {
        return (posters[tokenId].printed, posters[tokenId].posterTitle);
    }
    */
    
    
}
/*
contract TicketBooking {
    
    string private names;
    Show[] private shows;
    uint showId = 0;
    //list of shows and not just 1 show
    constructor(string memory _names){
        names = _names;
    }
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, uint _timestamp, string memory _linkSeatView) public returns (uint){
        showId = showId +1;
        Show show = new Show(showId,_title, _amountOfSeatpPerRow, _rows, _timestamp, _linkSeatView);
        show.createTickets();
        shows.push(show);
        return showId - 1;
    }
    
    function getShowTitleFromId(uint showid) public view returns(string memory){
        for(uint i = 0; i < shows.length; i++){
            if(shows[i].getShowId() == showid){
                return shows[i].getTitle();
            }
        }
        return "-1";
    }
    
    function verifyShowId(uint showid) private view returns(int){
        for(uint i = 0; i < shows.length; i++){
            if(shows[i].getShowId() == showid){
                return int(shows[i].getShowId());
            }
        }
        return -1;
    }
    
    function check(uint showid) private view returns (uint){
        int i = verifyShowId(showid);
        require(i == -1, "Show does not exist wrong showID");
        return uint(i);
    }
    
    function createTickets(uint showid) public{
        uint i = check(showid);
        shows[i].createTickets();
    }
    
    function buyTicket(uint showid) public returns(uint256){
        uint i = check(showid);
        return shows[i].buyTicket();
    }
    
    function verifyOwner(uint showid, uint256 tokenid) public view returns(address){
        uint i = check(showid);
        return shows[i].verifyOwner(tokenid);
    }
    
    function getTokenId(uint showid) public view returns(int){
        uint i = check(showid);
        return shows[i].getTokenId();
    }
    
    function refundTickets(uint showid) public{
        uint i = check(showid);
        shows[i].refundTickets(); 
    }
    
    function approveTradeTickets(uint showid, address toaddress, uint256 tokenid) public{
        uint i = check(showid);
        shows[i].Approves(toaddress, tokenid);
    }
    
    function tradeTicketsWithApproval(uint showid, address toaddress, uint256 tokenid) public {
        uint i = check(showid);
        shows[i].tradeTicket(toaddress, tokenid);
    }
 
    
}*/