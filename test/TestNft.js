const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CAS contract", function () {
  it("NFT mint", async function () {
    const [owner] = await ethers.getSigners();

    const CoAnswer = await ethers.getContractFactory("CoAnswer");

    const CASContract = await CoAnswer.deploy();
    await CASContract.deployed();

    await CASContract.safeMint(owner.address, "https://hardhat.org/tutorial/testing-contracts", { value: ethers.utils.parseEther("0.001") });
    expect(await CASContract.ownerOf(0)).to.equal(owner.address);
  });
});