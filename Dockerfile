FROM quay.io/hedgedoc/hedgedoc:1.9.4

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt update && apt install -y --no-install-recommends curl git wget jq python3 python3-pip nano wget && \
    pip3 install jinja2 requests && \
    git clone https://github.com/hedgedoc/cli /hedgedoc/cli && \
    ln -s /hedgedoc/cli/bin/hedgedoc /usr/local/bin/hedgedoc

