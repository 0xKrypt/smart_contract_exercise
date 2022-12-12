// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//自动动手写一下，按照使用自增整型作为任务 ID，配合 mapping 实现上面逻辑。
//状态按照【未完成，进行中，已完成，已取消】四种状态来做。
contract TodoList{
    enum Status {
        None,//0
        Pending,//1
        Completed,//2
        Canceled// 3
    }
    struct Todo{
        string name;
        Status status;
    }
    mapping(uint256=>Todo) public toDoMap;
    
    uint256 taskId = 0;

    // 创建任务
    function create(string memory name_) external {
        toDoMap[++taskId] = Todo({name:name_,status:Status.None}); 
    }

    function modiName(uint256 taskId_,string memory name_) external {
        // 方法2: 先获取储存到 storage，在修改，在修改多个属性的时候比较省 gas
        Todo storage temp = toDoMap[taskId_];
        temp.name = name_;
    }

    // 修改完成状态1:手动指定完成或者未完成
    function modiStatus1(uint256 taskId_,Status status_) external {
        toDoMap[taskId_].status = status_;
    }

    function getTask(uint256 taskId_) external view
        returns(string memory name_,Status status_){
        Todo storage temp = toDoMap[taskId_];
        return (temp.name,temp.status);
    }

}