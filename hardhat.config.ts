import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const privateKey: any  = process.env.PRIVATE_KEY || "";
const mumbai_api_key: any = process.env.MUMBAI_API_KEY
const BSC_API_key: any = process.env.BSC_API_KEY
const mumbaiRPC: any = process.env.MUMBAI_RPC
const bscRPC: any = process.env.BSC_RPC
const config: HardhatUserConfig = {
  // solidity: "0.8.20",
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true
    },
  },

  networks: {
    mumbai: {
      url: " https://polygon-mumbai-bor.publicnode.com",
      chainId: 80001,
      accounts: [privateKey]
    },
    bscTestnet: {
      url: "https://bsc-testnet.publicnode.com",
      // url: bscRPC,
      chainId: 97,
      accounts: [privateKey]
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: BSC_API_key,
      polygonMumbai: mumbai_api_key,

    }
  }
};

export default config;
