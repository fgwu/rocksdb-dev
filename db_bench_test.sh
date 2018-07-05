#!/bin/bash

echo $#
DB_BENCH=/data/users/fwu/rocksdb-dev/rocksdb/db_bench

ks=40
vs=40

$DB_BENCH --block_uses_suffix_index=$1 --db=/dev/shm/$1 \
           --block_size=16000 --level_compaction_dynamic_level_bytes=1 \
           --num=200000000 \
           --key_size=$ks \
           --value_size=$vs \
           --benchmarks=fillseq --compression_type=snappy \
           --statistics=true --block_restart_interval=1 \
           --compression_ratio=0.4 \

time perf record -g -F 99 \
$DB_BENCH --block_uses_suffix_index=$1 --db=/dev/shm/$1 \
           --block_size=16000 --level_compaction_dynamic_level_bytes=1 \
           --use_existing_db=true \
           --num=10000000 \
           --key_size=$ks \
           --value_size=$vs \
           --benchmarks=readrandom --compression_type=snappy \
           --statistics=true --block_restart_interval=1 \
           --compression_ratio=0.4 \
           --cache_size=10000000000 \
           --compressed_cache_size=10000000000 \
#           --read_cache_size=200000000

perf script | stackcollapse-perf.pl > out.perf-folded
flamegraph.pl out.perf-folded > perf.svg
