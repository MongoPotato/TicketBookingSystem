// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketBooking{
    
    struct Seat{
        string title;
        string date;
        uint256 seatNumber;
        uint256 row;
        string linkSeatView;
    }
    //lacks concatenation of strings for linkSeatView
    string title;
    Seat[] private seats;
    string linkSeatView;
    string temporary;
    uint amountOfSeatpPerRow;
    
    
    constructor(string memory _title, uint _amountOfSeatpPerRow, uint rows, string memory _date, string memory _linkSeatView) public{
        title = _title;
        amountOfSeatpPerRow = _amountOfSeatpPerRow;
        linkSeatView = _linkSeatView;
        for(uint i = 0; i < rows; i++){
            //linkSeatView = _linkSeatView;
            //linkSeatView(bytes.concat(bytes("/row/"), "+", bytes(uint2str(i))));
            //linkSeatView = linkSeatView + "/row/" + uint2str(i);
            temporary = linkSeatView;
            for(uint j = 0; j < amountOfSeatpPerRow; j++){
                //linkSeatView = linkSeatView + "/" + uint2str(j);
                seats.push(Seat({title: title, date: _date, seatNumber: j, row: i, linkSeatView: linkSeatView}));
                //linkSeatView = temp;
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