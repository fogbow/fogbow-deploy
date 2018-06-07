MACHINE_IP=$(ifconfig | grep "eth0" -A1 | awk 'NR==2 {print $2}' | awk -F ":" '{print $2}')
echo "$MACHINE_IP"
