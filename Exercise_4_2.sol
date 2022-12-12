// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/*
4_1写的是项目方角度的募集自己。如果是募集平台，肯定是会向 Todo List 那个练习中一样，是有众筹 ID 的；
请按照众筹平台的角度来写一个众筹协议。
使用平台角度写合约
使用 stuct 格式。
【选做】：增加众筹时间的限制
如果规定时间内完成，则结束后转钱给受益人
如果规定时间内没有完成，则资金释放，捐赠者自己取回捐赠资金。
*/
contract CrowdFunding {

    struct Project {
        string name;//项目名称
        uint256 goal;//目标金额
        address owner;//受益人
        uint startTime;
        uint endTime;
    }
    
    enum Status {
        Pending,//0
        pause,//1
        Completed,//2
        Canceled// 3
    }

    Project[] public list; 
    mapping(uint256=>Project) public projects;
    mapping(uint256=>mapping(address=>uint256)) funders;//赞助人赞助金额
    mapping(uint256=>uint256) fundingAmount;// 当前的金额
    mapping(uint256=>mapping(address=>bool)) fundersInserted;
    mapping(uint256=>Status) projectStatus;
    mapping(uint256=>address) projectAdmin;
    address immutable admin;
    uint256 count = 0;

    modifier onlyAdmin() {
        require(msg.sender == admin, unicode"没有管理员权限");
        _;
    }

    constructor(address _admin) {
        require(_admin != address(0), "invalid address");
        admin = _admin;
    }

    function create(address beneficiary_,uint256 goal_,string memory name_,uint time_) external returns(uint256){
        require(beneficiary_!=address(0),"address error");
        require(goal_>0,"goal error");
        require(time_>0,"time error");
        count++;
        uint t = block.timestamp;
        Project memory p = Project(
            {
                name:name_,
                owner:beneficiary_,
                startTime:t,
                endTime:t+time_,
                goal:goal_
            }
        );
        list.push(p);
        projects[count] = p;
        projectAdmin[count] = beneficiary_;
        fundingAmount[count] = 0;
        projectStatus[count] = Status.Pending;
        return count;
    }

    // 资助
    //      可用的时候才可以捐
    //      合约关闭之后，就不能在操作了
    function contribute(uint256 projectId) external payable{
        require(projectStatus[projectId]==Status.Pending,"CrowdFunding is closed");
        funders[projectId][msg.sender] += msg.value;
        fundingAmount[projectId] += msg.value;
        // 1.检查
        if(!fundersInserted[projectId][msg.sender]){
            // 2.修改
            fundersInserted[projectId][msg.sender] = true;
            // 3.操作
            //fundersKey.push(msg.sender);
        }
    }

    // 关闭
    function close(uint256 projectId) external returns(bool){
        // 1.检查
        if(fundingAmount[projectId]<projects[projectId].goal){
            return false;
        }
        uint256 amount = fundingAmount[projectId];

        // 2.修改
        fundingAmount[projectId] = 0;
        projectStatus[projectId] = Status.Completed;

        // 3. 操作
        payable(projects[projectId].owner).transfer(amount);
        return true;
    }

    function getBalance(uint256 projectId) external view returns(uint256){
        return fundingAmount[projectId];
    }
}