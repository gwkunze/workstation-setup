#!/bin/bash

set -eEuo pipefail

################################################################################

cat > root-inst.sh <<EOF
set -eEuo pipefail

declare LOCAL_USER="\$1"

apt update
apt install git ansible curl

sed -Ei 's/^((%sudo[ \t]+ALL=)\(ALL:ALL\))/\2(ALL) NOPASSWD:/g' /etc/sudoers

if ! groups "\$LOCAL_USER" | grep -q '\bsudo\b'; then
    usermod -G sudo "\$LOCAL_USER"
    >&2 printf "User not yet part of sudo group, please log out and back in again and run again"
    exit 1
fi
EOF

chmod a+x root-inst.sh

su -c "./root-inst.sh \"$(whoami)\""

rm root-inst.sh

ansible-playbook workstation.yml
