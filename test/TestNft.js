const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CAS contract", function () {
  it("NFT mint", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    console.log("addresses", owner.address, addr1.address, addr2.address);

    const CoAnswer = await ethers.getContractFactory("QACContract");

    const CASContract = await CoAnswer.deploy();
    await CASContract.deployed();

    let d = new Date(Date.UTC(2023, 8, 4, 12, 00, 00));
    const unixS = d.getTime()/1000;
    console.log('unixS' + unixS);

    await CASContract.safeMint(owner.address, "what is your name ?", ethers.utils.parseEther("0.001"), unixS, { value: ethers.utils.parseEther("0.001") });
    await CASContract.connect(addr1).setAnswer(0, "kyok", "a", 1, addr2.address);
    await CASContract.connect(addr2).setAnswer(0, "taro", "a", 1, addr1.address);
    const arr = await CASContract.getAnswersForTokenId(0);
    console.log(arr, typeof arr, arr[0][1], arr[0].sender);
    expect(await CASContract.ownerOf(0)).to.equal(owner.address);
    expect(await CASContract.getAllAnswers()).to.deep.equal(await CASContract.getAnswersForTokenId(0)); //You want to use deep if you're trying to compare objects

    await CASContract.setComment(0, "first");
    await CASContract.connect(addr1).setComment(0, "kyok", {value: ethers.utils.parseEther("0.0001")});
    await CASContract.connect(addr2).setComment(0, "taro", {value: ethers.utils.parseEther("0.0001")});
    const comments = await CASContract.getAllComments();
    console.log(comments);
    expect(await CASContract.getAllComments()).to.deep.equal(await CASContract.getCommentsForTokenId(0)); //You want to use deep if you're trying to compare objects
  });
});