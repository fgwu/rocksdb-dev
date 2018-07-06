#!/bin/bash

ks=20
: > k${ks}-binary.log
: > k${ks}-hash.log
for vs in 20 60 100 140; do
    echo $vs
    (vs=${vs} ks=${ks} block_index=binary ./db_bench_test.sh)
    (vs=${vs} ks=${ks} block_index=hash ./db_bench_test.sh)
done
