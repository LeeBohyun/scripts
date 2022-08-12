#!/bin/bash

echo "evia6587" | sudo -S nvme list

echo "evia6587" | sudo -S fdisk /dev/nvme0n1 <<EOF
n
p
1


w
EOF
