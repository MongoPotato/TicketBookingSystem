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
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, uint _timestamp, string memory _date, string memory _linkSeatView) public returns (address newContract){
        showId = showId + 1;
        Show show = new Show(showId,_title, _amountOfSeatpPerRow, _rows, _timestamp, _date, _linkSeatView, payable(msg.sender));
        show.createTickets();
        shows.push(show);
        
        contracts.push(address(show));
        return address(show);
    }
    
    function getAddress(uint showId) public returns (address) {
        return address(shows[showId]);
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
    
    function getTickets(uint showId) public returns(uint256){
        uint i = check(showId);
        return shows[i].getTickets().length;
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