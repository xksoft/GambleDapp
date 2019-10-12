// pragma solidity ^0.4.24;
pragma solidity ^0.4.16;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
   防止整数溢出问题
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
 
contract StandardToken {
	//使用SafeMath
    using SafeMath for uint256;
   
    //代币名称
    string public name;
    //代币缩写
    string public symbol;
	//代币小数位数(一个代币可以分为多少份)
    uint8 public  decimals;
	//代币总数
	uint256 public totalSupply;
   
	//交易的发起方(谁调用这个方法，谁就是交易的发起方)把_value数量的代币发送到_to账户
    function transfer(address _to, uint256 _value) public returns (bool success);
 
    //从_from账户里转出_value数量的代币到_to账户
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
 
	//交易的发起方把_value数量的代币的使用权交给_spender，然后_spender才能调用transferFrom方法把我账户里的钱转给另外一个人
    function approve(address _spender, uint256 _value) public returns (bool success);
 
	//查询_spender目前还有多少_owner账户代币的使用权
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
 
    function extendBid(uint amount) public returns (bool);
	//转账成功的事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	//使用权委托成功的事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
//设置代币控制合约的管理员
contract Owned {
 
    // modifier(条件)，表示必须是权力所有者才能do something，类似administrator的意思
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;//do something 
    }
 
	//权力所有者
    address public owner;
 
	//合约创建的时候执行，执行合约的人是第一个owner
    constructor() public {
        owner = msg.sender;
    }
	//新的owner,初始为空地址，类似null
    address newOwner=0x0;
 
    //是否为owner
    function isOwner() public constant returns (bool){
        return owner==msg.sender;
    }

	//更换owner成功的事件
    event OwnerUpdate(address _prevOwner, address _newOwner);
 
    //现任owner把所有权交给新的owner(需要新的owner调用acceptOwnership方法才会生效)
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }
 
    //新的owner接受所有权,权力交替正式生效
    function acceptOwnership() public{
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}
 
//代币的控制合约
contract Controlled is Owned{
 
	//创世vip
    constructor() public {
       setExclude(msg.sender,true);
    }
 
    // 控制代币是否可以交易，true代表可以(exclude里的账户不受此限制，具体实现在下面的transferAllowed里)
    bool public transferEnabled = true;
 
    // 是否启用账户锁定功能，true代表启用
    bool lockFlag=true;
	// 锁定的账户集合，address账户，bool是否被锁，true:被锁定，当lockFlag=true时，恭喜，你转不了账了，哈哈
    mapping(address => bool) locked;
	// 拥有特权用户，不受transferEnabled和lockFlag的限制，vip啊，bool为true代表vip有效
    mapping(address => bool) exclude;
 
	//设置transferEnabled值
    function enableTransfer(bool _enable) public onlyOwner returns (bool success){
        transferEnabled=_enable;
		return true;
    }
 
	//设置lockFlag值
    function disableLock(bool _enable) public onlyOwner returns (bool success){
        lockFlag=_enable;
        return true;
    }
 
	// 把_addr加到锁定账户里，拉黑名单。。。
    function addLock(address _addr) public onlyOwner returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr]=true;
        return true;
    }
 
	//设置vip用户
    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){
        exclude[_addr]=_enable;
        return true;
    }
 
	//解锁_addr用户
    function removeLock(address _addr) public onlyOwner returns (bool success){
        locked[_addr]=false;
        return true;
    }

	//控制合约 核心实现
    modifier transferAllowed(address _addr) {
        if (!exclude[_addr]) {
            require(transferEnabled,"transfer is not enabeled now!");
            if(lockFlag){
                require(!locked[_addr],"you are locked!");
            }
        }
        _;
    }
 
}
 
contract XiaomingToken is StandardToken,Controlled {
 
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) internal allowed;
    mapping (address => uint) public lastBonusTime;
	
	constructor() public {
        totalSupply = 1000000000;
        name = "Xiaoming Token";
        symbol = "MC";
        decimals = 0;
        balanceOf[msg.sender] = totalSupply;
    }
 
    function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool success) {
		require(_to != address(0));
		require(_value <= balanceOf[msg.sender]);
 
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(_from) returns (bool success) {
		require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowed[_from][msg.sender]);
 
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    //game 定制功能，定期允许用户领取一次奖励
    function sendBonus(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(now >= (lastBonusTime[_to] + 30 seconds));

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        lastBonusTime[_to] = now;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    
    function extendBid(uint amount) public returns (bool){
		require(owner != address(0));
		require(amount <= balanceOf[msg.sender]);
 
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        balanceOf[owner] = balanceOf[owner].add(amount);
        emit Transfer(msg.sender, owner, amount);
        return true;
    }

}

contract GambleToken is XiaomingToken{

    mapping(address => Player) internal players;
    address internal gameBankAddress;
    // address internal gameBankAddress = 0x41786fc0Cc8B14De336701d819501c46dAFAC1a8;//0x41786fc0Cc8B14De336701d819501c46dAFAC1a8,0x0572dA3eADf083C3CEb9f33cF09C0B37E5EF8211
    uint public gamePool =0;

    constructor() public {
        gameBankAddress = msg.sender;
    }

    //玩家的功能
    function register(string memory username)public returns (string,address,uint){
        players[msg.sender].name = username;
        players[msg.sender].addr = msg.sender;

        return (players[msg.sender].name,players[msg.sender].addr,getBalance());
    }

    //登录
    function login(string memory username)public returns (string,address,uint){
        // return register(username);
        return (players[msg.sender].name,players[msg.sender].addr,getBalance());
    }

    //查看登录情况
    function checkLogin() public constant returns (bool){
        return players[msg.sender].addr != 0x0000000000000000000000000000000000000000;
    }

    //获取用户信息
    function getPlayInfo()public constant returns(string,address,uint,uint){
        return (players[msg.sender].name,players[msg.sender].addr,getBalance(),gamePool);
    }

    
    //游戏功能
    //领取补贴
    // "0x1894881F2C1131c21bb62945f7512ddb273E9037","0x0eA45B1EB39d70C77F106D42655811E11D4B6a74",100000
    function getBonus() public returns (uint){
        uint bonus = 5;

        bool isSuccess = sendBonus(gameBankAddress,msg.sender,bonus);
        if (!isSuccess) bonus = 0;
        return bonus;
    }

    function checkBonus() public constant returns (bool){
        
        return now >= (lastBonusTime[msg.sender] + 30 seconds);
    }

    //投入资金
    function bid(uint amount) public payable returns (bool){
        require(amount < getBalance());
        transfer(gameBankAddress, amount);
        gamePool+=amount;
        emit Transfer(msg.sender, gameBankAddress, amount);
        // gameBankAddress.transfer(amount);
        return true;
    }



    function getBalance() public constant returns (uint){
        return this.balanceOf(msg.sender);
    }    

    //游戏的后台功能
    

    struct Player{
        string name;
        address addr;
    }
}