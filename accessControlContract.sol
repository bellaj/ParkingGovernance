pragma solidity ^0.5;

contract Token{
   
    string public name="Faireaccess_token";
    string public symbol="FTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address admin;
    mapping (address => uint256) public balanceOf;
 
    event Transfer(address indexed from, address indexed to, uint256 value);

 


    function transfer(address _to, uint256 _value) public {
        _to=msg.sender;
        _transfer( admin, _to, _value);
    }

 
      function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
       emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
   
}

contract Acces_control is Token
{
 
uint256 public time_start; // access start time
uint256 public time_end; // access end time
uint256 public now_=now; // access end time

string location;// device location exp "baby room"
mapping(address=>role) white_list;// the whitelisted users
address public ad_device_owner; //device owner

enum role{ //we user User as a global role, but you can define as roles as you need.
    Ressource_Owner,User,Service_Provider
}

function revokeToken() public{
   
}

constructor (string memory device_location,uint256 access_time_start,uint256 access_time_end,uint256 initialSupply) public{ 
    // the constructor initiates the total supply of token access and intial access control parameters (access timeframe, location,...)
   // time is expressed using linux timestamp
        totalSupply = initialSupply * 10 ** uint256(decimals);
        ad_device_owner=msg.sender;
        admin=ad_device_owner;
        white_list[ad_device_owner]=role.Ressource_Owner;
        time_start=access_time_start;
        time_end=access_time_end;
        location=device_location;
        balanceOf[ad_device_owner] = totalSupply;
       
}    


 
   modifier only_ressource_owner() // this modifier restricts the functions execution to the ressource owner
    {
        require(white_list[msg.sender]==role.Ressource_Owner);//check if the request comes from the ressource owner
        _;
    }


event allow_access_event(bool allowed);

    function setRole (address ad, uint256  roleID) public only_ressource_owner // add new whitelisted user or define the role
    {

        if (roleID==0)
            white_list[ad]=role.Ressource_Owner;  
        if (roleID==1)
            white_list[ad]=role.User;  
        if (roleID==2)
            white_list[ad]=role.Service_Provider;  
       
    }

 
    function getrole(address ad) public only_ressource_owner view returns (role) // get whitelisted users' roles
    {
        return white_list[ad];
    }


function access_control_policy(address requester, string memory location_)public returns (bool) { // this function represents an example of access control policy
   
   //herein we take a single example of a policy controling access to a location we call spot_A , within a defined timeframe
   //the request is recieved in a defined intervall for accessing the defined location, then the requester get his access token. 
    if(keccak256(abi.encodePacked(location_))==keccak256(abi.encodePacked("spot_A"))&& now<time_end && now>time_start)
   
    {
                transfer(requester,1);// transfer 1 token to the requester
                emit allow_access_event(true);
                return true;
    }
        else {    
                      revert("Access policy is not set.");
            
        }

}

function Access_Request( string memory Dlocation) public returns (bool){ 
//Access to spot_A is controlled by an IOT object (RaspberryPi), we name this later raspberryA
 // the requester call this function to request an access token to get into spot_A
 
    if(white_list[msg.sender]==role.User) //role check
    {
        access_control_policy(msg.sender, Dlocation);
   
    return true;
    }
    else {
          revert("Access request declined.");
        
    }
   
}

function burn_token(uint256 amount) public{// token is sent back to the contract after the access to the object
    _transfer(msg.sender,ad_device_owner,amount);
}

}
