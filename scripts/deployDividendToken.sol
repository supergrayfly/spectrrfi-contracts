const hre = require("hardhat");

const names = ['SpectrrFi Dividend MATIC', 'SpectrrFi Dividend BTC', 'SpectrrFi Dividend ETH', 'SpectrrFi Dividend USDT'];
const symbols = ['SDMATIC', 'SDBTC', 'SDETH', 'SDUSDT'];
const supply = '100000000000000000000000'
const paymentTokenAddresses = ['0xD773e8e23fC58d84f28b2C6cE78e3Ce4ADDe4Eb7', '0xB91F94a1097C57BF6E73B351Ba032CFB3E000171', '0x467233d786C768fa8048F4306bbccBd6e2543aA8', '0xFD2C06156e716269a657c347DBAf45c637d2933c'];
const spectrrFiAddress = '0xd0bd4f46D59ff4Fe28C721f529F0E3798B77342B';

async function main() {
	const SpectrrFiDividendToken = await hre.ethers.getContractFactory("SpectrrFiDividendToken");

	for (var i = 0; i < names.length; i++) {
		var spectrrFiDividendToken = await SpectrrFiDividendToken.deploy(
			names[i],
			symbols[i],
			supply,
			paymentTokenAddresses[i],
			spectrrFiAddress
		);

		await spectrrFiDividendToken.deployed();

  	console.log(`SpectrrFi Dividend Token Contract Address: "${spectrrFiDividendToken.address}"`);
	}
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
