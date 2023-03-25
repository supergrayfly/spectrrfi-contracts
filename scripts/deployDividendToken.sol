const hre = require("hardhat");

const name = '';
const sym = '';
const supply = '1000000000000000000000000'
const paymentTokenAddress = '';
const spectrrFiAddress = '';

async function main() {
	const SpectrrFiDividendToken = await hre.ethers.getContractFactory("SpectrrFiDividendToken");
	const spectrrFiDividendToken = SpectrrFiDividendToken.deploy(
		name,
		sym,
		supply,
		paymentTokenAddress,
		spectrrFiAddress
	);

  console.log(`SpectrrFi Dividend Token Contract Address: "${spectrrFiDividendToken.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
