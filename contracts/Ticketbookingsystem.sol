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
    
    constructor(string memory _title, uint _amountOfSeatpPerRow, uint _rows, string memory _date, string memory _linkSeatView) ERC721("Group 9 Ticket System", "G9TSys"){
        title = _title;
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        linkSeatView = _linkSeatView;
        owner = payable(msg.sender);
        
        for(uint i = 0; i < _rows; i++){
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
            }
        }
    }
    
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
    
    
    function buyTicket() public payable {
        uint counter = 0;
        for(uint i = 0; i < tickets.length; i++){
            if(tickets[i].sold == false){
                counter = i;
                i = tickets.length;
            }
        }
        
        address buyer = msg.sender;
        require(msg.value >= ticketPrice);
        _transfer(ownerOf(tickets[counter].tokenId), buyer, tickets[counter].tokenId);
        payable(ownerOf(tickets[counter].tokenId)).transfer(msg.value);
        tickets[counter].owner = buyer;
        tickets[counter].sold = true;
    }
    
    function getTicket() view public returns(uint256 seatNumber) {
        address customer = msg.sender;
        for(uint256 i = 0; i < tickets.length; i++){
            if(customer == tickets[i].owner){
                return tickets[i].seat.seatNumber;
            }
        }
    }
    
    
}

contract TicketBooking {
    
    string private names;
    Show[] private shows;
    //list of shows and not just 1 show
    constructor(string memory _names){
        names = _names;
    }
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint _rows, string memory _date, string memory _linkSeatView) public {
        Show show = new Show(_title, _amountOfSeatpPerRow, _rows, _date, _linkSeatView);
        show.createTickets();
        shows.push(show);
    }
    
    function getShow(uint index) public  view returns(Show show){
        return shows[index];
    }
 
    
}