
pragma solidity 0.4.24;
import "./Token.sol";

contract Crowdsale {
   bool public icoCompleted;
   uint256 public icoStartTime;
   uint256 public icoEndTime;
   uint256 public tokenRate;
   ICOToken public token;
   uint256 public fundingGoal;
   address public owner;
   uint256 public tokensRaised;
   uint256 public etherRaised;

   modifier whenIcoCompleted {
      require(icoCompleted);
      _;
   }
   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

   

   function () public payable {
      buy();
   }
   constructor(uint256 _icoStart, uint256 _icoEnd, uint256 _tokenRate, address _tokenAddress, uint256 _fundingGoal) public {
      require(_icoStart != 0 &&
      _icoEnd != 0 &&
      _icoStart < _icoEnd &&
      _tokenRate != 0 &&
      _tokenAddress != address(0) &&
      _fundingGoal != 0);
      icoStartTime = _icoStart;
      icoEndTime = _icoEnd;
      tokenRate = _tokenRate;
      token = ICOToken(_tokenAddress);
      fundingGoal = _fundingGoal;
      owner = msg.sender;
   }
   function buy() public payable {
      require(tokensRaised < fundingGoal);
      require(now < icoEndTime && now > icoStartTime);
      uint256 tokensToBuy;
      uint256 etherUsed = msg.value;
      tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * tokenRate;
      // Check if we have reached and exceeded the funding goal to refund the exceeding tokens and ether
      if(tokensRaised + tokensToBuy > fundingGoal) {
         uint256 exceedingTokens = tokensRaised + tokensToBuy - fundingGoal;
         uint256 exceedingEther;
         // Convert the exceedingTokens to ether and refund that ether
         exceedingEther = exceedingTokens * 1 ether / tokenRate / token.decimals();
         msg.sender.transfer(exceedingEther);
         // Change the tokens to buy to the new number
         tokensToBuy -= exceedingTokens;
         // Update the counter of ether used
         etherUsed -= exceedingEther;
      }
      // Send the tokens to the buyer
      token.buyTokens(msg.sender, tokensToBuy);
      // Increase the tokens raised and ether raised state variables
      tokensRaised += tokensToBuy;
      etherRaised += etherUsed;
   }
   function extractEther() public whenIcoCompleted onlyOwner {
      owner.transfer(address(this).balance);
   }
}