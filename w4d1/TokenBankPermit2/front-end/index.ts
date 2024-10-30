import { hashMessage } from "viem";

function main() {
    const message = "hello world";

    const messageHash = hashMessage(message);
    console.log("Message hash1 :", messageHash);
}

main();
