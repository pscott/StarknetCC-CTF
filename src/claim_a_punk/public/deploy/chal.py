import cairo_sandbox

from pathlib import Path

from starknet_py.net import AccountClient
from starknet_py.contract import Contract
from starkware.python.utils import from_bytes

async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] declaring erc721mintable")
    # Create declaration transaction
    declare_transaction = await client.sign_declare_transaction(
        compiled_contract=Path("compiled/erc721enumerable_mintable.cairo").read_text(), max_fee=int(1e16)
    )

    # Send it
    resp = await client.declare(transaction=declare_transaction)
    await client.wait_for_tx(resp.transaction_hash)

    # Get declared contract class hash from response
    nft_enumerable_mintable_class_hash = resp.class_hash

    print("[+] deploying claim_a_punk contract")
    contract_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/claim_a_punk.cairo").read_text(),
        constructor_args=[
            nft_enumerable_mintable_class_hash,
            client.address
        ],
    )
    await contract_deployment.wait_for_acceptance()

    claim_a_punk = contract_deployment.deployed_contract

    print("[+] creating users")
    user_1 = await AccountClient.create_account(client.client)
    user_2 = await AccountClient.create_account(client.client)

    print("[+] whitelisting those users as well as the player's address")
    response = await client.execute(
        calls=[
            contract_deployment.deployed_contract.functions["whitelist"].prepare(user_1.address),
            contract_deployment.deployed_contract.functions["whitelist"].prepare(user_2.address),
            contract_deployment.deployed_contract.functions["whitelist"].prepare(player_address),
        ],
        max_fee=int(1e16)
    )
    await client.wait_for_tx(response.transaction_hash)

    return claim_a_punk.address


async def checker(client: AccountClient, contract: Contract, player_address: int) -> bool:
    punks_nft_contract_address = (await contract.functions["getPunksNftAddress"].call()).address
    punks_nft = await Contract.from_address(punks_nft_contract_address, client)
    player_nft_balance = (await punks_nft.functions["balanceOf"].call(player_address)).balance

    return player_nft_balance > 1

cairo_sandbox.run_launcher([
    cairo_sandbox.new_launch_instance_action(deploy),
    cairo_sandbox.new_kill_instance_action(),
    cairo_sandbox.new_get_flag_action(checker),
])
