const { task } = require("hardhat/config")

task("deploy-fundme","部署合约fundme").setAction(async(taskArgs,hre) => {
    // create factory
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    console.log("contract deploying")
    // deploy contract 
    const fundMe = await fundMeFactory.deploy(300) //合约中的构造函数中的参数
    //wait deploy contract complate
    await fundMe.waitForDeployment()
    console.log("contract has been deployed successfully,contract address is " + fundMe.target);

    //当前运行环境网络是Sepolia
    if(hre.network.config.chainId == 11155111 && process.env.ETHERS_API_KEY){
        //等待区块链中几个节点确认完成
     await fundMe.deploymentTransaction().wait(5)
     console.log("Waiting for 5 confirmations")

     await verifyFundMe(fundMe.target,[300])
    }else {
        console.log("skip verify...")
    }
})

async function verifyFundMe(addr,args) {
    //auto verify
    await hre.run("verify:verify", {
        address: addr,
        constructorArguments: args,
      });
}

module.exports = {}
