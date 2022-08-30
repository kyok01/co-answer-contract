const hre = require("hardhat");

async function main() {
  const Comment = await ethers.getContractFactory("Comment");

  // Start deployment, returning a promise that resolves to a contract object
  const CommentContract = await Comment.deploy();   
  console.log("Contract deployed to address:", CommentContract.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });
