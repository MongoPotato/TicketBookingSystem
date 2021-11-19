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
        Show show = new Show(showId,_title, _amountOfSeatpPerRow, _rows, _timestamp, _date, _linkSeatView, payable(msg.sender));
        show.createTickets();
        shows.push(show);
        showId = showId + 1;
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
    
    function verifyShowId(uint showid) private view returns(bool){
        for(uint i = 0; i < shows.length; i++){
            if(shows[i].getShowId() == showid){
                return true;
            }
        }
        return false;
    }
    
    function check(uint showid) private view{
        bool cond = verifyShowId(showid);
        require(cond == true, "Show does not exist wrong showID");
    }
    
    function buyTicket(uint showid) public payable returns(uint256){
        check(showid);
        uint counter = 0;
        for(uint j = 0; j < shows[showid].getAmountOfticket(); j++){
            if(shows[showid].getSoldStatus(j) == false){
                counter = j;
                j = shows[showid].getAmountOfticket();
            }
        }
        address buyer = msg.sender;
        require(msg.value == shows[showid].getTicketPrice(counter));
        
        (bool sent, bytes memory data) = payable(shows[showid].getAddressSeller(counter)).call{value: msg.value}("");
        require(sent, "Failed to send ether");
        return shows[showid].buyTicket(counter, buyer);
    }
    
    function verifyOwner(uint showid, uint256 tokenid) public view returns(address){
        check(showid);
        return shows[showid].verifyOwner(tokenid);
    }
    
    function getTokenId(uint showid) public view returns(int){
        check(showid);
        return shows[showid].getTokenId();
    }
    
    function getTickets(uint showid) public view returns(uint256){
        check(showid);
        return shows[showid].getTickets().length;
    }
    function refundTickets(uint showid) public payable{
        check(showid);
        require(msg.sender == shows[showid].getAddressSeller(0));
        uint counter = 0;
        for(uint i = 0; i < shows[showid].getAmountOfticket(); i++){
            if(shows[showid].getSoldStatus(i) == true){
                counter = counter + 1;
            }
        }
        require(msg.value == shows[showid].getTicketPrice(0) * counter);
        for(uint i = 0; i < shows[showid].getAmountOfticket(); i++){
            if(shows[showid].getSoldStatus(i) == true){
                shows[showid].refundTickets(i, shows[showid].getOwner(i));
                (bool sent, bytes memory data) = payable(shows[showid].getOwner(i)).call{value: shows[showid].getTicketPrice(i)}(""); 
                require(sent, "Failed to send ether");
            }
        }
    }
    
    function checkTokenId(uint showid, uint tokenid) public view returns(bool){
        check(showid);
        for(uint j = 0; j < shows[showid].getAmountOfticket(); j++){
            if(tokenid == shows[showid].getTokenid(tokenid)){
                return true;
            }
        }
        return false;
    }
    
    function approveTradeTickets(uint showid, address toaddress, uint256 tokenid) public{
        check(showid);
        address customer = msg.sender;
         for(uint256 j = 0; j < shows[showid].getAmountOfticket(); j++){ //checks if the sender has a ticket and if the token he sends in is valid
            if(customer == shows[showid].getOwner(j)){
                j = shows[showid].getAmountOfticket();
            }
        }
        require(checkTokenId(showid, tokenid));
        TicketApproval[tokenid] = toaddress; //we then send an approval
        shows[showid].Approves(customer, toaddress, tokenid);
    }
    
    function tradeTicketsWithApproval(uint showid, address toaddress, uint256 tokenid) public payable {
        check(showid);
        address customer = msg.sender;

        for(uint j = 0; j < shows[showid].getAmountOfticket(); j++){ //checks if you have a ticket
            if(customer == shows[showid].getOwner(j)){
                j = shows[showid].getAmountOfticket();
            }
        }
        require(checkTokenId(showid, tokenid));
        require(toaddress == shows[showid].getOwner(tokenid) && TicketApproval[tokenid] == customer); 
        require(msg.value == shows[showid].getTicketPrice(tokenid));
        (bool sent, bytes memory data) = payable(toaddress).call{value: msg.value}("");
        require(sent, "Failed to send ether");
        shows[showid].setOwner(tokenid, customer);
    }
}