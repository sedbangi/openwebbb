1. nftMarket address: 0x9eb054417350Df8DcA50D475Bc3B45a8391311b7
2. abi

3. nft address: 0xA5C8995D0fA65DC927362170B09A6296b40727Ef
4. myToken address: 0xFA4C14aDc711b953Db51852D7FF1fac8812C9bA6
5. nft approveAll for nftMarket
6. list your nft:
    cast send --rpc-url "https://ethereum-sepolia-rpc.publicnode.com" --account moto956 0x9eb054417350Df8DcA50D475Bc3B45a8391311b7 "list(address nft, uint256 tokenId, address payToken, uint256 price, uint256 deadline)" 3. nft address: 0xA5C8995D0fA65DC927362170B09A6296b40727Ef 0 0xFA4C14aDc711b953Db51852D7FF1fac8812C9bA6 5ether 2730286366
7. .studio.thegraph.com/query/93090/s4nftmarket-tim/v0.0.1

type OrderBook @entity(immutable: true) {
    id: Bytes!
    nft: Bytes! # address
    tokenId: BigInt! # uint256
    seller: Bytes! # address
    payToken: Bytes! # address
    price: BigInt! # uint256
    deadline: BigInt! # uint256
    blockNumber: BigInt!
    blockTimestamp: BigInt!
    transactionHash: Bytes!
    cancelTxHash: Bytes!
    filledTxHash: Bytes!
}


{
  cancels(first: 5) {
    id
    orderId
    blockNumber
    blockTimestamp
  }
  eip712DomainChangeds(first: 5) {
    id
    blockNumber
    blockTimestamp
    transactionHash
  }
}