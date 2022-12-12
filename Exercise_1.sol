// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title 一个模拟同志们好的简单演示
contract HelloComrades {
    /*
     * ========================================
     * State Variables
     * ========================================
     */

    /// @notice 用于标记当前进度
    /// @dev 0:等待领导说"同志们好"，
    /// @dev 1:等待同志们说"领导好"，
    /// @dev 2:等待领导说"同志们辛苦了"
    /// @dev 3:等待同志们说"为人民服务"
    /// @dev 4:等待销毁。
    /// @return 当前进度
    uint8 public step = 0;

    /// @notice 用于标记领导地址
    /// @dev 不可变量，需要在构造函数内指定，以后就不能修改了
    /// @return 当前领导的地址
    address public immutable leader;

    /// @notice 用于遇到错误时的无脑复读机式回复
    string internal constant UNKNOWN =
        unicode"我不知道如何处理它,你找相关部门吧!";

    /*
     * ========================================
     * Events
     * ========================================
     */

    /// @notice 用于对当前 step 被修改时的信息通知
    /// @dev 只要发生 step 修改，都需要抛出此事件
    /// @param 当前修改的最新 step
    event Step(uint8);

    /// @notice 用于对当前合约的金额变动通知
    /// @dev 只要发生金额修改，都需要抛出此事件
    /// @param tag: 标记内容
    /// @param from: 当前地址
    /// @param value: 当前发送金额
    /// @param data: 当前调用的data内容
    event Log(string tag, address from, uint256 value, bytes data);

    /*
     * ========================================
     * Modifier
     * ========================================
     */

    /// @notice 检查只能领导调用
    /// @dev 用于领导专用函数
    modifier onlyLeader() {
        require(msg.sender == leader, unicode"必须领导才能说");
        _;
    }

    /// @notice 检查只能非领导调用
    /// @dev 用于非领导地址检测
    modifier notLeader() {
        require(
            msg.sender != leader,
            unicode"不需要领导回答，需要同志们来回答"
        );
        _;
    }

    /*
     * ========================================
     * Errors
     * ========================================
     */

    /// @notice 自定义的错误，这种注释内容会在错误时显示出来
    /// @dev 用于所有未知错误
    /// This is a message des info.需要上方空一行，才可以显示出来
    error MyError(string msg);

    /*
     * ========================================
     * Constructor
     * ========================================
     */

    /// @dev 用于领导地址的指定，后续不可修改
    constructor(address _leader) {
        require(_leader != address(0), "invalid address");
        leader = _leader;
    }

    /*
     * ========================================
     * Functions
     * ========================================
     */

    /// @notice 用于领导说"同志们好"
    /// @dev 只能在 step 为 0 时调用，只能领导调用，并且只能说"同志们好"
    /// @param content: 当前领导说的内容
    /// @return 当前调用的状态，true 代表成功
    function hello(string calldata content) external onlyLeader returns (bool) {
        if (step != 0) {
            revert(UNKNOWN);
        }
        if (!review(content, unicode"同志们好")) {
            revert MyError(unicode"必须说:同志们好");
        }
        step = 1;
        emit Step(step);
        return true;
    }

    /// @notice 用于同志们说"领导好"
    /// @dev 只能在 step 为 1 时调用，只能非领导调用，并且只能说"领导好"
    /// @param content: 当前同志们说的内容
    /// @return 当前调用的状态，true 代表成功
    function helloRes(string calldata content)
        external
        notLeader
        returns (bool)
    {
        if (step != 1) {
            revert(UNKNOWN);
        }
        if (!review(content, unicode"领导好")) {
            revert MyError(unicode"必须说:领导好");
        }
        step = 2;
        emit Step(step);
        return true;
    }

    /// @notice 用于领导说"同志们辛苦了"
    /// @dev 只能在 step 为 2 时调用，只能领导调用，并且只能说"同志们辛苦了",还需给钱
    /// @param content: 当前领导说的内容
    /// @return 当前调用的状态，true 代表成功
    function comfort(string calldata content)
        external
        payable
        onlyLeader
        returns (bool)
    {
        if (step != 2) {
            revert(UNKNOWN);
        }
        if (!review(content, unicode"同志们辛苦了")) {
            revert MyError(unicode"必须说:同志们辛苦了");
        }
        if (msg.value < 2 ether) {
            revert MyError(unicode"给钱！！！最少2个以太币");
        }
        step = 3;
        emit Step(step);
        emit Log("comfort", msg.sender, msg.value, msg.data);
        return true;
    }

    /// @notice 用于同志们说"为人民服务"
    /// @dev 只能在 step 为 3 时调用，只能非领导调用，并且只能说"为人民服务"
    /// @param content: 当前同志们说的内容
    /// @return 当前调用的状态，true 代表成功
    function comfortRes(string calldata content)
        external
        notLeader
        returns (bool)
    {
        if (step != 3) {
            revert(UNKNOWN);
        }
        if (!review(content, unicode"为人民服务")) {
            revert MyError(unicode"必须说:为人民服务");
        }
        step = 4;
        emit Step(step);
        return true;
    }

    /// @notice 用于领导对
    /// @dev 只能在 step 为 4 时调用，只能领导调用
    /// @return 当前调用的状态，true 代表成功
    function destruct() external onlyLeader returns (bool) {
        if (step != 4) {
            revert(UNKNOWN);
        }
        emit Log("selfdestruct", msg.sender, address(this).balance, "");
        selfdestruct(payable(msg.sender));
        return true;
    }

    /*
     * ========================================
     * Helper
     * ========================================
     */

    /// @notice 用于检查调用者说的话
    /// @dev 重复检测内容的代码抽出
    /// @param content: 当前内容
    /// @param correctContent: 正确内容
    /// @return 当前调用的状态，true 代表内容相同，通过检测
     function review(string calldata content, string memory correctContent)
     private
     pure
     returns(bool){
         return keccak256(abi.encodePacked(content)) == keccak256(abi.encodePacked(correctContent));
     }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    /// @notice 用于获取当前合约内的余额
    /// @dev 一个获取当前合约金额的辅助函数
    /// @return 当前合约的余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}