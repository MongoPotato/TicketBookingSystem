// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Show.sol";

contract TicketBooking {
    
    struct Seat{
        string title;
        uint timestamp;
        string date;
        uint256 seatNumber;
        uint256 row;
        string linkSeatView;
    }
    
    struct Ticket {
        uint256 tokenId;
        address seller;
        address owner;
        uint256 ticketPrice;
        bool sold;
        Seat seat;
    }
    
    string private names;
    Show[] public shows;
    Show[] public generatedShows;
    uint showId = 0;
    address[] public contracts;
    //list of shows and not just 1 show
    constructor(string memory _names){
        names = _names;
    }
    
    mapping (uint => address) TicketApproval;
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, uint _timestamp, string memory _date, string memory _linkSeatView) public returns (address newContract){
        showId = showId + 1;
        Show show = new Show(showId,_title, _amountOfSeatpPerRow, _rows, _timestamp, _date, _linkSeatView, payable(msg.sender));
        show.createTickets();
        shows.push(show);
        
        contracts.push(address(show));
        return address(show);
    }
    
    function getAddress(uint showid) public view returns (address) {
        return address(shows[showid]);
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
    
    function buyTicket(uint showid) public payable returns(uint256){
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
    
    function getTickets(uint showid) public view returns(uint256){
        uint i = check(showid);
        return shows[i].getTickets().length;
    }
    function refundTickets(uint showid) public{
        uint i = check(showid);
        shows[i].refundTickets(); 
    }
    
    function checkTokenId(uint showid, uint tokenid) public returns(bool){
        uint i = check(showid);
        for(uint j = 0; j < shows[i].getAmountOfticket(); j++){
            if(tokenid == shows[i].getTokenid(tokenid)){
                return true;
            }
        }
        return false;
    }
    
    function approveTradeTickets(uint showid, address toaddress, uint256 tokenid) public{
        uint i = check(showid);
        address customer = msg.sender;
         for(uint256 j = 0; j < shows[i].getAmountOfticket(); j++){ //checks if the sender has a ticket and if the token he sends in is valid
            if(customer == shows[i].getOwner(j)){
                j = shows[i].getAmountOfticket();
            }
        }
        require(checkTokenId(i, tokenid));
        TicketApproval[tokenid] = toaddress; //we then send an approval
        shows[i].Approves(customer, toaddress, tokenid);
    }
    
    function tradeTicketsWithApproval(uint showid, address toaddress, uint256 tokenid) public payable {
        uint i = check(showid);
        address customer = msg.sender;

        for(uint j = 0; j < shows[i].getAmountOfticket(); j++){ //checks if you have a ticket
            if(customer == shows[i].getOwner(j)){
                j = shows[i].getAmountOfticket();
            }
        }
        require(checkTokenId(i, tokenid));
        require(toaddress == shows[i].getOwner(tokenid) && TicketApproval[tokenid] == customer); 
        require(msg.value == shows[i].getTicketPrice(tokenid));
        (bool sent, bytes memory data) = payable(toaddress).call{value: msg.value}("");
        require(sent, "Failed to send ether");
        shows[i].setOwner(tokenid, customer);
    }
}