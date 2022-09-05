const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Co-Answer contract", function () {
  async function deployTokenFixture() {
    const CAS = await ethers.getContractFactory("WithdrawalContract");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const CASContract = await CAS.deploy();

    await CASContract.deployed();

    // Fixtures can return anything you consider useful for your tests
    return { CASContract, owner, addr1, addr2 };
  }
  it("NFT mint", async function () {
    const {CASContract, owner, addr1, addr2} = await loadFixture(deployTokenFixture);

    let d = new Date(Date.UTC(2023, 8, 6, 12, 00, 00));
    const unixS = d.getTime()/1000;
    // console.log('unixS' + unixS);

    await CASContract.safeMint(owner.address, "what is your name ?", ethers.utils.parseEther("0.001"), unixS, { value: ethers.utils.parseEther("0.001") });
    await CASContract.connect(addr1).setAnswer(0, "kyok", "a", 1, addr2.address);
    await CASContract.connect(addr2).setAnswer(0, "taro", "a", 1, addr1.address);
    const arr = await CASContract.getAnswersForTokenId(0);
    // console.log(arr, typeof arr, arr[0][1], arr[0].sender);
    expect(await CASContract.ownerOf(0)).to.equal(owner.address);
    expect(await CASContract.getAllAnswers()).to.deep.equal(await CASContract.getAnswersForTokenId(0)); //You want to use deep if you're trying to compare objects

    await CASContract.setComment(0, "first");
    await CASContract.connect(addr1).setComment(0, "kyok", {value: ethers.utils.parseEther("0.0001")});
    await CASContract.connect(addr2).setComment(0, "taro", {value: ethers.utils.parseEther("0.0001")});
    const comments = await CASContract.getAllComments();
    // console.log(comments);
    expect(await CASContract.getAllComments()).to.deep.equal(await CASContract.getCommentsForTokenId(0)); //You want to use deep if you're trying to compare objects

    await CASContract.setBestAnswer(0, 1);
    const bAId = await CASContract.getBAIdForTId(0);
    const bA = await CASContract.getBestAnswerForBAId(bAId);
    expect(parseInt(bA.aId._hex, 16)).to.equal(1);

    const amount = await CASContract.connect(addr1).getWithdrawableAmount();
    await CASContract.connect(addr1).withdraw();
    console.log(amount.toString());
    const addr1Balance = await ethers.getDefaultProvider().getBalance(addr1.address);
    console.dir('addr1' + addr1Balance)
  });
});