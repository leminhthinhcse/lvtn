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


contract Enterprise  { //ghi nhan thong tin Doanh nghiep
    bytes32 identityEnt; //Ma so Doanh nghiep
    address accountEnt; //Tai khoan Doanh nghiep
    uint8 indexEnt; //So thu tu Doanh nghiep
    uint8 counterEnt; //So luong chi nhanh
    address addedByEnt; //Duoc them boi
    bytes32[] branches; //Danh sach chi nhanh
    mapping (bytes32=>uint8) orderBranches; //mapping giua chi nhanh va so thu tu cua no

    constructor ( //Ham tao
        bytes32 _identity,
        address _account,
        uint8 _index,
        address _creator)
    public {
        identityEnt = _identity;
        accountEnt = _account;
        indexEnt = _index;
        addedByEnt = _creator;
        //owner = _account;
        counterEnt= 0;
    }

    function addBranch(uint8 _index, bytes32 _identity) public { //Them chi nhanh
        branches.push(_identity);
        counterEnt++;
        orderBranches[_identity]=_index;
    }

    function getIdentity() public view returns (bytes32 name) {
        return identityEnt;

    }

    function getAccount() public view returns (address addr) {
        return accountEnt;
    }

    function getIndex() public view returns (uint8 number) {
        return  indexEnt;
    }

    function getAddedBy() public view returns (address who) {
        return addedByEnt;
    }
    
    function getCountBranches() public view returns (uint8 quantity) {
        return counterEnt;
    }
    
    function getIndexBranches(bytes32 _identity) public view returns (uint8 number) {
        return orderBranches[_identity];
    }
    
    function getBranch(uint8 _index) public view returns (bytes32 name) {
        return branches[_index];
    }
}


contract Supplychain is Ownable {
    bool public alert;
    bytes32[] public alertedPosition; //Danh sach cac vi tri canh bao
    uint public temp; // Tao ra id
    uint public i; //Bien dem theo Next
    uint public j; //Bien dem theo Previous
    address[] public inChainEnterprises; //cac Cong ty tham gia trong chuoi
    
    mapping (address=>bool) public node; //cong ty co tham gia trong chuoi
    mapping (address => uint) public layer; //cho biet mot Nut o tang nao trong cay Do thi
    mapping (uint=>address) public createdBy; //cho biet Batch thu i do ai tao ra
    mapping (uint=>bool) public existedBatch; //cho biet Batch thu i co ton tai khong
    mapping (uint=>bool) public soldItem; //cho biet san pham da ban chua
    mapping (bytes32=>uint) public idBatch; //Cho biet id cua Batch khi biet Identity
    mapping (bytes32=>address) public Of; //Chu so huu Batch la ai
    mapping (uint=>uint[]) public countNext; //NextPointer tai 1 nut
    mapping (uint=>uint[]) public countPrev; //PreviousPointer tai 1 nut
    mapping (uint=>uint) public soldAt;

   // enum typedEvent{harvest, store, packing, shipping, transport, unpacking, sell, addCode}
    //typedEvent public TYPEDEVENT;
    //enum typedProduct{sold, unSold}
    //typedProduct public TYPEDPRODUCT;
   
    //address creator;
    //owner=creator;

    struct Batch {
    //    uint typedevent;
        uint id;
        uint layerIndex;
        uint weight;
        uint quantity;
        uint startI;
        uint endI;
        uint when;
        address frOm;
        address tO;
        bytes32 position;
        bytes32 identity;
        bytes32 item;
      
    }

    Batch[] public globatches; //Toan bo Lo hang duoc luu tru
    
   
    
    //Cac batch duoc gui tiep theo tu 1 nut
    struct Next { 
        uint id;
        address receiver;
    }

    Next[] public nexts; //Toan bo con tro Next

    //Cac batch deu gui den cung 1 nut 
    struct Previous {
        uint id;
        address sender;
    }
    
    Previous[] public previouses;

    modifier onlyNode() {
        require(node[msg.sender] == true);
        _;
    }

    constructor (address _creator)
    public {
        owner = _creator; //Xac dinh chu so huu dau tien cua Lo hang
        layer[owner]=0;
        temp=0;
        i=0;
        j=0;
        //Them Doanh nghiep
        if (isNode(msg.sender)!=true){
            addNode(msg.sender);
            inChainEnterprises.push(msg.sender);
        }
        
        //counter=0;
    }
    
    function isExisted(uint _id) public view returns (bool){
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
    
    function isStatus()public view returns(bool){
        return alert;
    }
    
    function setNext(uint _id, address _receiver) public {
        nexts.push(Next({
            id: _id,
            receiver: _receiver
        }));
    }
    
    function setPrevious(uint _id, address _sender) public{
        previouses.push(Previous({
            id: _id,
            sender: _sender
        }));
    }
    
    function setNextPoint(uint _idCurBatch) public{
        setNext(_idCurBatch,msg.sender);
    }
    
    function setPreviousPoint(bytes32 _identityPrevBatch)public{
        setPrevious(idBatch[_identityPrevBatch],Of[_identityPrevBatch]);
    }
    
    function setAlert (
        //uint _typedevent,
        address _from,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public onlyNode {
        layer[msg.sender]=layer[_from]+1;
        alert=true;
        alertedPosition.push(_identity);
        temp=temp+1;
        globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: _from,
            tO: msg.sender,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setHarvest(
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        //i=i++;
        //j=j++;
        
    }
    
    function setStore (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex:layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setPacking (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex:layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setUnpacking (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
   }

    function setShipping (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }

    function setTransport (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }

    function setSell (
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        uint _productId,
        bytes32 _identityPrevBatch)
    public onlyNode{
            temp=temp+1;
            globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
            weight: _weight,
            quantity: _quantity,
            startI:0,
            endI: 0
        }));
        soldItem[_productId] = true;
        soldAt[_productId]=temp;
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }

    function setaddCode(
        //uint _typedevent,
        address _to,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public onlyNode{
        temp=temp+1;
        globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: msg.sender,
            tO: _to,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }
    
    function setReceive(
        //uint _typedevent,
        address _from,
        bytes32 _position,
        uint _when,
        bytes32 _identity,
        bytes32 _item,
        uint _weight,
        uint _quantity,
        uint _start,
        uint _end,
        bytes32 _identityPrevBatch)
    public onlyNode{
        temp=temp+1;
        layer[msg.sender]=layer[_from]+1;
        globatches.push(Batch({
            //typedevent: _typedevent,
            id: temp,
            frOm: _from,
            tO: msg.sender,
            layerIndex: layer[msg.sender]+1,
            position: _position,
            when: _when,
            identity: _identity,
            item: _item,
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
        Of[_identity]=msg.sender; //Danh dau Chu so huu
        
        i=i+1;
        j=j+1;
        //tao NextPoint cho Batch truoc do
        uint k=idBatch[_identityPrevBatch];
        countNext[k].push(i-1);
        setNextPoint(temp);
        //tao PreviousPoint cho Batch hien tai
        countPrev[temp].push(j-1);
        setPreviousPoint(_identityPrevBatch);
    }
    
    
    function alertWith(bytes32 _identity) public view returns(address){
        return globatches[idBatch[_identity]].frOm;
    }
    
    function alertWith(uint _id) public view returns(address){
        return globatches[_id].frOm;
    }
    
    function alertBy(bytes32 _identity) public view returns(address){
        return createdBy[idBatch[_identity]];
    }
    
    function alertBy(uint _id) public view returns(address){
        return createdBy[_id];
    }
    
    function alertAt(bytes32 _identity) public view returns(bytes32){
        return globatches[idBatch[_identity]].position;
    }
    
    function alertAt(uint _id) public view returns(bytes32){
        return globatches[_id].position;
    }
    
    function getSoldItemInBatch(uint _productId) public view returns(Batch memory batch_){
        return globatches[soldAt[_productId]];
    }
    
    function getSoldBy(uint _productId) public view returns(address){
        return globatches[soldAt[_productId]].frOm;
    }
    
    function getSoldAt(uint _productId)public view returns(bytes32){
        return globatches[soldAt[_productId]].position;
    }
    
    function getCreatBy(bytes32 _identity) public view returns(address){
        return createdBy[idBatch[_identity]];
    }
    
    function getCreatBy(uint _id) public view returns(address){
        return createdBy[_id];
    }
    
    function getLocation(bytes32 _identity) public view returns(bytes32){
        return globatches[idBatch[_identity]].position;
    }
    
     function getLocation(uint _id) public view returns(bytes32){
        return globatches[_id].position;
    }
    
    function getCountBatch() public view returns(uint){
        return globatches.length;
    }
    
    function getBatch(bytes32 _identity) public view returns(Batch memory batch_){
        return globatches[idBatch[_identity]];
    }
    
    function getBatch(uint _id) public view returns(Batch memory batch_){
        return globatches[_id-1];
    }
    
    function getIdBatch(bytes32 _identity) public view returns(uint){
        return idBatch[_identity];
    }
    
    function getNextPoint(uint k) public view returns (uint[] memory nextpointer){
        return countNext[k];
    }
    
    function getPrevPoint(uint k) public view returns (uint[] memory prevpointer){
        return countPrev[k];
    }
}

contract EnterpriseFactory is Ownable {
    Enterprise[] public deployedEnterprises;

    event CreatedEnterprise(Enterprise indexed _newEnterprise);

    function createEnterprise(bytes32 identity, address account, uint8 index) public {
        Enterprise newEnterprise = new Enterprise(identity, account, index, msg.sender);
        emit CreatedEnterprise(newEnterprise);
        deployedEnterprises.push(newEnterprise);
    }

    function getDeployedEnterprises() public view returns (Enterprise[] memory enterprises) {
        return deployedEnterprises;
    }
}

contract SupplychainFactory is Ownable {
    Supplychain[] public deployedRoots;

    event CreatedRoot(Supplychain indexed _root);

    function createRoot() public {
        Supplychain newsupplychain = new Supplychain(msg.sender);
        deployedRoots.push(newsupplychain);
        emit CreatedRoot(newsupplychain);
    }

    function getDeployedRoots() public view returns (Supplychain[]  memory roots) {
        return deployedRoots;
    }
}
