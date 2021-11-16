// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketSystem is ERC721{
    
    
    struct Ticket {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 ticketPrice;
        bool sold;
        Seat seats;
    }
    
    struct Seat{
        string title;
        string date;
        uint256 seatNumber;
        uint256 row;
        string linkSeatView;
    }
    
    string private title;
    Seat[] private seats;
    Ticket[] private tickets;
    string private linkSeatView;
    //string private temporary;
    uint private amountOfSeatpPerRow;
    address payable owner;
    Seat private seat;

    constructor(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) ERC721("Group 9 Ticket System", "G9TSys"){
        title = _title;
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        linkSeatView = _linkSeatView;
        owner = payable(msg.sender);
        
        for(uint i = 0; i < rows; i++){
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
            }
        }
    }
    
    function createTicket(uint256 ticketprice) public {
        require(msg.sender == owner, 'Not owner to of Ticket system');
        for(uint256 i = 0; i < seats.length; i++){
            tickets.push(Ticket({tokenId: i, seller: owner, owner: owner, ticketPrice: ticketprice, sold: false, seats: seats[i]}));
        }
    }
    
    
    
}


contract Show{
    
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
    string private linkSeatView;
    //string private temporary;
    uint private amountOfSeatpPerRow;
    
    
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
    
    
    //from https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    
}

contract TicketBooking {
    string name;
    Show[] shows;
    //list of shows and not just 1 show
    constructor(string memory _name){
        name = _name;
    }
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) public {
        Show show = new Show(_title, _amountOfSeatpPerRow, rows, _date, _linkSeatView);
        shows.push(show);
    }
 
    
}