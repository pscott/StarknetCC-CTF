FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && starknet-compile --debug_info_with_source impl_1.cairo > /home/ctf/compiled/impl_1.json \
    && starknet-compile --debug_info_with_source impl_2.cairo > /home/ctf/compiled/impl_2.json \
    && starknet-compile --debug_info_with_source puzzle_box.cairo > /home/ctf/compiled/puzzle_box.json \
    && rm -rf /tmp/contracts \
    && true
