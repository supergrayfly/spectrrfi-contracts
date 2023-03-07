const hre = require("hardhat");

async function main() {
/*
// deploy payment splitter contract
  const SpectrrPaymentSplitter = await hre.ethers.getContractFactory("SpectrrPaymentSplitter");
  const spectrrPaymentSplitter = await SpectrrPaymentSplitter.deploy();

  await spectrrPaymentSplitter.deployed();

	let splitterAddress = spectrrPaymentSplitter.address

  console.log(`Payment Splitter Contract Address: "${splitterAddress}"`);
*/

// deploy spctrrfi contract
  const SpectrrFi = await hre.ethers.getContractFactory("SpectrrFi");
  const spectrrFi = await SpectrrFi.deploy("0x6cA9a0be1b1A5cec96776bA0Fa4934337215D77A");

  await spectrrFi.deployed();

  // console.log(`SpectrrFi Contract Address: "${spectrrFi.address}"`);
  console.log(`SpectrrFi Contract Address: "${spectrrFi.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
