import {
  List as ListEvent,
  Sold as SoldEvent
} from "../generated/NFTMarketTim/NFTMarketTim"
import {
  List,
  Sold,
  OrderBook,
  FilledOrder
} from "../generated/schema"

export function handleList(event: ListEvent): void {
  let entity = new OrderBook(event.params.orderId);
  entity.nft = event.params.nft;
  entity.tokenId = event.params.tokenId;
  entity.seller = event.params.seller;
  entity.payToken = event.params.payToken;
  entity.price = event.params.price;
  entity.deadline = event.params.deadline;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleSold(event: SoldEvent): void {
  let entity = new FilledOrder(event.transaction.hash);
  entity.buyer = event.params.buyer;
  entity.fee = event.params.fee;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  // connect to the OrderBook entity
  let order = OrderBook.load(event.params.orderId);
  if (order) {
    entity.order = order.id;
  }

  entity.save();
}
