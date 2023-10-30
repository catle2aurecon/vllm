#!/bin/bash
while read mdl gmu qtz; do
    # run benchmark backend
    run_backend="python3 -m vllm.entrypoints.api_server --model ${mdl} --swap-space 16 --gpu-memory-utilization ${gmu} --port 18000 --disable-log-requests"
    if [ "$qtz" != "None" ]; then
        run_backend="${run_backend} --quantization ${qtz}"
    fi
    run_backend="(nohup ${run_backend} > ./run_backend.out) &"
    echo $run_backend
    eval $run_backend; backend_pid=$!

    # run benchmark client
    run_client="python3 benchmark_serving.py \
        --backend vllm\
        --tokenizer ${mdl} --dataset ./ShareGPT_V3_unfiltered_cleaned_split.json"
    echo $run_client
    eval $run_client

    # stop benchmakr backend
    kill $backend_pid
done < model_list.txt
# --request-rate <request_rate>
#
