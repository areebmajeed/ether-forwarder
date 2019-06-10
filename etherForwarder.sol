pragma solidity 0.5.9;

contract ERC20Interface {
  function transfer(address _to, uint256 _value) public returns (bool success);
  function balanceOf(address _owner) public view returns (uint256 balance);
}

contract etherForwarder {

  address payable public ownerAddress;
  event ForwarderDeposited(address from, uint value, bytes data);
  event TokensFlushed(address tokenContractAddress, address paymentRecipientAddress, uint256 value);
  
  constructor() public {
    ownerAddress = msg.sender;
  }

  modifier onlyOwner {

    if (msg.sender != ownerAddress) {
      revert();
    }

    _;

  }

  function() external payable {

    if(!ownerAddress.send(msg.value)){
      revert();
    }

    emit ForwarderDeposited(msg.sender, msg.value, msg.data);

  }
  
  function changeOwner(address payable newOwnerAddress) public onlyOwner {
      ownerAddress = newOwnerAddress;
  }

  function flushTokens(address tokenContractAddress, address paymentRecipientAddress, uint256 amountToSend) public onlyOwner {

    ERC20Interface instance = ERC20Interface(tokenContractAddress);
    address forwarderAddress = address(this);
    uint256 forwarderBalance = instance.balanceOf(forwarderAddress);

    if (amountToSend > forwarderBalance) {
      revert();
    }

    if (!instance.transfer(paymentRecipientAddress, amountToSend)) {
      revert();
    }

    emit TokensFlushed(tokenContractAddress, paymentRecipientAddress, amountToSend);

  }

  function flush() public {

    uint256 balance = address(this).balance;

    if(!ownerAddress.send(balance)){
        revert();
    }

  }

}
