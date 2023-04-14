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

    constructor()
    {
        // optional rules
        name = "";
        symbol = "";
        decimals = ;

        _totalSupply = ;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
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
}
