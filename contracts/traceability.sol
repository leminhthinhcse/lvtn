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
        counter=0;
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


contract SupplyChain is Ownable, Enterprise {

   // enum typedEvent{harvest, store, packing, shipping, transport, unpacking, sell, addCode}
    //typedEvent public TYPEDEVENT;
    //enum typedProduct{sold, unSold}
    //typedProduct public TYPEDPRODUCT;
    bool alert;
    bytes32[] alertedPosition; //Danh sach cac vi tri canh bao
    uint temp; // Tao ra id
    uint counter;
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
    }

    Batch[] globatches; //Toan bo Lo hang duoc luu tru

    //Cac batch duoc gui tiep theo tu 1 nut
    struct Send {
        Batch[] batches;
        address[] receivers;
    }

    Send[] senders;

    //Cac batch deu gui den cung 1 nut
    struct Receive {
        Batch[] batches;
        address[] senders;
    }

    Receive[] receivers;

    address[] inChainEnterprises; //cac Cong ty tham gia trong chuoi
    mapping (address=>bool) node; //cong ty co tham gia trong chuoi
    mapping (address => uint) layer; //cho biet mot Nut o tang nao trong cay Do thi
    mapping (uint=>address) createdBy; //cho biet Batch thu i do ai tao ra
    mapping (address=>address) acceptedBy; //cho biet cong ty hien tai duoc chap nhan boi cong ty nao truoc do
    mapping (uint=>bool) existedBatch; //cho biet Batch thu i co ton tai khong
    //mapping (uint=>Batch) previousBatch; //cho biet Struct truoc do
    //mapping (uint=>Batch) nextBatch; //cho biet Struct sau no
    mapping (uint=>bool) soldItem; //cho biet san pham da ban chua

    constructor(address _creator)
    public {
        owner = _creator; //Xac dinh chu so huu dau tien cua Lo hang
        layer[owner]=0;
        temp=0;
        counter=0;
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
        uint _end)
    public {
        layer[msg.sender]=layer[_from]+1;
        alert=true;
        alertedPosition.push(_identity);
        globatches.push(Batch({
            typedevent: _typedevent,
            id: temp++,
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
        counter++;

        existedBatch[temp]=true;
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
            globatches.push(Batch({
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
        //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;

    }

    function setStore (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
    }

    function setPacking (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
    }

    function setUnpacking (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
    }

    function setShipping (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
    }

    function setTransport (
        uint _typedevent,
        address _to,
        bytes32 _where,
        uint _when,
        bytes32 _identity,
        bytes32 _what,
        uint _weight,
        uint _quantity)
    public {
            globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
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
        uint _itemId)
    public {
            globatches.push(Batch({
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
        soldItem[_itemId] = true;
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
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
        uint _end)
    public {
        globatches.push(Batch({
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
         //Them Doanh nghiep
        if (isNode(_to)!=true){
            addNode(_to);
            inChainEnterprises.push(_to);
        }
        //Danh dau nguoi tao Event
        createdBy[temp]=msg.sender;
        //Dem so Event
        counter++;

        existedBatch[temp]=true;
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
        uint _end)
    public {
        layer[msg.sender]=layer[_from]+1;
        globatches.push(Batch({
            typedevent: _typedevent,
            id: temp++,
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
        counter++;

        existedBatch[temp]=true;
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
