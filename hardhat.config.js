require('@nomicfoundation/hardhat-toolbox');
require('hardhat-abi-exporter');
require('solidity-docgen')
require('dotenv').config()

const privKey = process.env.PRIV_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'fantom_testnet',
  networks: {
     mumbai_testnet: {
			 url: 'https://rpc-mumbai.maticvigil.com/',
       accounts: [privKey],
       gasPrice: 1500000000,
     },
    fantom_testnet: {
      url: 'https://rpc.testnet.fantom.network/',
      accounts: [privKey],
      gasPrice: 3500000000,
    },
    fantom_mainnet: {
      url: 'https://rpc.ftm.tools',
      accounts: [privKey],
      // gasPrice: gasPrice
    },
    bsc_testnet: {
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
        runs: 300,
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
	/*
	docgen: {
  	path: './docgen',
  	clear: true,
  	runOnCompile: true,
	}
	*/
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
