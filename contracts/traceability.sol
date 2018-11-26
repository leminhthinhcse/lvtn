pragma solidity ^0.4.25;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Enterprise is Ownable{ //ghi nhan thong tin Doanh nghiep
    bytes32 identity;
    address account;
    uint index;
    address addedBy;
    mapping (uint=>bytes32) public branches;
    
    function Enterprise (
        bytes32 _identity, 
        address _account, 
        uint _index, 
        address _creator
    )public{
        identity=_identity;
        account=_account;
        index=_index;
        addedBy=_creator;
        owner=_account;
    }
    
    function addBranch(uint _index, bytes32 _identity) onlyOwner public{
        branches[_index]=_identity;
    }
    
    function getIdentity() public view returns (bytes32 identity_){
        identity_=identity;
        
    }
    
    function getAccount() public view returns (address account_){
        account_=account;
    }
    
    function getIndex() public view returns (uint index_){
        index_=index;
    }
    
    function getAddedBy() public view returns (address addedBy_){
        addedBy_=addedBy;
    }
}

contract SupplyChain is Ownable, Enterprise{
    
   // enum typedEvent{harvest, store, packing, shipping, transport, unpacking, sell, addCode}
    //typedEvent public TYPEDEVENT;
    //enum typedProduct{sold, unSold}
    //typedProduct public TYPEDPRODUCT;
    bool alert;
    uint[] alertedPosition;
    uint temp=0;
    uint root=0;
    address creator;
    //owner=creator;
    
    struct Batch{
        uint typedevent;
        uint id;
        address frOm;
        address tO;
        uint layerIndex;
        bytes32 where;
        uint when;
        bytes32 identity;
        bytes32 what;
        uint weight;
        uint quantity;
        uint startI;
        uint endI;
    }
    
    Batch[] batches;
    
    struct Send{
        Batch[] Batches;
        address[] Receivers;
    }
    
    Send[] senders;
    
     struct Receive{
        Batch[] Batches;
        address[] Senders;
    }
    Receive[] receivers;
    
    address[] inChainEnterprises; //cac Cong ty tham gia trong chuoi
    mapping (address=>bool) node; //cong ty co tham gia trong chuoi
    mapping (address => uint) layer; //cho biet mot Nut o tang nao trong cay Do thi
    mapping (uint=>address) createdBy; //cho biet Batch thu i do ai tao ra
    mapping (address=>address) acceptedBy; //cho biet cong ty hien tai duoc chap nhan boi cong ty nao truoc do
    mapping (uint=>Batch) previousBatch; //cho biet Struct truoc do
    mapping (uint=>Batch) nextBatch; //cho biet Struct sau no
    mapping (uint=>bool) soldItem;
    
   
    function SupplyChain(
        address _creator
        )
    public{
        creator=_creator; //Xac dinh chu so huu dau tien cua Lo hang
        //layer[owner]=0;
    }
     
    function setHarvest(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    }
    function setStore(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex:layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    }   
    function setPacking(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity)public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    }  
    function setUnpacking(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    }   
    function setShipping(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    }   
    function setTransport(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
    } 
    function setSell(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity, uint _itemId) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:0,
                endI: 0
            }));
        soldItem[_itemId]=true;
    } 
    function setaddCode(uint _typedevent, address _to, bytes32 _where, uint _when, bytes32 _identity, 
    bytes32 _what, uint _weight, uint _quantity, uint _start, uint _end) public{
        batches.push(Batch({ 
                typedevent: _typedevent,
                id: temp++,
                frOm: msg.sender,
                tO: _to,
                layerIndex: layer[msg.sender]+1,
                where: _where,
                when: _when,
                identity: _identity,
                what: _what,
                weight: _weight,
                quantity: _quantity,
                startI:_start,
                endI: _end
            }));
    }   
}



contract FactoryEnterprise is Ownable{
    address[] public deployedEnterprises;
    event createdEnterprise(Enterprise indexed _newEnterprise);
    function createEnterprise(bytes32 identity, address account, uint index) public {
        address newEnterprise = new Enterprise(identity, account,index, msg.sender);
        //emit createdEnterprise(newEnterprise);
        deployedEnterprises.push(newEnterprise);
    }

    function getDeployedEnterprises() public view returns (address[]) {
       return deployedEnterprises;
    }
}

contract FactoryRoot is Ownable{
   // event createdRoot(address indexed _root);
    address[] public deployedRoots;
    function createRoot() public  {
       address newSupplyChain=new SupplyChain(msg.sender);
       deployedRoots.push(newSupplyChain);
       //emit createdRoot(newSupplyChain);
    }

    function getDeployedRoots() public view returns (address[] memory roots) {
        return deployedRoots;
    }
}



