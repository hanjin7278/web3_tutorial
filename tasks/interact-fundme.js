const { task } = require("hardhat/config")

task("interact-fundme","执行转账测试").addParam("addr","fundme 合约地址").setAction(async(taskArgs,hre) => {
    const fundMefactory = await ethers.getContractFactory("FundMe")
    const fundMe = fundMefactory.attach(taskArgs.addr)

    //初始化2个账户
    const [firstAccount,secondAccount] = await ethers.getSigners()
    //连接第一个账户
    const fundtx = fundMe.fund({value: ethers.parseEther("0.5")})
    await fundtx.wait()
    //检查账户信息
    const balanceOfConstract = await ethers.provider.getBalance(fundMe.target)
    console.log(`balance of the constract is ${balanceOfConstract}`)

     //连接第二个账户
     const fundtxWithSecond = fundMe.connect(secondAccount).fund({value: ethers.parseEther("0.5")})
     await fundtxWithSecond.wait()

     //检查账户信息
    const balanceOfConstractAfterSecond = await ethers.provider.getBalance(fundMe.target)
    console.log(`balance of the constract is ${balanceOfConstractAfterSecond}`)

    //检查账户信息
    const firstAccountBalance = await fundMe.fundersAndAmount(firstAccount.address)
    const SecondAccountBalance = await fundMe.fundersAndAmount(secondAccount.address)
    console.log(`第一个账户地址${firstAccount.address} 的余额为${firstAccountBalance}`)
    console.log(`第二个账户地址${firstAccount.address} 的余额为${secondAccountBalance}`)
})

module.exports = {}