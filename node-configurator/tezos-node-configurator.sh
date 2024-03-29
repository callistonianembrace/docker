#!/bin/sh

set -ex

bin_dir="/usr/local/bin"

data_dir="/var/run/tezos"
node_dir="$data_dir/node"
client_dir="$data_dir/client"
node="$bin_dir/tezos-node"
node_data_dir="$node_dir/data"

# Network as a link should be converted to a json object
network=\"$TEZOS_NETWORK\"
if [[ "$TEZOS_NETWORK" =~ ^http.* ]]; then
    network=$(wget -qO- $TEZOS_NETWORK)
fi
echo $network

echo "Writing custom configuration for public node\n"
# why hard-code this file ?
# Reason 1: we could regenerate it from scratch with cli but it requires doing tezos-node config init or tezos-node config reset, depending on whether this file is already here
# Reason 2: the --connections parameter automatically puts the number of minimal connections to half that of expected connections, resulting in logs spewing "Not enough connections (2)" all the time. Hard-coding the config file solves this.

rm -rvf ${node_dir}/data/config.json
mkdir -p ${node_dir}/data
cat << EOF > ${node_dir}/data/config.json
{ "data-dir": "/var/run/tezos/node/data",
  "network": $network,
  "metrics_addr": [ "0.0.0.0:9932" ],
  "rpc":
    {
      "listen-addrs": [ "0.0.0.0:8732" ],
      "cors-origin": [
          "*"
      ],
      "cors-headers": [
          "Content-Type"
      ],
      "acl":
        [ { "address": "0.0.0.0:8732", "blacklist": [
            "POST /injection/block",
            "POST /injection/protocol",
            "GET /network/**",
            "GET /workers/**",
            "GET /worker/**",
            "GET /stats/**",
            "GET /config/**",
            "GET /chains/main/blocks/*/helpers/baking_rights",
            "GET /chains/main/blocks/*/helpers/endorsing_rights",
            "GET /helpers/baking_rights",
            "GET /helpers/endorsing_rights"
          ] }
        ]
    },
  "p2p":
    { "limits":
        { "connection-timeout": 10, "min-connections": 25,
          "max-connections": 75, "max_known_points": [ 400, 300 ],
          "max_known_peer_ids": [ 400, 300 ] } },
  "shell": { "chain_validator": { "bootstrap_threshold": 1 },
             "history_mode": "$HISTORY_MODE" } }
EOF

cat ${node_dir}/data/config.json

# Generate a new identity if not present
if [ ! -f "$node_data_dir/identity.json" ]; then
    echo "Generating a new node identity..."
    exec "${node}" identity generate "${IDENTITY_POW:-26}". \
            --data-dir "$node_data_dir"
fi
