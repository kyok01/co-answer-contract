import Artifact from "../contracts/WithdrawalContract.json";
import contractAddress from "../contracts/contract-address.json";
import { useState, useEffect } from "react";

import { ethers } from "ethers";

export default () => {
    const [qs, setQ] = useState([]);
    useEffect(() => {
        getAllQuesitons();
    }, []);
    
    async function getAllQuesitons() {
        const ethers = require("ethers");
        //After adding your Hardhat network to your metamask, this code will get providers and signers
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        //Pull the deployed contract instance
        let contract = new ethers.Contract(contractAddress.address, Artifact.abi, signer)
        //create an NFT Token
        const addr = await signer.getAddress();
        let transaction = await contract.getAllQuestions();
        console.log(transaction);

        const questions = await Promise.all(transaction.map(async (q, i) => {
            let price = ethers.utils.formatUnits(q.mintPrice.toString(), 'ether');
            let item = {
                tokenId: i,
                price,
                text: q.text,
                sender: q.sender,
                expires: q.expires.toNumber()
            }
            return item;
        }));
        console.log(questions);
        setQ(questions);
    }

    return (
        <div>
            Enter
            {qs.map((q,i) => (<div key={i}>{q.text}</div>))}
        </div>      
    );
}