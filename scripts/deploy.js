const hre = require("hardhat");

async function main() {
  const SpectrrCore = await hre.ethers.getContractFactory("SpectrrCore");
  const spectrrCore = await SpectrrCore.deploy();

  await spectrrCore.deployed();

  console.log(`Contract Address: "${spectrrCore.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
