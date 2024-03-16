#!/bin/bash

while true
do
    # 计算文件的哈希值
    current_hash=$(md5sum /root/back/num.txt)

    # 检查上一次保存的哈希值文件是否存在
    if [ -f "hash_value.txt" ]; then
        # 读取之前保存的哈希值
        previous_hash=$(cat hash_value.txt)
        
        # 比较当前哈希值和之前保存的哈希值
        if [ "$current_hash" != "$previous_hash" ]; then
            # 执行kvm.sh
            ./kvm.sh
            
            # 保存新的哈希值
            echo "$current_hash" > hash_value.txt
        fi
    else
        # 如果之前没有保存的哈希值文件，则创建一个并保存当前哈希值
        echo "$current_hash" > hash_value.txt
    fi
    
    sleep 1  # 暂停1秒钟
done
