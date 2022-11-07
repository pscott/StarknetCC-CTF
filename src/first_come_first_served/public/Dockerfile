FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && starknet-compile --debug_info_with_source fifs.cairo > /home/ctf/compiled/fifs.json \
    && rm -rf /tmp/contracts \
    && true
