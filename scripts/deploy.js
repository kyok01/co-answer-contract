const hre = require("hardhat");

async function main() {
  const ContractFactory = await ethers.getContractFactory("WithdrawalContract");

  // Start deployment, returning a promise that resolves to a contract object
  const Contract = await ContractFactory.deploy();   
  console.log("Contract deployed to address:", Contract.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });
