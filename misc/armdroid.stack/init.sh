#!/bin/bash

# for GPU
sudo mkdir /dev/binderfs
sudo mount -t binder binder /dev/binderfs
sudo ln -s /dev/dma_heap/system /dev/dma_heap/system-uncached

# "translation" modules for legacy iptables (used in redroid) to work
sudo modprobe ip_tables
sudo modprobe iptable_filter
sudo modprobe iptable_mangle
sudo modprobe iptable_raw
sudo modprobe nf_nat
sudo modprobe xt_state
sudo modprobe ip6_tables
sudo modprobe ip6table_filter
sudo modprobe ip6table_mangle
sudo modprobe ip6table_raw
# sudo modprobe ip6_backend_nanit  # recommended but not present
sudo modprobe iptable_nat
sudo modprobe ip6table_nat