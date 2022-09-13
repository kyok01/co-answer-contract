import { GetServerSideProps } from "next";
import { ethers } from "ethers";

import Artifact from "@cont/WithdrawalContract.json";
import contractAddress from "@cont/contract-address.json";
import { useState, useEffect } from "react";
import { Question } from "types/Question";

export default ({ pId }) => {
    const [qs, setQ] = useState<Question>({});
  useEffect(() => {
    getQuesitonForId();
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
      price: ethers.utils.formatUnits(transaction.mintPrice.toString(), 'ether'),
      text: transaction.text,
      sender: transaction.sender,
      expires: transaction.expires.toNumber(),
    };

    console.log(question);
    setQ(question);
  }

  return (
    <div>
      <p>{qs.tokenId}</p>
      <p>{qs.price}</p>
      <p>{qs.text}</p>
      <p>{qs.sender}</p>
      <p>{qs.expires}</p>
    </div>
  );
};

export const getServerSideProps: GetServerSideProps = async (context) => {
  const { id } = context.query;

  return { props: { pId: id } };
};
