import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const privateKey: any = process.env.PRIVATE_KEY || "";
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
      // viaIR: true
    },
  },

  networks: {
    mumbai: {
      url: " https://polygon-mumbai-bor.publicnode.com",
      chainId: 80001,
      accounts: ["019756cded143683a0dafcfa19004f6efcfd8989a3e3bad590b490005ef31599"]
    },
    bscTestnet: {
      url: "https://bsc-testnet.publicnode.com",
      // url: bscRPC,
      chainId: 97,
      accounts: ["019756cded143683a0dafcfa19004f6efcfd8989a3e3bad590b490005ef31599"]
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: "FUFZFC8P2PFBBTDN3EZ3288I3MPE8M37SY",
      polygonMumbai: mumbai_api_key,

    }
  }
};

export default config;
