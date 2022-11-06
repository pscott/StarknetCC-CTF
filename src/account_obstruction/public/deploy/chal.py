import cairo_sandbox

from pathlib import Path

from starknet_py.net import AccountClient
from starknet_py.contract import Contract
from starkware.python.utils import from_bytes


async def deploy(client: AccountClient, player_address: int) -> int:
    print("[+] deploying erc20")
    erc20_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/ERC20Pausable.json").read_text(),
        constructor_args=[
            from_bytes(b"Test Token"),
            from_bytes(b"TTK"),
            5,
            {"low": 1000000, "high": 0},
            3351906084215946721898793036190880870882020375377251832461900192322724599681,
            3351906084215946721898793036190880870882020375377251832461900192322724599681,
        ],
        salt=2312,
    )

    await erc20_deployment.wait_for_acceptance()

    print(f"[+] deploying admin")
    admin_deployment = await Contract.deploy(
        client=client,
        compiled_contract=Path("compiled/Account.json").read_text(),
        constructor_args=[
            1868321919106442055173355261247575744522155493610515503615668231781156211452
        ],
        salt=2312,
    )
    await admin_deployment.wait_for_acceptance()

    return erc20_deployment.deployed_contract.address


async def checker(
    client: AccountClient, erc20_contract: Contract, player_address: int
) -> bool:
    return (await erc20_contract.functions["paused"].call()).paused == 1


cairo_sandbox.run_launcher(
    [
        cairo_sandbox.new_launch_instance_action(deploy),
        cairo_sandbox.new_kill_instance_action(),
        cairo_sandbox.new_get_flag_action(checker),
    ]
)
