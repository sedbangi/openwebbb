// https://decert.me/challenge/1267b0cc-ac39-47a7-9a4b-2ef482ff2c5c - （2）
// chenyuqing

import { createPublicClient, decodeEventLog, formatUnits, webSocket } from 'viem';
import { mainnet } from 'viem/chains';

// USDT 地址和 Transfer 事件的签名
const USDT_ADDRESS = '0xdac17f958d2ee523a2206206994597c13d831ec7';
// const TRANSFER_EVENT_SIGNATURE = 'Transfer(address,address,uint256)';

// 使用 viem 创建 WebSocket 客户端连接到以太坊主网
const client = createPublicClient({
    chain: mainnet,
    transport: webSocket('wss://mainnet.infura.io/ws/v3/59d76783bf2a4c9e9e202e59876c075f'), // 替换为你的 Infura WebSocket URL
});

// 定义监控函数
async function printLiveUSDTTransfers(): Promise<void> {
  console.log('开始监控 USDT 转账事件...\n');

  // 订阅 Transfer 事件
  client.watchEvent({
      address: USDT_ADDRESS,
      event: {
          type: 'event',
          name: 'Transfer',
          inputs: [
              { type: 'address', name: 'from', indexed: true },
              { type: 'address', name: 'to', indexed: true },
              { type: 'uint256', name: 'value' },
          ],
      },
      onLogs: (logs) => {
          logs.forEach((log) => {
              // 解码日志数据
              const { args } = decodeEventLog({
                  abi: [
                      {
                          type: 'event',
                          name: 'Transfer',
                          inputs: [
                              { type: 'address', name: 'from', indexed: true },
                              { type: 'address', name: 'to', indexed: true },
                              { type: 'uint256', name: 'value' },
                          ],
                      },
                  ],
                  data: log.data,
                  topics: log.topics,
              });

              if (args) {
                const from = args.from as string;
                const to = args.to as string;
                const amount = formatUnits(args.value as bigint, 6); // USDT 使用 6 位小数

                  console.log(`From: ${from} -> To: ${to} | Amount: ${amount} USDT | Block: ${log.blockNumber} | Tx: ${log.transactionHash}`);
              }
          });
      },
  });
}

// 启动监控
printLiveUSDTTransfers().catch((error) => {
    console.error('监控过程中出错:', error);
});
