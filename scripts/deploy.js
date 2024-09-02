const hre = require("hardhat");

async function main() {
  // Get the smart contract
  const Degen = await hre.ethers.getContractFactory("DegenGame");

  // Deploy it
  const degen = await Degen.deploy();
  await degen.deployed();

  // Display the contract address
  console.log(`DegenGame token deployed to ${degen.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
