#!/bin/bash

touch /usr/local/bin/etstack

cat >/usr/local/bin/etstack<<'EOF'
#!/bin/bash

if [ "$1" = "start" ]; then
    VM_NAME="$2"
    virsh start "$VM_NAME" && brctl delif virbr0 vnet0 && brctl addif br1 vnet0
else
    echo "Usage: etstack start $VM_NAME"
fi
EOF

chmod +x /usr/local/bin/etstack

