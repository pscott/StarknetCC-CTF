FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && starknet-compile --debug_info_with_source claim_a_punk.cairo > /home/ctf/compiled/claim_a_punk.cairo \
    && starknet-compile --debug_info_with_source openzeppelin/token/erc721/enumerable/presets/ERC721EnumerableMintableBurnable.cairo > /home/ctf/compiled/erc721enumerable_mintable.cairo \
    && rm -rf /tmp/contracts \
    && true
