import { BaseProvider } from '@metamask/providers';

declare global {
    interface Window {
      ethereum: BaseProvider;
    }
  }

import Link from "next/link";
import { useRouter } from "next/router";
import { useEffect, useState } from "react";

import { Button, Flowbite, Navbar } from "flowbite-react";

export const Navbar2 = () => {
      const [connected, toggleConnect] = useState(false);
  const router = useRouter();
  const [currAddress, updateAddress] = useState('0x');

  async function getAddress() {
    const ethers = require("ethers");
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send('eth_requestAccounts', []);
    const signer = provider.getSigner();
    const addr = await signer.getAddress();
    updateAddress(addr);
  }

  async function connectWebsite() {

      const chainId = await window.ethereum.request({ method: 'eth_chainId' });
      if(chainId !== '0x5')
      {
        //alert('Incorrect network! Switch your metamask network to Rinkeby');
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x5' }],
       })
      }
      await window.ethereum.request({ method: 'eth_requestAccounts' })
        .then(() => {
          console.log("here");
          getAddress();
          window.location.replace(router.pathname)
        });
  }

    useEffect(() => {
      let val = window.ethereum.isConnected();
      if(val)
      {
        console.log("here");
        getAddress();
        toggleConnect(val);
      }

      window.ethereum.on('accountsChanged', function(accounts){
        window.location.replace(router.pathname)
      })
    });

  return (
    <div>
    <Navbar fluid={true} rounded={true} >
      <Navbar.Brand href="https://flowbite.com/">
        <img
          src="https://flowbite.com/docs/images/logo.svg"
          className="mr-3 h-6 sm:h-9"
          alt="Flowbite Logo"
        />
        <span className="self-center whitespace-nowrap text-xl font-semibold dark:text-white">
          PLQ
        </span>
      </Navbar.Brand>
      <div className="flex md:order-2 space-x-2 items-center">
        <Button>↓</Button>
        <Button>Ask</Button>
        <div className='flex flex-col'>
        <button className="enableEthereumButton bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded text-sm" onClick={connectWebsite}>{connected? currAddress.substring(0,7)+'...' :"Connect Wallet"}</button>
        {/* <div className='text-bold text-right mr-10 text-sm'>
        {currAddress !== "0x" ? "Connected to":"Not Connected. Please login to view NFTs"} {currAddress !== "0x" ? (currAddress.substring(0,6)+'...'):""}
      </div> */}
        </div>
        
        <Navbar.Toggle />
      </div>
      <Navbar.Collapse>
        <Navbar.Link href="/" active={true}>
          Home
        </Navbar.Link>
        <Navbar.Link href="/questions">Questions</Navbar.Link>
        <Navbar.Link href="/questions">Search</Navbar.Link>
      </Navbar.Collapse>
    </Navbar>
<Button>aaa</Button>
    
    </div>
  );
};
