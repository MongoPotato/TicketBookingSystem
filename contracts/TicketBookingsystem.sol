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
    
    
    /**
     * 
     * function create, creates new show and then pushes it to the show array and it also initializes all the tickets in a Show
     * 
    **/
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, uint _timestamp, string memory _date, string memory _linkSeatView) public returns (address newContract){
        Show show = new Show(showId,_title, _amountOfSeatpPerRow, _rows, _timestamp, _date, _linkSeatView, payable(msg.sender));
        show.createTickets();
        shows.push(show);
        showId = showId + 1;
        contracts.push(address(show));
        return address(show);
    }
    
     /**
     * 
     * returns address of the show
     * 
    **/
    
    function getAddress(uint showid) public view returns (address) {
        return address(shows[showid]);
    }
    
     /**
     * 
     * fetches the title for the show from the show id
     * 
    **/
    
    function getShowTitleFromId(uint showid) public view returns(string memory){
        for(uint i = 0; i < shows.length; i++){
            if(shows[i].getShowId() == showid){
                return shows[i].getTitle();
            }
        }
        return "-1";
    }
    
     /**
     * 
     * verifies if the id of the show exists
     * 
    **/
    
    function verifyShowId(uint showid) private view returns(bool){
        for(uint i = 0; i < shows.length; i++){
            if(shows[i].getShowId() == showid){
                return true;
            }
        }
        return false;
    }
    
     /**
     * 
     * checks if the showid exists
     * 
    **/
    
    function check(uint showid) private view{
        bool cond = verifyShowId(showid);
        require(cond == true, "Show does not exist wrong showID");
    }
    
    /**
     * 
     * Created a buyTicket function where you input the price of the show 
     * by default 1 ether and it returns the tokenid for your ticket.
     * 
    **/
    
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
    
    
    /**
     * 
     * verifies if the owner exists and has a token with that tokenid
     * 
    **/
    
    function verifyOwner(uint showid, uint256 tokenid) public view returns(address){
        check(showid);
        return shows[showid].verifyOwner(tokenid);
    }
    
    /**
     * 
     * validates the ticket with the validationTime that is defined in UNIX time to validate the ticket.
     * 
    **/
    
    function validateTicket(uint showid, uint256 tokenid, uint validationTime) public returns(string memory, uint256){
        check(showid);
        require(msg.sender == verifyOwner(showid, tokenid), "You do not own this ticket");
        require(msg.sender != shows[showid].getPosterOwner(tokenid), "Ticket already validated!");
        
        require((shows[showid].getShowValidationTime() -1800 <= validationTime) || (shows[showid].getShowValidationTime() + 900 >= validationTime), "Not within timeslot of validation");
        
        if(shows[showid].getSoldStatus(tokenid) == true){
            shows[showid].burnValidatedTicket(tokenid, msg.sender);
            
        }
    }
    
    /**
     * 
     * verifyPrinted returns the validaton of the ticket with your post token.
     * 
    **/
    
    function verifyPrinted(uint showid, uint256 tokenid) public view returns(bool, string memory) {
        check(showid);
        require(msg.sender != verifyOwner(showid, tokenid), "You have not validated your ticket");
        require(msg.sender == shows[showid].getPosterOwner(tokenid), "You do not own this poster");
        
        return shows[showid].verifyPrinted(tokenid);
        
    }
    
    function getTokenId(uint showid) public view returns(int){
        check(showid);
        return shows[showid].getTokenId();
    }
    
    function getTickets(uint showid) public view returns(uint256){
        check(showid);
        return shows[showid].getTickets().length;
    }
    
    /**
     * 
     * refunds checks if you are the owner of the Show and then you can call on the refund 
     * that goes through the list and refunds each person that has purchased a token
     * 
    **/
    
    function refundTickets(uint showid) public payable returns(uint){
        check(showid);
        require(msg.sender == shows[showid].getAddressSeller(0));
        uint counter = 0;
        for(uint i = 0; i < shows[showid].getAmountOfticket(); i++){
            if((shows[showid].getSoldStatus(i)) == true){
                counter = counter + 1;
            }
        }
        require(msg.value == shows[showid].getTicketPrice(0) * counter);
        for(uint j = 0; j < shows[showid].getAmountOfticket(); j++){
            if((shows[showid].getSoldStatus(j)) == true){
                (bool sent, bytes memory data) = payable(shows[showid].getOwner(j)).call{value: shows[showid].getTicketPrice(j)}("");
                require(sent, "Failed to send ether");
                shows[showid].refundTickets(j, shows[showid].getOwner(j));
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
    
    /**
     * Function Approves takes in the address of the person you want to trade the ticket with and get money. 
     * If we take an example where C request the ticket of D. Then D sends this request and C approves the 
     * request in tradeTicket and accepts the trade with C. C obtains the token from D while D gains his ether back for the 
     * price of the ticket he bought.
     * 
     * Your tockenId you want to give away and the address of the person you want to trade with (example on top D tockenId and C address)
    **/
    
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
    
    function tradeTicketsWithApproval(uint showid, address toaddress, uint256 tokenid) public payable {
        check(showid);
        address customer = msg.sender;

        for(uint j = 0; j < shows[showid].getAmountOfticket(); j++){ //checks if you have a ticket
            if(customer == shows[showid].getOwner(j)){
                j = shows[showid].getAmountOfticket();
            }
        }
        require(checkTokenId(showid, tokenid), "tokenid does not exist on show");
        require(toaddress == shows[showid].getOwner(tokenid) && TicketApproval[tokenid] == customer, "toadress is not owner of token"); 
        require(msg.value == shows[showid].getTicketPrice(tokenid), "price is not equal to value entered");
        (bool sent, bytes memory data) = payable(toaddress).call{value: msg.value}("");
        require(sent, "Failed to send ether");
        shows[showid].tradeTicket(toaddress, customer, tokenid);
        shows[showid].setOwner(tokenid, customer);
    }
}