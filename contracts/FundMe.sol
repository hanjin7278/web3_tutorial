// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe{

    //获取ETH兑换美元价格
    AggregatorV3Interface internal dataFeed;

    // 记录收款用户地址和金额
    mapping(address => uint256) public fundersAndAmount;

    //定义最小金额单位eth 1乘以10的18次方 最小100美元
    uint256 MINI_NUM = 100 * 10 ** 18;

    //定义最小金额美元
    uint256 constant TARGET = 1000 * 10 ** 18;

    // 定义所有者
    address owner;

    //定义部署世界
    uint256 deployTimestamp;
    uint256 lockTime;
    //erc20协议地址
    address erc20Addr;

    bool public successFlag = false;

    constructor(uint256 _lockTime){
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        lockTime = _lockTime;
        deployTimestamp = block.timestamp;
    }

    // 1、定义一个收款函数
    function fund() external payable{
        // 交易的eth小于定义的最小金额则revert回退
        require(convertEthToUsd(msg.value) >= MINI_NUM,"Send more ETH");
        require(block.timestamp < deployTimestamp + lockTime,"the contract locked");
        successFlag = true;
        fundersAndAmount[msg.sender] = msg.value;
    }

    function getSuccessFlag() public view returns(bool){
        return successFlag;
    }

    // 返回eth兑换美元的价格
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    // 返回eth数量和价格计算
    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        int chainlinkPrice = getChainlinkDataFeedLatestAnswer(); // 1eth的USD价格
        return ethAmount * uint256(chainlinkPrice) / (10 ** 8);
    }

    // 获取当前合约中的金额
    function getFund() external payable windowClosed onlyOwner{
        //单位默认是wei 需要转换成eth
        require(convertEthToUsd(address(this).balance) >= TARGET,"target is not reched");

        //1、通过transfer转移 将合约内的金额转移到当前账户中
        // payable(msg.sender).transfer(address(this).balance);
        //2、通过send来转移，会返回一个bool，判断是否成功
        //bool success = payable(msg.sender).send(address(this).balance);
        //require(success,"tx fail");
        //3、call类型可以附加参数
        bool success;
        (success,)= payable(msg.sender).call{value:address(this).balance}("");
        require(success,"tx fail");
        fundersAndAmount[msg.sender] = 0;
    }

    //创建转移所有权的函数
    function transferOwnerShip(address newOwner) public onlyOwner{
        owner = newOwner;
    }


    //退款操作
    function refound() external windowClosed{
        //合约中的金额已经达成
        require(convertEthToUsd(address(this).balance) < TARGET,"target is reched");
        //判断当前发送人是否投入
        require(fundersAndAmount[msg.sender] != 0,"you need to give fund firstly");


        bool success;
        (success,)= payable(msg.sender).call{value:fundersAndAmount[msg.sender]}("");
        require(success,"tx fail");
        fundersAndAmount[msg.sender] = 0;
    }

    //设置地址amount
    function setFunderToAmount(address addr,uint256 amount) public{
        //需要erc20地址的合约才能调用
        require(erc20Addr == msg.sender,"only erc20addr can call this fun");
        fundersAndAmount[addr] = amount;
    }

    //设置erc20地址
    function setErc20Addr(address _erc20Addr) external onlyOwner{
        erc20Addr = _erc20Addr;
    }

    modifier windowClosed(){
        require(block.timestamp >= deployTimestamp + lockTime);
        _;
    }

    modifier onlyOwner(){
        require(owner == msg.sender,"this func only for owner");
        _;
    }
}