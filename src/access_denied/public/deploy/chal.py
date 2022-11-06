from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net import AccountClient
from starkware.python.utils import to_bytes

import cairo_sandbox


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying contract")
    signature_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/access_denied.cairo").read_text(),
        constructor_args=[],
    )
    await signature_deployment.wait_for_acceptance()

    return signature_deployment.deployed_contract.address


async def checker(
    client: AccountClient, signature_contract: Contract, player_address: int
) -> bool:
    solved = (await signature_contract.functions["solved"].call()).solved

    return solved == 1


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
