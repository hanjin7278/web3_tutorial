require("@nomicfoundation/hardhat-toolbox");
//require("dotenv").config()
require("@chainlink/env-enc").config()
require("@nomicfoundation/hardhat-verify");
require("./tasks/deploy-fundme")
require("./tasks/interact-fundme")
// require("./tasks")

const SEPOLIA_URL = process.env.SEPOLIA_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const PRIVATE_KEY_1 = process.env.PRIVATE_KEY_1
const ETHERS_API_KEY = process.env.ETHERS_API_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks:{
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [PRIVATE_KEY,PRIVATE_KEY_1],
      chainId: 11155111
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      sepolia: ETHERS_API_KEY
    }
  }
};
