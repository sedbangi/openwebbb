
// https://decert.me/challenge/1267b0cc-ac39-47a7-9a4b-2ef482ff2c5c
// chenyuqing

import { createPublicClient, getContract, http, decodeEventLog, parseUnits, formatUnits } from "viem";
import { mainnet } from "viem/chains";

const publicClient = createPublicClient({
    chain: mainnet,
    transport: http('https://mainnet.infura.io/v3/59d76783bf2a4c9e9e202e59876c075f'),
});


// usdc address 
const USDC_ADDRESS = "0xdac17f958d2ee523a2206206994597c13d831ec7";

const TRANSFER_EVENT_SIGNATURE = 'Transfer(address,address,uint256)';

async function keepListenBlock() {
    publicClient.watchBlocks({
        onBlock: (block) => {
            console.log(`New Block - Height: ${block.number}, Hash: ${block.hash}`);
        }
    });
}

keepListenBlock();