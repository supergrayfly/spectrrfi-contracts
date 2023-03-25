require('@nomicfoundation/hardhat-toolbox');
require('hardhat-abi-exporter');
require('solidity-docgen')
require('dotenv').config()

const privKey = process.env.PRIV_KEY

module.exports = {
  defaultNetwork: 'mumbai',
  networks: {
     mumbai: {
       url: 'https://rpc-mumbai.maticvigil.com/',
       accounts: [privKey],
       gasPrice: 1500000000,
     },
    fantomTestnet: {
      url: 'https://endpoints.omniatech.io/v1/fantom/testnet/public',
      accounts: [privKey],
      gasPrice: 3500000000,
    },
    fantomOpera: {
      url: 'https://rpc.ftm.tools',
      accounts: [privKey],
      // gasPrice:
    },
    bscTestnet: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      accounts: [privKey],
      gasPrice: 10000000000,
    }
  },
  solidity: {
    version: '0.8.12',
    settings: {
      optimizer: {
        enabled: true,
        runs:	10000,
      },
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  abiExporter: {
    path: './abis/',
    flat: true,
    runOnCompile: true,
    clear: true,
    format: 'json',
  }
};
