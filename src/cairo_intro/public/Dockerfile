FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && starknet-compile --debug_info_with_source cairo-intro.cairo > /home/ctf/compiled/cairo-intro.cairo \
    && rm -rf /tmp/contracts \
    && true
