// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// 存钱罐合约
// 所有人都可以存钱
// ETH
// 只有合约 owner 才可以取钱
// 只要取钱，合约就销毁掉 selfdestruct
// 合约版本 V.1
contract TestVersion1 {
    address public sender;
    uint256 public value;
    uint256 public num;

    function set(uint256 num_) external payable {
        sender = msg.sender;
        value = msg.value;
        num = num_;
    }
}

// 合约版本 V.2
contract TestVersion2 {
    address public sender;
    uint256 public value;
    uint256 public num;

    function set(uint256 num_) external payable {
        sender = msg.sender;
        value = msg.value;
        num = num_ * 2;
    }
}

// 委托调用测试
contract DelegateCall {
    address public sender;
    uint256 public value;
    uint256 public num;

    function set(address _ads, uint256 num_) external payable {
        sender = msg.sender;
        value = msg.value;
        num = num_;
        // 第1种 encode
        // 不需知道合约名字，函数完全自定义
        //bytes memory data1 = abi.encodeWithSignature("set(uint256)", num_);
        // 第2种 encode
        // 需要合约名字，可以避免函数和参数写错
        bytes memory data2 = abi.encodeWithSelector(TestVersion1.set.selector, num_);

        (bool success, bytes memory _data) = _ads.delegatecall(data2);

        require(success, "DelegateCall set failed");
    }
}