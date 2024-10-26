// https://decert.me/challenge/982e088b-f252-466b-8311-1a5834a7c8d1
// chenyuqing

import { createPublicClient, getContract, http, decodeEventLog, parseUnits, formatUnits } from "viem";
import { mainnet } from "viem/chains";


const publicClient = createPublicClient({
    chain: mainnet,
    transport: http('https://mainnet.infura.io/v3/59d76783bf2a4c9e9e202e59876c075f'),
});

// usdc address 
const USDC_ADDRESS = '0xA0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
const TRANSFER_EVENT_SIGNATURE = 'Transfer(address,address,uint256)';

async function getRecentUSDCTransfers() {
    // get the latest block number
    const latestBlockNumber = await publicClient.getBlockNumber();

    // 
    const startBlock = latestBlockNumber - BigInt(100);

    const logs = await publicClient.getLogs({
        address: USDC_ADDRESS,
        event: {
            type: 'event',
            name: 'Transfer',
            inputs: [
              { type: 'address', indexed: true },
              { type: 'address', indexed: true },
              { type: 'uint256', indexed: false }
            ]
        },
        fromBlock: startBlock,
        toBlock: latestBlockNumber,
    });

    for (const log of logs) {
        try {
          const decodedLog = decodeEventLog({
            abi: [
              {
                type: 'event',
                name: 'Transfer',
                inputs: [
                  { type: 'address', name: 'from', indexed: true },
                  { type: 'address', name: 'to', indexed: true },
                  { type: 'uint256', name: 'value', indexed: false },
                ],
              },
            ],
            data: log.data,
            topics: log.topics,
          });
    
          if (decodedLog && decodedLog.args) {
            const { from, to, value } = decodedLog.args;
            const formattedValue = formatUnits(value, 6);
            // const formattedValue = parseFloat(parseUnits(value.toString(), BigInt(6))).toFixed(5); // USDC 精度为 6
    
            console.log(
              `从 ${from} 转账给 ${to} ${formattedValue} USDC, 交易ID: ${log.transactionHash}`
            );
          }
        } catch (error) {
          console.error(`Error decoding log: ${error}`);
        }
      }
}

getRecentUSDCTransfers().catch((error) => console.error(`Error fetching USDC transfers: ${error}`));

