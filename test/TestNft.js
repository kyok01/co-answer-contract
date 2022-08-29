const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CAS contract", function () {
  it("NFT mint", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("addresses", owner.address, addr1.address, addr2.address);

    const CoAnswer = await ethers.getContractFactory("CoAnswer");

    const CASContract = await CoAnswer.deploy();
    await CASContract.deployed();

    await CASContract.safeMint(owner.address, "what is your name ?", { value: ethers.utils.parseEther("0.001") });
    await CASContract.connect(addr1).setAnswer(0, "kyok");
    await CASContract.connect(addr2).setAnswer(0, "taro");
    await CASContract.getAnswers(0);
    expect(await CASContract.ownerOf(0)).to.equal(owner.address);
  });
});