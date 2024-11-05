import { createClient, http, createPublicClient } from 'viem';
import { mainnet, sepolia } from 'viem/chains';

const client = createPublicClient({
  chain: sepolia,
  transport: http("https://ethereum-sepolia-rpc.publicnode.com")
});


const esRNTAddress = '0xf01eB1130C13415e52629a6b260dfBa0B6758d65';


async function getLockInfo(index: number) {
  // the base slot is zero
  const baseSlot = 0; 

  // 
  const userSlot = baseSlot + index * 3; // address 
  const startTimeSlot = userSlot + 1;    // uint64
  const amountSlot = userSlot + 2;       // uint256

  const userHex = await client.getStorageAt({address: esRNTAddress, slot: `0x${userSlot.toString(16)}`}) || '0x0';
  const startTimeHex = await client.getStorageAt({address: esRNTAddress, slot: `0x${startTimeSlot.toString(16)}`}) || '0x0';
  const amountHex = await client.getStorageAt({address: esRNTAddress, slot: `0x${amountSlot.toString(16)}`}) || '0x0';

  const user = `0x${userHex.slice(26)}`; // get the last 40 bit as the address
  const startTime = BigInt(startTimeHex); // change time into BigInt 
  const amount = BigInt(amountHex); // change amount into BigInt 

  return {
    user: user, 
    startTime: Number(startTime), 
    amount: amount.toString(), 
  };
}

// search LockInfo by specific index, for example, index = 0
(async () => {
  const lockInfo = await getLockInfo(0); 
  console.log(lockInfo);
})();
