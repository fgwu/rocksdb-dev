#!/bin/bash

: ${ks:=16}
: ${vs:=32}
: ${block_index:=binary}

DB_BENCH=/data/users/fwu/rocksdb-dev/rocksdb/db_bench

if [ ${block_index} = "hash" ]; then
    using_hash_index=true
else
    using_hash_index=false
fi

echo ks $ks vs $vs block_index ${block_index}  using_hash_index  $using_hash_index

rm -rf  /dev/shm/*

$DB_BENCH  --block_uses_suffix_index=${using_hash_index} \
           --db=/dev/shm/${block_index} \
           --block_size=16000 --level_compaction_dynamic_level_bytes=1 \
           --num=200000000 \
           --key_size=$ks \
           --value_size=$vs \
           --benchmarks=fillseq --compression_type=snappy \
           --statistics=true --block_restart_interval=1 \
           --compression_ratio=0.4 \

time perf record -g -F 99 \
$DB_BENCH  --block_uses_suffix_index=${using_hash_index} \
           --db=/dev/shm/${block_index} \
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
           > readrand.log

#           --read_cache_size=200000000



perf script | stackcollapse-perf.pl > out.perf-folded
perf_figure=/mnt/public/fwu/k${ks}v${vs}_${block_index}_opt.svg
flamegraph.pl out.perf-folded > ${perf_figure}

micros_op=$(grep readrandom readrand.log | awk '{print $3}')
ops_sec=$(grep readrandom readrand.log | awk '{print $5}')
bw=$(grep readrandom readrand.log | awk '{print $7}')
cpu_util=$(grep -Po "<title>rocksdb::BlockIter::Seek.*samples, \K[1-9]+\.[^%]+" ${perf_figure})
space=$(du /dev/shm/${block_index} | grep -Po '^\d+')

echo $ks, ${vs}, ${micros_op}, ${ops_sec}, ${bw}, ${cpu_util}, ${space}| tee -a k${ks}-${block_index}.log
