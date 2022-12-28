const hre = require("hardhat");

async function main() {
  const SpectrrCore = await hre.ethers.getContractFactory("SpectrrCore");
  const spectrrCore = await SpectrrCore.deploy();

  await spectrrCore.deployed();

  console.log(`Deployed Contract to: "${spectrrCore.address}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
