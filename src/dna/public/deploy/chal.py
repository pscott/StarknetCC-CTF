import cairo_sandbox

from pathlib import Path

from starknet_py.net import AccountClient
from starknet_py.contract import Contract
from starkware.python.utils import to_bytes

async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying dna")
    riddle_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/dna.cairo").read_text(),
        constructor_args=[3329738248317886966279794942297149793815292158761370755733235303955518040301],
    )
    await riddle_deployment.wait_for_acceptance()

    return riddle_deployment.deployed_contract.address


async def checker(client: AccountClient, dna_contract: Contract, player_address: int) -> bool:
    solution = (await dna_contract.functions["is_challenge_done"].call()).res

    return solution == 1

cairo_sandbox.run_launcher([
    cairo_sandbox.new_launch_instance_action(deploy),
    cairo_sandbox.new_kill_instance_action(),
    cairo_sandbox.new_get_flag_action(checker),
])