#!/bin/bash

ks=8
: > k${ks}-binary.log
: > k${ks}-hash.log
for vs in 40; do
#for vs in 20 60 100 140; do
    echo $vs
    (vs=${vs} ks=${ks} block_index=binary ./db_bench_test.sh)
    (vs=${vs} ks=${ks} block_index=mse ./db_bench_test.sh)
done
