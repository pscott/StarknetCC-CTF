FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && starknet-compile --debug_info_with_source openzeppelin/account/presets/Account.cairo --output /home/ctf/compiled/Account.json --account \
    && starknet-compile --debug_info_with_source openzeppelin/token/erc20/presets/ERC20Pausable.cairo --output /home/ctf/compiled/ERC20Pausable.json \
    && rm -rf /tmp/contracts \
    && true
