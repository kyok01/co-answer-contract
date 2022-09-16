import { GetServerSideProps } from "next";
import { ethers } from "ethers";

import Artifact from "@cont/WithdrawalContract.json";
import contractAddress from "@cont/contract-address.json";
import { useState, useEffect } from "react";
import { Question } from "types/Question";

export default ({ pId }) => {
  const [qs, setQ] = useState<Question>({});
  const [answers, setA] = useState([]);
  useEffect(() => {
    getQuesitonForId();
    getAnswerForId()
  }, []);


  async function getQuesitonForId() {
    //After adding your Hardhat network to your metamask, this code will get providers and signers
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    //Pull the deployed contract instance
    let contract = new ethers.Contract(
      contractAddress.address,
      Artifact.abi,
      signer
    );
    //create an NFT Token
    let transaction = await contract.getQuestionForId(pId);
    console.log(transaction);
    console.log(transaction.expires);
    const question = {
      tokenId: pId,
      price: ethers.utils.formatUnits(
        transaction.mintPrice.toString(),
        "ether"
      ),
      text: transaction.text,
      sender: transaction.sender,
      expires: transaction.expires.toNumber(),
    };

    console.log(question);
    setQ(question);
  }

  async function getAnswerForId() {
    //After adding your Hardhat network to your metamask, this code will get providers and signers
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    //Pull the deployed contract instance
    let contract = new ethers.Contract(
      contractAddress.address,
      Artifact.abi,
      signer
    );
    //create an NFT Token
    let transaction = await contract.getAllAnswers();
    let answerIds = [];
    const rowAnswers = await Promise.all(transaction.filter(async (q, i) => {
      await answerIds.push(i);
      console.log(q)
      console.log(q.tokenId.toNumber())
      const bool = await q.tokenId.toNumber() === pId;
      console.log(bool);
      return false;
  }));
  console.log(rowAnswers);
  
  const answers = await Promise.all(rowAnswers.map(async (q, i) => {
    let item = {
        answerId: answerIds[i],
        text: q.text,
        sender: q.sender,
    }
    return item;
}));
  console.log(answers);
  setA(answers);
  }

  async function handleSubmit(event) {
    // Stop the form from submitting and refreshing the page.
    event.preventDefault();

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();

      let contract = new ethers.Contract(
        contractAddress.address,
        Artifact.abi,
        signer
      );

      const answerText = event.target.answerText.value;
      const qacType = event.target.qacType.value;
      const qacId = event.target.qacId.value;

      let struct;
      if(qacType === "question") {
        struct = await contract.getQuestionForId(qacId);
      }else if (qacType === "answer"){
        struct = await contract.getAnswerForAnswerId(qacId);
      }else if (qacType === "comment"){
        struct = await contract.getCommentForCommentId(qacId);
      }
      const refAddr = struct.sender;

      let transaction = await contract.setAnswer(
        pId,
        answerText,
        qacType,
        qacId,
        refAddr,
      );
      await transaction.wait();

      alert("Successfully listed your Answer!");
      location.reload();
    } catch (e) {
      alert("Upload error" + e);
    }
  }

  return (
    <div>
      <div>
        <p>{qs.tokenId}</p>
        <p>{qs.price}</p>
        <p>{qs.text}</p>
        <p>{qs.sender}</p>
        <p>{qs.expires}</p>
      </div>
      <p>=======</p>
      <div>
        {answers.map((answer, i) => (<div key={i}>{answer.text}</div>))}
      </div>
      <div>
        <form onSubmit={handleSubmit}>
          <label htmlFor="answerText">Text</label>
          <textarea id="answerText" name="answerText" />

          <label htmlFor="qacType">Refference</label>
          <select name="qacType">
            <option value="question">Question</option>
            <option value="answer">Answer</option>
            <option value="comment">Comment</option>
          </select>
          <input type="number" id="qacId" name="qacId" />

          <button
            type="submit"
            className="bg-green-300 hover:bg-green-200 text-white rounded px-4 py-2"
          >
            Submit
          </button>
        </form>
      </div>
    </div>
  );
};

export const getServerSideProps: GetServerSideProps = async (context) => {
  const { id } = context.query;

  return { props: { pId: id } };
};
