pragma solidity ^0.4.23;
import "./Ownable.sol";
import "./erc721.sol";
import "./SafeMath.sol";

contract Wheel is Ownable {
    
using SafeMath for uint;


uint private random;
bytes32 private oraclizeID;

uint256 private minBet = 100000000000000000; //unit -> wei
uint256 private maxBet = 1000000000000000000; //unit -> wei
uint256 private pow = 10**16;


/* mappings */
mapping(address => uint256) internal addressToBalance;
mapping(uint => uint) internal rewards;


/* events */
event Transfer(address _from, address _to, uint256 _amount);
event RandomNumber(uint _randomNumber);
event RewardAmount(uint256 _amount);
event AmountSend(uint _amount);
event NewOraclizeQuery(string description);
event NewRandom(uint random);



constructor(){
//initializing rewards
uint temp = 15;
    for(uint i=0; i<10; i++){
        rewards[i]=temp;
        rewards[i+10]=temp;

        temp=temp.add(15);
    }
}


function checkAddressToBalance(address player) public view returns (uint256) {
    return addressToBalance[player];
}


function getReward(uint index) private returns(uint) {
    return rewards[index];
}

function randomGen() private {
        random = (uint(keccak256(blockhash(block.number-1), block.timestamp )) % 20);
        emit NewRandom(random);
    }


function getRandomNumber() private returns(uint) {
    return random;
}

function calculateReward(uint _randomNumber, uint256 betAmount) private returns(uint256){
    return rewards[_randomNumber].mul(betAmount).div(100);
}

mapping (address => uint) remainBalance;
//on spin click
uint private a ;
function init() public payable {
   require(msg.value <= maxBet);
   require(msg.value >= minBet);
   addressToBalance[msg.sender]  = addressToBalance[msg.sender].add(msg.value);

   randomGen();
   a = calculateReward(random, msg.value); //msg.value has wei amount
//    emit RewardAmount(a);
   transferToUser(a);

}

function setMinimumBet(uint256 value) public onlyOwner{
  minBet = value;
}

function setMaximumBet(uint256 value) public onlyOwner{
  maxBet = value;
}


function getContractBalance () public view returns (uint){
    return address(this).balance;
}

function claimRemainingBalance() external returns (uint){
    if(remainBalance[msg.sender] == 0 )
        return 0;
        uint amount = remainBalance[msg.sender];
    if(msg.sender.send(amount)){
        remainBalance[msg.sender] = 0;
        return 1; // 1 signifies "everthing went correct";
    }
        return 404; // 404 is a num that signifies "something went wrong" ;
    
}

function transferToUser(uint256 amount) private returns (string){
  require(addressToBalance[msg.sender] > 0);
  if( msg.sender.send(amount))
       return 'true';

    remainBalance[msg.sender] += amount;
    return 'false';
}

}
