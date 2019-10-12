pragma solidity ^0.4.16;

import "./ERC20.sol";

contract GambleGameBak{
    
    mapping(address => Player) internal players;
    
    uint internal currentId;
    ERC20 public erc;
    // ERC20 public erc = ERC20(0x4059E4B81aa04D923e7890bDb23F2179b68C243E);
    // token public erc = token(0x4059E4B81aa04D923e7890bDb23F2179b68C243E);
    
    address mainAddress;
    address tokenAddress;
    
    constructor(address _coinAddress) public {
        currentId = 10000;
        //mainAddress = 0x83dF2aBf22c8E2784c9B6Ae0B20E2e1cbb1cf9d0 ;
        mainAddress = 0x1894881F2C1131c21bb62945f7512ddb273E9037;
        erc = ERC20(_coinAddress);
        tokenAddress = _coinAddress;
    }
    
    function getbalance() public constant returns(address,uint)
    {
        uint a=erc.balanceOf(msg.sender);//查询该代币总量赋值给a
        
        return (msg.sender,a);
    }

    function login(string memory username)public returns (uint,string,address,uint){

        players[msg.sender].id = 1;
        players[msg.sender].name = username;
        players[msg.sender].addr = msg.sender;
        players[msg.sender].balance = 1;
        
        
        return (players[msg.sender].id,players[msg.sender].name,players[msg.sender].addr,players[msg.sender].balance);
    }
    
    function getMainAddress() public constant returns (address){

        return mainAddress;
    }
    
    function checkLogin(address playerAddress) public constant returns (bool){
        return players[playerAddress].addr != 0x0000000000000000000000000000000000000000;
    }
    
    
    function getPlayInfo()public constant returns(uint,string,address,uint){
        return (players[msg.sender].id,players[msg.sender].name,players[msg.sender].addr,players[msg.sender].balance);
    }
    
    function officialTransfer(uint256 amount) public payable returns(uint){
        erc.transferFrom(mainAddress,msg.sender,amount);
        return erc.balanceOf(msg.sender);
    }
    
    function gameTransfer(address _to,uint256 amount) public returns(uint){
        // erc.transferFrom(msg.sender,_to,amount);
        erc.transfer(_to,amount);
        return erc.balanceOf(msg.sender);
    }
    
    function sendToOfficial(uint256 amount) public payable returns(uint){
        // erc.transferFrom(msg.sender,_to,amount);
        0x82092399Fa0c6d24862b741d394367DA406f5feD.transfer(1 ether);
        return erc.balanceOf(msg.sender);
    }
    
    
    
    function selfTransfer() public returns (uint){
        //require(mainAddress != msg.sender);
        mainAddress.transfer(5000000000000000000);
        // return msg.sender.balance;
    }
    
    function selfSend()  public returns (bool){
        return mainAddress.send(1000000000000000000);
    }
    
    function selfBalance() public constant returns (uint){
        return msg.sender.balance;
    }
    
    struct Player{
        uint id;
        string name;
        address addr;
        uint balance;
    }

}