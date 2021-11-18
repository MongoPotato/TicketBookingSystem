// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


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
        string date;
        uint256 seatNumber;
        uint256 row;
        string linkSeatView;
    }
    
    
    //lacks concatenation of strings for linkSeatView
    string private title;
    Seat[] private seats;
    Ticket[] private tickets;
    string private linkSeatView;
    uint private amountOfSeatpPerRow;
    address payable owner;
    Seat private seat;
    uint256 ticketPrice = 1 ether;
    uint Showid;
    
    mapping (uint => address) TicketApproval;
    
    /*
    constructor(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) public{
        title = _title;
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        //string memory s1 = "/row/";
        //string memory temp;
        //string memory s2;
        //string memory s3 = "/";
        linkSeatView = _linkSeatView;
        
        for(uint i = 0; i < rows; i++){
            //linkSeatView = _linkSeatView;
            //s2 = uint2str(i);
            //temp = s1.toSlice().concat(s2.toSlice()); // /row/ + i
            //linkSeatView = (linkSeatView.toSlice().concat(temp.toSlice())); //linkSeatView + /row/ + i
            //temporary = linkSeatView;
            
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                //temp = (s3.toSlice().concat(uint2str(j).toSlice())); // "/" + j
                //linkSeatView = (linkSeatView.toSlice().concat.temp.toSlice()); // linkSeatView + / + j
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
                //linkSeatView = temporary;
            }
        }
    }
    */
    
    
    /**
     * constructor that takes in the title, amountOfSeatpPerRow, the amount of rows, the date of the show, then the link for the seat
     * It generates every seat available for that show.
     * 
    **/
    
    constructor(uint _Showid, string memory _title, uint _amountOfSeatpPerRow, uint _rows, string memory _date, string memory _linkSeatView) ERC721("Group 9 Ticket System", "G9TSys"){
        title = _title; 
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        linkSeatView = _linkSeatView;
        owner = payable(msg.sender);
        Showid = _Showid;
        
        for(uint i = 0; i < _rows; i++){
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
            }
        }
    }
    
    
    function getTitle() public view returns(string memory){
        return title;
    }
    
    function getShowId() public view returns(uint){
        return Showid;
    }
    
    /**
     * createTickets takes in the price of each ticket 
     * and creates a ticket for every seat.
     * It transfers ownership of every ticket to the organizer of the show
     *  
     * 
    **/
    function createTickets() public payable {
        require(msg.sender == owner, 'Not owner to of Ticket system');
        ticketPrice = msg.value;
        for(uint256 i = 0; i < seats.length; i++){
            tickets.push(Ticket({tokenId: i, seller: owner, owner: owner, ticketPrice: ticketPrice, sold: false, seat: seats[i]}));
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
        payable(ownerOf(tickets[counter].tokenId)).transfer(msg.value);
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
    
    /**
     * Returns the tokenId of the ticket you have bought at a show
     * else returns -1
     * 
    **/
    
    function getTockenId() view public returns(int) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == tickets[i].owner){
                return int(tickets[i].tokenId);
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
     * Function refundTickets requires that the organizer of the show 
     * is the sender. Then it goes through the whole function and transfer
     * ownership of the token to the organizer and transfer the value
     * of the tickets back to each person that have bought a ticket.
     * 
     * 
    **/
    function refundTickets() payable public{
        require(msg.sender == owner);
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == true){
                _transfer(ownerOf(tickets[i].tokenId), owner, tickets[i].tokenId);
                payable(ownerOf(tickets[i].tokenId)).transfer(ticketPrice); //i think this transfer funds to the owner of the ticket ??
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
    **/
    
    function tradeTicket(address toaddress, uint256 tokenid) payable public{
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){ //checks if you have a ticket
            if(customer == tickets[i].owner && tokenid == tickets[i].tokenId){
                i = tickets.length;
            }
        }
        require(customer == tickets[tokenid].owner && TicketApproval[tokenid] == customer); 
        _transfer(customer, toaddress, tickets[tokenid].tokenId);
        payable(toaddress).transfer(ticketPrice); //i think this transfer funds to the owner of the ticket ??
        tickets[tokenid].owner = toaddress;
    }
    
    /**
     * Function Approves takes in the address of the person you want to trade the ticket with and get money. 
     * If we take an example where C request the ticket of D. Then C sends this request and D approves the 
     * request and accepts the trade with C. C obtains the token from D while D gains his ether back for the 
     * price of the ticket he bought.
     * 
     * 
    **/
    
    function Approves(address toaddress, uint256 tokenid) external payable{
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){ //checks if the sender has a ticket and if the token he sends in is valid
            if(customer == tickets[i].owner && tokenid == tickets[i].tokenId){
                i = tickets.length;
            }
        }
        require(toaddress == tickets[tokenid].owner && customer != toaddress); //we require that the address of sender is 
        //different from the address you want to send to and that the token you send in belongs to the address you send in
        TicketApproval[tokenid] = toaddress; //we then send an approval
        emit Approval(customer, toaddress, tokenid);
    }
    
    
    
}

contract TicketBooking {
    
    string private names;
    Show[] private shows;
    uint Showid = 0;
    //list of shows and not just 1 show
    constructor(string memory _names){
        names = _names;
    }
    
    //title is id
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, string memory _date, string memory _linkSeatView) public returns(uint) {
        Showid = Showid + 1;
        Show show = new Show(Showid, _title, _amountOfSeatpPerRow, _rows, _date, _linkSeatView);
        show.createTickets();
        shows.push(show);
        return Showid - 1;
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
    
    function getTockenId(uint showid) public view returns(int){
        uint i = check(showid);
        return shows[i].getTockenId();
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
}