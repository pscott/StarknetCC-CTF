from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net import AccountClient
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.contract_address.contract_address import \
    calculate_contract_address_from_hash
from starkware.starknet.public.abi import get_storage_var_address

import cairo_sandbox


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] implementation_v1")
    implementation_v1_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/implementation_v1.json").read_text(),
        constructor_args=[],
        salt=111111,
    )
    await implementation_v1_deployment.wait_for_acceptance()

    print("[+] deploying proxy")
    proxy_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/proxy.json").read_text(),
        constructor_args=[
            await client.get_class_hash_at(
                implementation_v1_deployment.deployed_contract.address
            ),
            client.address,
        ],
    )
    await proxy_deployment.wait_for_acceptance()

    return proxy_deployment.deployed_contract.address


async def checker(
    client: AccountClient, proxy_contract: Contract, player_address: int
) -> bool:

    implementation_class_hash = await client.get_storage_at(
        proxy_contract.address, get_storage_var_address("implementation"), "latest"
    )
    implementation_address = calculate_contract_address_from_hash(
        salt=111111,
        class_hash=implementation_class_hash,
        constructor_calldata=[],
        deployer_address=0,
    )

    implemenatation_contract = await Contract.from_address(
        implementation_address, client
    )

    wrapper_contract = Contract(
        proxy_contract.address,
        implemenatation_contract.data.abi,
        client,
    )
    player_id = (
        await wrapper_contract.functions["getIdNumber"].call(player_address)
    ).id_number

    return player_id == 313337


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
