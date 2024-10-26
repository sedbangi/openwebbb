// https://decert.me/challenge/1fa95fb5-e7d4-40ec-88d4-89d8f4953f15
// chenyuqing

import { createPublicClient, getContract, http } from "viem";
import { mainnet } from "viem/chains";

import { abi, address} from "./abi";


const publicClient = createPublicClient({
    chain: mainnet,
    transport: http()
});

const contract = getContract({
    address: address,
    abi: abi,
    client: publicClient
});


async function getOwnerOfNFT(tokenId: bigint){
    const nftOwner = await contract.read.ownerOf([tokenId]);
    console.log("owner of token no.1 nft is:\n",nftOwner);
}

async function getTokenURIofNFT(tokenId: bigint) {
    const nftUri = await contract.read.tokenURI([tokenId]);
    console.log("URI of token", tokenId,"nft is:\n",nftUri);
}

async function main() {
    const tokenId:bigint = BigInt(1);
    getOwnerOfNFT(tokenId);
    getTokenURIofNFT(tokenId);
}

main();