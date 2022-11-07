from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net import AccountClient
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.contract_address.contract_address import \
    calculate_contract_address_from_hash
from starkware.starknet.public.abi import get_storage_var_address

import cairo_sandbox


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] impl_1")
    implementation_1_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/impl_1.json").read_text(),
        salt=111111,
    )
    await implementation_1_deployment.wait_for_acceptance()

    print("[+] impl_2")
    implementation_2_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/impl_2.json").read_text(),
        constructor_args=[],
        salt=111111,
    )
    await implementation_2_deployment.wait_for_acceptance()

    print("[+] deploying puzzle")
    proxy_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/puzzle_box.json").read_text(),
        constructor_args=[
            await client.get_class_hash_at(
                implementation_1_deployment.deployed_contract.address
            ),
            implementation_2_deployment.deployed_contract.address
        ],
    )
    await proxy_deployment.wait_for_acceptance()

    return proxy_deployment.deployed_contract.address


async def checker(
    client: AccountClient, puzzle_contract: Contract, player_address: int
) -> bool:

    solved = (await puzzle_contract.functions["is_solved"].call()).res

    return solved == 1


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
