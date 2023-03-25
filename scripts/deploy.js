const hre = require("hardhat");

async function main() {
  const SpectrrFi = await hre.ethers.getContractFactory("SpectrrFi");
  const spectrrFi = await SpectrrFi.deploy();

  await spectrrFi.deployed();

  console.log(`SpectrrFi Contract Address: "${spectrrFi.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
