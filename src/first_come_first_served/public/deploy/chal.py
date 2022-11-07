from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net import AccountClient
from starkware.python.utils import from_bytes

import cairo_sandbox


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying fifs contract")
    fifs_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/fifs.json").read_text(),
        constructor_args=[],
    )
    await fifs_deployment.wait_for_acceptance()

    print("[+] creating bidders")
    player_1 = await AccountClient.create_account(client.client)

    response = await client.execute(
        calls=[
            fifs_deployment.deployed_contract.functions["claim"].prepare(),
        ],
        max_fee=int(1e16),
    )
    await player_1.wait_for_tx(response.transaction_hash)

    return fifs_deployment.deployed_contract.address


async def checker(
    client: AccountClient, fifs_contract: Contract, player_address: int
) -> bool:
    max_supply = (await fifs_contract.functions["get_max_supply"].call()).supply
    user_balance = (
        await fifs_contract.functions["get_balance"].call(player_address)
    ).balance

    return int(user_balance) > int(max_supply)


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
