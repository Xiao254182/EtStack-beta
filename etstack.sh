#!/bin/bash

touch /usr/local/bin/etstack

cat >/usr/local/bin/etstack<<'EOF'
#!/bin/bash

if [ "$1" = "start" ]; then
    VM_NAME="$2"
    virsh start "$VM_NAME" 
    NET_NAME=$(virsh dumpxml "$VM_NAME" | grep "vnet" | awk -F\' '/dev/ {print $2}')
    brctl delif virbr0 "$NET_NAME" && brctl addif br1 "$NET_NAME"
else
    echo "Usage: etstack start $VM_NAME"
fi
EOF

chmod +x /usr/local/bin/etstack

