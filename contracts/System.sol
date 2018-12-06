pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract System {
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
    //bool public alert;
    //bytes32[] public alertedLocation; //Danh sach cac vi tri canh bao
    
    
}