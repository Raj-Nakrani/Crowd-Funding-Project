// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;



contract CrowdFunding{
    mapping(address=>uint) public contributers;
    address public manager;
    uint minimumcontribution;
    uint public target;
    uint public Noofcontributers;
    uint public raisedamount;
    uint public deadline;

struct Request{
    string discription;
    uint value;
    address payable reciepent;
    bool completed;
    uint noofvoters;
    mapping(address=>bool) voters;
    
}  

mapping (uint=>Request) public requests;
uint public numrequest;
 

    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp + _deadline;
        manager=msg.sender;
        minimumcontribution = 100 wei;
    }

    function sendEth() public payable{
         require(block.timestamp<deadline,"Deadline Has beeen Passed");
         require(msg.value>=minimumcontribution,"Minimuncontribution is not enough");

         if (contributers[msg.sender]==0){
             Noofcontributers++;
         }
         contributers[msg.sender]+=msg.value;
         raisedamount+=msg.value;
        
    }

     function getcontractbalance() view public returns(uint){
         return address(this).balance;
     }

     function refund() public{
         require(block.timestamp>deadline && raisedamount>=target," You Are Not Eligble to refund");
         require(contributers[msg.sender]>=minimumcontribution);
         address payable user=payable(msg.sender);
         user.transfer(contributers[msg.sender]);
         contributers[msg.sender]=0;

     }

      modifier onlymanager(){
         require(msg.sender==manager,"Only Manager can call this function");
         _;
     }

    function CreateRequest(string memory _discription,uint _value,address payable _reciepent) onlymanager public{
        Request storage newRequest=requests[numrequest];
        numrequest++;
        newRequest.discription=_discription;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noofvoters=0;

    }

    function voteRequest(uint _requestid) public{
        require(contributers[msg.sender]>0);
        Request storage thisRequest=requests[_requestid];
        require(thisRequest.voters[msg.sender]==false,"You are Already Voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noofvoters++;
        }

    function makepayment(uint _requestNo) onlymanager public{
        require(raisedamount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The Request Has Been Completed");
        require(thisRequest.noofvoters>=Noofcontributers/2,"Majority Does Not Support");
        thisRequest.reciepent.transfer(thisRequest.value);
        thisRequest.completed==true;
    }
}