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
      url: 'https://rpc.testnet.fantom.network/',
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
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000,
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

task(
  'flat',
  'Flattens and prints contracts and their dependencies (Resolves licenses)'
)
  .addOptionalVariadicPositionalParam(
    'files',
    'The files to flatten',
    undefined,
    types.inputFile
  )
  .setAction(async ({ files }, hre) => {
    let flattened = await hre.run('flatten:get-flattened-sources', { files });

    // Remove every line started with "// SPDX-License-Identifier:"
    flattened = flattened.replace(
      /SPDX-License-Identifier:/gm,
      'License-Identifier:'
    );
    flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

    // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
    flattened = flattened.replace(
      /pragma experimental ABIEncoderV2;\n/gm,
      (
        (i) => (m) =>
          !i++ ? m : ''
      )(0)
    );
    console.log(flattened);
  });
