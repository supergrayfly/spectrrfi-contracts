const hre = require("hardhat");

async function main() {
// deploy payment splitter contract
  const SpectrrPaymentSplitter = await hre.ethers.getContractFactory("SpectrrPaymentSplitter");
  const spectrrPaymentSplitter = await SpectrrPaymentSplitter.deploy();

  await spectrrPaymentSplitter.deployed();

	let splitterAddress = spectrrPaymentSplitter.address

  console.log(`Payment Splitter Contract Address: "${splitterAddress}"`);

// deploy spctrrfi contract
  const SpectrrFi = await hre.ethers.getContractFactory("SpectrrFi");
  const spectrrFi = await SpectrrFi.deploy(splitterAddress);

  await spectrrFi.deployed();

  console.log(`SpectrrFi Contract Address: "${spectrrFi.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
