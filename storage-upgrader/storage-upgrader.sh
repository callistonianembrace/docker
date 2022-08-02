#!/bin/sh

set -e
set -x

bin_dir="/usr/local/bin"

data_dir="/var/run/tezos"
node_dir="$data_dir/node"
node_data_dir="$node_dir/data"
node="$bin_dir/tezos-node"


echo "Updating node..."

exec "${node}" upgrade storage --data-dir ${node_data_dir} --network $TEZOS_NETWORK --config-file ${node_data_dir}/config.json

echo "Node updated!"
