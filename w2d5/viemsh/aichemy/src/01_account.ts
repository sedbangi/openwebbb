import { createPublicClient } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { arbitrumSepolia } from "viem/chains";

import dotenv from "dotenv";

dotenv.config();

const PRIVATE_KEY = "0xe515509bae76f5c7e10cddf3074ae6fc374969663aa4bd47238766aaa2ea32c2";

const account = privateKeyToAccount(PRIVATE_KEY);

console.log(account);


(async() => {
    const client = createPublicClient({
        chain: arbitrumSepolia,
        transport: http(process.env.API_URL)
    });

    const balance = await client.getBalance({
        address: account.address,

    });

    console.log(balance);
})();
