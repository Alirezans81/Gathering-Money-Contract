pragma solidity >=0.5.0;

import "./SafeMath.sol";
import "./TheToken.sol";

contract MoneyGathering is TheToken {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    struct investment {
        string Name;
        address payable Address;
        address recommender;
        uint Balance;
        uint Remain;
        bool Done;
    }

    struct investor {
        address payable Address;
        uint[] InvestBalancePerIndex;
        uint TotalBalance;
        uint totalYes;
        uint totalNo;
    }

    investment[] public investments;
    investor[] public investors;

    function setNewInvestment(string memory _name, address payable _address, uint _balance) external {
        require (_address != msg.sender);
        investments.push(investment(_name, _address, msg.sender, _balance, _balance, false));
    }

    function viewInvestments() external view returns(investment[] memory) {
        return investments;
    }
    
    function viewMyInvests() external view returns(uint[] memory) {
        uint myIndex = getUserIndex(msg.sender);
        return investors[myIndex].InvestBalancePerIndex;
    }

    function deposit(uint _index) external payable {

        investment storage invest = investments[_index];
        require (invest.Done == false);
        require (invest.Remain >= msg.value);

        invest.Remain -= msg.value;

        if (invest.Remain == 0) {
            doneInvestment(_index);
        }

        //////////////////////
        
        uint myIndex;
        uint isZero = 0;
        for (uint i = 0; i < investors.length; i++) {
            if (investors[i].Address == msg.sender) {
                myIndex = i;
                if (i == 0) {
                    isZero = 1;
                }
            }
        }

        if (myIndex > 0 || isZero == 1) {
            investors[myIndex].InvestBalancePerIndex[_index] += msg.value;
            investors[myIndex].TotalBalance += msg.value;
        } else {
            uint[] memory investArray;
            for (uint i = 0; i < investors.length; i++) {
                if (i == _index) {
                    investArray[i] = msg.value;
                } else {
                    investArray[i] = 0;
                }
            }

            investors.push(investor(payable(msg.sender), investArray, msg.value, 0, 0));
        }


    }

    function withdraw(uint _index, uint _value) external {

        uint myIndex;
        uint isZero = 2;
        for (uint i = 0; i < investors.length; i++) {
            if (investors[i].Address == msg.sender) {
                myIndex = i;
                if (i == 0) {
                    isZero = 1;
                } else {
                    isZero = 0;
                }
            }
        }
        require (myIndex != 2);
        require (investors[myIndex].Address == msg.sender);
        require (investors[myIndex].InvestBalancePerIndex[_index] >= _value);

        investors[myIndex].InvestBalancePerIndex[_index] -= _value;
        investments[_index].Remain += _value;
        
        payable(msg.sender).transfer(_value);
    }
    
    function updateInvestment(uint _index, address payable _address, uint _addBalance) external {
        
        investments[_index].Address = _address;
        investments[_index].Balance += _addBalance;
        investments[_index].Remain += _addBalance;
    }

    function doneInvestment(uint _index) private {
        investment storage invest = investments[_index];
        invest.Done = true;
        invest.Address.transfer(invest.Balance);
    }
}