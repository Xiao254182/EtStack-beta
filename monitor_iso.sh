#!/bin/bash

# 存储/vm-iso目录下当前文件列表
old_files=$(ls /vm-iso)

while true; do
    new_files=$(ls /vm-iso)
    
    # 检查是否有文件被添加
    added_file=$(comm -13 <(echo "$old_files" | sort) <(echo "$new_files" | sort))
    if [ ! -z "$added_file" ]; then
        echo "<option value=\"${added_file}\">${added_file}</option>" > /root/iso.txt
        sed -i '11r iso.txt' /root/dashboard/src/views/Main.vue
    fi
    
    # 检查是否有文件被删除
    deleted_file=$(comm -23 <(echo "$old_files" | sort) <(echo "$new_files" | sort))
    if [ ! -z "$deleted_file" ]; then
        sed -i "/$deleted_file/d" /root/dashboard/src/views/Main.vue  # 删除Main.vue中含有被删除文件名的整行
    fi
    
    old_files=$new_files
    sleep 1  # 每秒检查一次
done

