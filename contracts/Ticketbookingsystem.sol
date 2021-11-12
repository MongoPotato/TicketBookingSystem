// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "github.com/Arachnid/solidity-stringutils/strings.sol";

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
    string private temporary;
    uint private amountOfSeatpPerRow;
    
    
    constructor(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) public{
        title = _title;
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        string s1 = "/row/";
        string temp;
        string s3 = "/";
        linkSeatView = _linkSeatView;
        string temporary;
        
        for(uint i = 0; i < rows; i++){
            linkSeatView = _linkSeatView;
            string s2 = uint2str(i);
            temp = (s1.toSlice().concat(s2.toSlice())); // /row/ + i
            linkSeatView = (linkSeatView.toSlice().concat(temp.toSlice())); //linkSeatView + /row/ + i
            temporary = linkSeatView;
            
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                temp = (s3.toSlice().concat(uint2str(j).toSlice())); // "/" + j
                linkSeatView = (linkSeatView.toSlice().concat.temp.toSlice()); // linkSeatView + / + j
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
                linkSeatView = temporary;
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
    constructor(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView, string memory _name){
        name = _name;
    }
    
    function create(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) public {
        Show show = new Show(_title, _amountOfSeatpPerRow, rows, _date, _linkSeatView);
        shows.push(show);
    }
    
    
}