const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CCcontract", function () {
  it("Import", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("addresses", owner.address, addr1.address, addr2.address);

    const CC = await ethers.getContractFactory("Comment");

    const CContract = await CC.deploy();
    await CContract.deployed();

    await CContract.safeMint(owner.address, "what is your name ?", { value: ethers.utils.parseEther("0.001") });
    await CContract.connect(addr1).setAnswer(0, "kyok");
    await CContract.connect(addr2).setAnswer(0, "taro");
    await CContract.connect(addr2).setSpecificAnswer();
    const arr = await CContract.getAnswersForTokenId(0);
    console.log(arr, typeof arr, arr[0][1], arr[0].sender);
    expect(await CContract.ownerOf(0)).to.equal(owner.address);
    expect(await CContract.getAllAnswers()).to.deep.equal(await CContract.getAnswersForTokenId(0)); //You want to use deep if you're trying to compare objects

    await CContract.connect(addr1).setComment(0, "kyok", {value: ethers.utils.parseEther("0.0001")});
    await CContract.connect(addr2).setComment(0, "taro", {value: ethers.utils.parseEther("0.0001")});
    expect(await CContract.getAllComments()).to.deep.equal(await CContract.getCommentsForTokenId(0)); //You want to use deep if you're trying to compare objects
  });
});