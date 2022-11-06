from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net import AccountClient
from starkware.python.utils import from_bytes

import cairo_sandbox


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying frozen account")
    frozen_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/frozen.cairo").read_text(),
        constructor_args=[],
    )
    await frozen_deployment.wait_for_acceptance()

    return frozen_deployment.deployed_contract.address


async def checker(
    client: AccountClient, frozen_contract: Contract, player_address: int
) -> bool:
    balance = await frozen_contract.functions["readBalance"].call()

    return balance.balance == 0


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
