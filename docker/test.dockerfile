FROM ubuntu:22.04

COPY nushell_0.89.0.deb /tmp/
RUN apt update -qq && apt install -y libssl-dev pkg-config
RUN dpkg -i /tmp/nushell_0.89.0.deb
ENTRYPOINT ["/usr/local/bin/nu", "-n"]
