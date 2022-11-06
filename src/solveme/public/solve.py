from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net import AccountClient
from starknet_py.contract import Contract
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.models import StarknetChainId

import asyncio

node_url = "http://b9ccc07e-c239-4c79-9ead-46fc847d92a5@18.157.198.111:5061"
contract_address = "0x9440e000abc26c4a523a179b9dd00d7b2f7557df8e65db37112ef4a3c95ba2"
private_key = "0x6ad468966b741a9c2ac54ab170a3ade9"

gateway_client = GatewayClient(node_url, chain=StarknetChainId.TESTNET)

abi = [{
    "inputs": [
    ],
        "name": "solve",
        "outputs": [],
        "type": "function"
}]


async def main():
    print(gateway_client.net)
    # print(gateway_client.chain)
    print(StarknetChainId.TESTNET)

    acc_client = await AccountClient.create_account(gateway_client, private_key)

    print("Account client address: ", hex(acc_client.address))

    contract = Contract(address=contract_address, abi=abi, client=acc_client)

    invocation = await contract.functions["solve"].invoke(0x1, max_fee=int(0))
    await invocation.wait_for_acceptance()

asyncio.run(main())