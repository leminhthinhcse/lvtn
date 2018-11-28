pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
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


contract Enterprise is Ownable { //ghi nhan thong tin Doanh nghiep
    bytes32 identity; //Ma so Doanh nghiep
    address account; //Tai khoan Doanh nghiep
    uint index; //So thu tu Doanh nghiep
    uint counter; //So luong chi nhanh
    address addedBy; //Duoc them boi
    bytes32[] branches; //Danh sach chi nhanh
    mapping (bytes32=>uint) orderBranches; //mapping giua chi nhanh va so thu tu cua no

    constructor ( //Ham tao
        bytes32 _identity,
        address _account,
        uint _index,
        address _creator)
    public {
        identity = _identity;
        account = _account;
        index = _index;
        addedBy = _creator;
        owner = _account;
        counter= 0;
    }

    function addBranch(uint _index, bytes32 _identity) onlyOwner public { //Them chi nhanh
        branches.push(_identity);
        counter++;
        orderBranches[_identity]=_index;
    }

    function getIdentity() public view returns (bytes32 identity_) {
        identity_ = identity;

    }

    function getAccount() public view returns (address account_) {
        account_ = account;
    }

    function getIndex() public view returns (uint index_) {
        index_ = index;
    }

    function getAddedBy() public view returns (address addedBy_) {
        addedBy_ = addedBy;
    }
    
    function getCountBranches() public view returns (uint count_) {
        count_ = counter;
    }
    
    function getIndexBranches(bytes32 _identity) public view returns (uint index_) {
        index_ = orderBranches[_identity];
    }
    
    function getBranch(uint _index) public view returns (bytes32 identity_) {
        identity_ = branches[_index];
    }
}

contract System{
    bool alert;
    bytes32[] alertedPosition; //Danh sach cac vi tri canh bao
    uint temp; // Tao ra id
    uint i; //Bien dem theo Next
    uint j; //Bien dem theo Previous
    
    address[] inChainEnterprises; //cac Cong ty tham gia trong chuoi
    
    mapping (address=>bool) node; //cong ty co tham gia trong chuoi
    mapping (address => uint) layer; //cho biet mot Nut o tang nao trong cay Do thi
    mapping (uint=>address) createdBy; //cho biet Batch thu i do ai tao ra
    mapping (address=>address) acceptedBy; //cho biet cong ty hien tai duoc chap nhan boi cong ty nao truoc do
    mapping (uint=>bool) existedBatch; //cho biet Batch thu i co ton tai khong
    mapping (uint=>bool) soldItem; //cho biet san pham da ban chua
    mapping (bytes32=>uint) idBatch; //Cho biet id cua Batch khi biet Identity
    mapping (bytes32=>address) own; //Chu so huu Batch la ai
    mapping (uint=>uint[]) countNext; //NextPointer tai 1 nut
    mapping (uint=>uint[]) countPrev; //PreviousPointer tai 1 nut
    
    //Cac batch duoc gui tiep theo tu 1 nut
    struct Next { 
        uint id;
        address receiver;
    }

    Next[] nexts; //Toan bo con tro Next

    //Cac batch deu gui den cung 1 nut 
    struct Previous {
        uint id;
        address sender;
    }

    Previous[] previouses; //Toan bo con tro Previous
}


contract SupplyChain is Ownable, Enterprise, System {

   // enum typedEvent{harvest, store, packing, shipping, transport, unpacking, sell, addCode}
    //typedEvent public TYPEDEVENT;
    //enum typedProduct{sold, unSold}
    //typedProduct public TYPEDPRODUCT;
   
    //address creator;
    //owner=creator;

    struct Batch {
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
        //uint[] next_i;
        //uint[] prev_j;
    }

    Batch[] globatches; //Toan bo Lo hang duoc luu tru

    constructor(address _creator)
    public {
        owner = _creator; //Xac dinh chu so huu dau tien cua Lo hang
        layer[owner]=0;
        temp=0;
        //counter=0;
    }
    
    function getCountBatch() public view returns(uint){
        return globatches.length;
    }
    
    function getBatch(uint _id) public view returns(Batch memory batch_){
        return globatches[_id];
    }
    
    function isExisted1(uint _id) public view returns (bool){
        if (_id<=counter) return true;
    }
    
    function isExisted2(uint _id) public view returns (bool){
        return existedBatch[_id];
    }
    
    function addNode(address _account) public{
        node[_account]=true;
    }
    
    function isNode(address _account) public view returns(bool){
        if(node[_account]==true) return true;
    }
    
    function isSold(uint _id) public view returns(bool){
        return soldItem[_id];
    }
    
    function getIdBatch(bytes32 _identity) public view returns(uint){
        return idBatch[_identity];
    }
    
    function setNext(uint _id, address _receiver) public {
        nexts.push(Next({
            id: _id,
            receiver: _receiver
        }));
    }
    
    function setPrevious(uint _id, address _sender) public {
        previouses.push(Previous({
            id: _id,
            sender: _sender
        }));
    }
    
    function setNextPoint(uint _idCurBatch) public{
        setNext(_idCurBatch,msg.sender);
    }
    
    function setPreviousPoint(bytes32 _identityPrevBatch)public{
        setPrevious(idBatch[_identityPrevBatch],own[_identityPrevBatch]);
    }
    
    function setAlert(
        uint _typedevent,
        address _from,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public {
        layer[msg.sender]=layer[_from]+1;
        alert=true;
        alertedPosition.push(_identity);
        temp=temp++;
        globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
            frOm: _from,
            tO: msg.sender,
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
        
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setHarvest(
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
        //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        //i=i++;
        //j=j++;
        
    }

    function setStore (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setPacking (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setUnpacking (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setShipping (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setTransport (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setSell (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        uint _itemId,
        bytes32 _identityPrevBatch)
    public {
            temp=temp++;
            globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
        soldItem[_itemId] = true;
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }

    function setaddCode(
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public {
        temp=temp++;
        globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setReceive(
        uint _typedevent,
        address _from,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public {
        temp=temp++;
        layer[msg.sender]=layer[_from]+1;
        globatches.push(Batch({
            typedevent: _typedevent,
            id: temp,
            frOm: _from,
            tO: msg.sender,
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
         
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        //counter++;
        
        existedBatch[temp]=true;
        
        idBatch[_identity]=temp; //Danh dau Id Lo hang
        own[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i++;
        j=j++;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j);
        setPreviousPoint(_identityPrevBatch);
    }
}


contract EnterpriseFactory is Ownable {
    Enterprise[] public deployedEnterprises;

    event CreatedEnterprise(Enterprise indexed _newEnterprise);

    function createEnterprise(bytes32 identity, address account, uint index) public {
        Enterprise newEnterprise = new Enterprise(identity, account, index, msg.sender);
        emit CreatedEnterprise(newEnterprise);
        deployedEnterprises.push(newEnterprise);
    }

    function getDeployedEnterprises() public view returns (Enterprise[] memory enterprises) {
        return deployedEnterprises;
    }
}


contract SupplyChainFactory is Ownable {

    event CreatedRoot(SupplyChain indexed _root);

    SupplyChain[] public deployedRoots;

    function createRoot() public {
        SupplyChain newSupplyChain=SupplyChain(msg.sender);
        deployedRoots.push(newSupplyChain);
        emit CreatedRoot(newSupplyChain);
    }

    function getDeployedRoots() public view returns (SupplyChain[] memory roots) {
        return deployedRoots;
    }
}