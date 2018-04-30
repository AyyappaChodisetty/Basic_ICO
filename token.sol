pragma solidity ^0.4.15;

/*
This contract defines the admin functions.
*/
contract admined {
  address public admin;

  function admined() public {
    admin = msg.sender;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _; /* Continue the function  */
  }

  /*
  This function transfers the administration to another person.
  */
  function transferAdmin(address newAdmin) onlyAdmin {
    admin = newAdmin;
  }
}

contract Token {

  /* This is a vector of all balances.  */
  mapping (address => uint256) public balanceOf;

  /* Name of the token. */
  string public name;

  /* Symbol of the token (E.g.: BTC, BCH). */
  string public symbol;

  /* How many decimals.  */
  uint8 public decimal;

  /* How many tokens there is. */
  uint256 public totalSupply;

  /* Transfer event that anounces to the network a new transfer between accounts,
  the indexed keyword allows to search for this event by these parameters as filters.

 */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /* Constructor, same name of the contract is mandatory.
   */
  function Token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {

    /* Whoever deploys this contract gets all the coins first.
     */
    balanceOf[msg.sender] = initialSupply;
    totalSupply = initialSupply;
    decimal = decimalUnits;
    name = tokenName;
    symbol = tokenSymbol;
  }

  /* This function will tranfer tokens to the '_to' address.
   */
  function transfer(address _to, uint256 _value) {


  /* Checks if sender has enough balance to transfer.
   */
  if(balanceOf[msg.sender] < _value) revert();

  /* If true, that means an overflow happened.
   */
  if(balanceOf[_to] + _value < balanceOf[_to]) revert();

  balanceOf[msg.sender] -= _value;
  balanceOf[_to] += _value;

  /* Announces the transfer event.
   */
  Transfer(msg.sender, _to, _value);
  }
}

contract AssetToken is admined, Token {
  function AssetToken(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralAdmin)
  Token(initialSupply, tokenName, tokenSymbol, decimalUnits) {
    totalSupply = initialSupply;

    /* If an admin is provided, then... */
    if(centralAdmin != 0) {
      admin = centralAdmin; /* Is the new admin. | É o novo admin .*/
    } else {
      admin = msg.sender;
    }

    balanceOf[admin] = initialSupply;
    totalSupply = initialSupply;
  }

  /* This function creates moke tokens. */
  function mintTokens(address target, uint256 mintedAmount) onlyAdmin {
    balanceOf[target] += mintedAmount;
    totalSupply += mintedAmount;

    /* Publishes on the network the event that this smart contract received
    the mintedAmout and then that it was transfered to the target address.

    */
    Transfer(0, this, mintedAmount);
    Transfer(this, target, mintedAmount);
  }

  /* If crowdsale has limited supply use transfer function, if not use mintTokens.
 */
  function transfer(address _to, uint256 _value) {

    if(balanceOf[msg.sender] < 0) revert();
    if(balanceOf[msg.sender] < _value) revert();
    if(balanceOf[_to] + _value < balanceOf[_to]) revert();

    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    Transfer(msg.sender, _to, _value);

  }
}
