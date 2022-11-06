FROM amanusk/cairo-base:latest

COPY deploy/ /home/ctf/

COPY contracts /tmp/contracts

RUN true \
    && mkdir /home/ctf/compiled \
    && cd /tmp/contracts \
    && cat magic-encoding.json > /home/ctf/compiled/magic-encoding.json \
    && rm -rf /tmp/contracts \
    && true
