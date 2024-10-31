// https://decert.me/challenge/1267b0cc-ac39-47a7-9a4b-2ef482ff2c5c - （1）
// chenyuqing

import { createPublicClient, http } from "viem";
import { mainnet } from "viem/chains";

const publicClient = createPublicClient({
    chain: mainnet,
    transport: http('https://mainnet.infura.io/v3/59d76783bf2a4c9e9e202e59876c075f'),
});


async function keepListenBlock() {
    publicClient.watchBlocks({
        onBlock: (block) => {
            console.log(`New Block - Height: ${block.number}, Hash: ${block.hash}`);
        }
    });
}

keepListenBlock();