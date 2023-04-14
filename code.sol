// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ---------------------------------------------------------------
// ERC20Interface 3-42
// ---------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external  view returns (uint balance);
    function allowance(address tokenOwner, address spender) external  view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event LotteryDrawn(address indexed winner, uint256 bonus);
}

// ---------------------------------------------------------------
// SafeMath library 3-44
// ---------------------------------------------------------------
contract SafeMath {
    function safeAdd (uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "Invalid operation!");
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a==0 || c/a==b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ---------------------------------------------------------------
// ERC20 Content 3-52~3-58
// ---------------------------------------------------------------
contract myToken is ERC20Interface, SafeMath{

    // 3 optional rules
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => uint256) lastFaucetTime;
    address public owner;

    

    constructor()
    {
        // optional rules
        name = "BLOCKCAHINANNIE";
        symbol = "BCA";
        decimals = 18;

        _totalSupply = 10000000000000000000000;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        
        emit Transfer(address(0), owner, _totalSupply);
    }

    // implement mandatory rules
    function totalSupply() public view override returns (uint)
    {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success)
    {
        require(to != msg.sender, "Cannot transfer tokens to own account.");
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        if (msg.sender == owner) {
            _totalSupply = safeSub(_totalSupply, tokens);
        }
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success)
    {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function faucet() public {
        require(msg.sender != owner, "Contract owner cannot claim from faucet.");
        require(lastFaucetTime[msg.sender] + 30 seconds < block.timestamp, "Please wait for 30 seconds to claim again.");
        require(_totalSupply >= 500000000000000000000, "Not enough token for faucet.");

        lastFaucetTime[msg.sender] = block.timestamp;
        _totalSupply = safeSub(_totalSupply, 500000000000000000000);
        balances[owner] = safeSub(balances[owner], 500000000000000000000);
        balances[msg.sender] = safeAdd(balances[msg.sender], 500000000000000000000);

        emit Transfer(address(0), msg.sender, 500000000000000000000);
    }

    address payable public winner;
    address payable[] players;
    uint256 public totalPot;
    uint256 public lastDrawTime;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function random() public view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return randomNumber;
    }

    function betLottery() public payable {
        require(msg.sender != owner, "The owner cannot participate in the lottery.");
        require(balances[msg.sender] >= 100000000000000000000, "The bet amount should be 100 tokens.");
        // require(_totalSupply >= 500, "Not enough token for lottery.");
        // require(totalPot + 100 <= _totalSupply, "Total pot exceeds token supply.");
        balances[msg.sender] = safeSub(balances[msg.sender], 100000000000000000000);
        players.push(payable(msg.sender));
        totalPot += 100000000000000000000;
    }

    function draw() public onlyOwner {
        require(players.length > 0, "At least one lottery ticket must be sold.");
        require(block.timestamp > lastDrawTime + 180, "The banker cannot call the draw function within 3 minutes of the previous draw.");
        uint256 randomNumber = random();
        uint256 index = randomNumber % players.length;

        winner = players[index];

        uint256 bonus = totalPot/ 10 * 9 ;
        uint256 remain = totalPot/ 10 * 1;

        balances[owner] = safeAdd(balances[owner], totalPot);
        _totalSupply = safeAdd(_totalSupply, remain);

        approve(msg.sender, bonus);
        transferFrom(owner, winner, bonus);

        emit LotteryDrawn(winner, bonus);
        totalPot = 0;
        lastDrawTime = block.timestamp;
        delete players;
    }

    function getAllPlayers() public view returns (address payable[] memory) {
        address payable[] memory allPlayers = new address payable[](players.length);
        for (uint i = 0; i < players.length; i++) {
            allPlayers[i] = payable(players[i]);
        }
        return allPlayers;
    }

}