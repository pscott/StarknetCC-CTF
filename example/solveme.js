import { Provider, constants, Signer } from "starknet";
import fs from "fs";
import {
    Account,
    ec,
    json,
} from "starknet";

let uuid = "514490d7-2184-4cd4-b260-e5cc0bd82dbd";
let baseUrl = "http://18.157.198.111:5051";
const privateKey = "0xc7734ffe0fe0eca422c612977314c9df";
const playerAddress = "0x6ccef733f7e637732573944fdb4f7c76052780c014a064d9f2fc5ad62502c17";
const contractAddress = "0x673961dfca6eeb8c07579974f970cf0d61c6e1a8389b23ee7dbcb463216440a";

const provider = new Provider({
    sequencer: {
        baseUrl: `${baseUrl}`,
        chainId: constants.StarknetChainId.TESTNET,
        feederGatewayUrl: `${baseUrl}/feeder_gateway`,
        gatewayUrl: `${baseUrl}/gateway`,
        headers: {
            Authorization: `Basic ${Buffer.from(uuid + ":").toString("base64")}`,
        },
    },
});

async function main() {
    // Check if the provider is working correctly.
    let block = await provider.getBlock(0);

    const starkKeyPair = ec.getKeyPair(privateKey);
    let signer = new Signer(starkKeyPair);
    let acc = new Account(provider, playerAddress, signer);

    let txRes = await acc.execute({
        contractAddress,
        entrypoint: "solve",
        calldata: [],
    })
    console.log("Tx result: ", txRes);
}

main();