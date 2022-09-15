import { ethers } from "ethers";

import Artifact from "@cont/WithdrawalContract.json";
import contractAddress from "@cont/contract-address.json";

export default () => {
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
              
            const addr = await signer.getAddress();
            const questionText = event.target.questionText.value;
            console.log(event.target.mintPrice.value);
            const mintPrice = ethers.utils.parseEther(event.target.mintPrice.value);
            console.log(event.target.expires.value);
            console.log(mintPrice);
            
            const expires = new Date(Date.parse(event.target.expires.value));
            
            let transaction = await contract.safeMint(addr, questionText, mintPrice, expires.getTime()/1000, { value: mintPrice });
            await transaction.wait()

            alert("Successfully listed your Question!");
        }
        catch(e) {
            alert( "Upload error"+e )
        }

    }
  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label htmlFor="questionText">Text</label>
        <input type="text" id="questionText" name="questionText"/>

        <label htmlFor="mintPrice">mintPrice</label>
        <input type="text" id="mintPrice" name="mintPrice"/>

        <label htmlFor="expires">Expires</label>
        <input type="date" id="expires" name="expires"/>

        <button type="submit" className="bg-green-300 hover:bg-green-200 text-white rounded px-4 py-2">Submit</button>
      </form>
    </div>
  );
};
