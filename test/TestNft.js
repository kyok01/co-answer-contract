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
    const arr = await CASContract.getAnswersForTokenId(0);
    console.log(arr, typeof arr, arr[0][1], arr[0].sender);
    expect(await CASContract.ownerOf(0)).to.equal(owner.address);
    expect(await CASContract.getAllAnswers()).to.deep.equal(await CASContract.getAnswersForTokenId(0)); //You want to use deep if you're trying to compare objects

    await CASContract.connect(addr1).setComment(0, "kyok", {value: ethers.utils.parseEther("0.0001")});
    await CASContract.connect(addr2).setComment(0, "taro", {value: ethers.utils.parseEther("0.0001")});
    expect(await CASContract.getAllComments()).to.deep.equal(await CASContract.getCommentsForTokenId(0)); //You want to use deep if you're trying to compare objects
  });
});