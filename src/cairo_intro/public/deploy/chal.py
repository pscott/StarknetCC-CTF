import cairo_sandbox

from pathlib import Path

from starknet_py.net import AccountClient
from starknet_py.contract import Contract
from starkware.python.utils import to_bytes

async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying cairo-intro")
    storage_deploy = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/cairo-intro.cairo").read_text(),
        constructor_args=[0],
    )
    await storage_deploy.wait_for_acceptance()

    return storage_deploy.deployed_contract.address


async def checker(client: AccountClient, intro_contract: Contract, player_address: int) -> bool:
    solution = (await intro_contract.functions["is_solved"].call()).res

    return solution == 1

cairo_sandbox.run_launcher([
    cairo_sandbox.new_launch_instance_action(deploy),
    cairo_sandbox.new_kill_instance_action(),
    cairo_sandbox.new_get_flag_action(checker),
])
