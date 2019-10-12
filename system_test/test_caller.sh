#!/bin/bash
echo "Running system test for prim-mods"
for test in ./abench_prim_mods/*.sh; do
    echo $test
    bash test
done