const hre = require("hardhat");

async function main() {
  const SpectrrPaymentSplitter = await hre.ethers.getContractFactory("SpectrrPaymentSplitter");
  const spectrrPaymentSplitter = await SpectrrPaymentSplitter.deploy();

  await spectrrPaymentSplitter.deployed();

  console.log(`Contract Address: "${spectrrPaymentSplitter.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
