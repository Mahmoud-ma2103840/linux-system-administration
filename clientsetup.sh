# Update the system
# sudo dnf update
echo "Enter the server's IP Address: "
read ip
export ip
echo "Enter client1 0r client2: "
read client
export client

# Install required packages
sudo dnf install openssh-server net-tools sysstat

# Configure SSH and start the service
sudo systemctl start sshd
sudo systemctl enable sshd

ssh-keygen
ssh-copy-id $client@$ip
#ssh-keygen
#ssh-copy-id -i ~/.ssh/id_rsa.pub client1@172.20.10.4

# Create the heartbeat script
cat > heartbeat.sh <<EOL
#!/bin/bash
mkdir -p /home/liveuser/heartbeat
ssh -o StrictHostKeyChecking=yes $client@$ip "mkdir -p /home/$client/heartbeat"
while true; do
  echo "\$(date '+%Y-%m-%d %H:%M:%S')" >> /home/liveuser/heartbeat/connectivity
  echo "\$(ping -c 1 $ip)" >> /home/liveuser/heartbeat/connectivity
  scp /home/liveuser/heartbeat/connectivity $client@$ip:/home/$client/heartbeat
  sleep 300
done
EOL

# Make the script executable
chmod +x heartbeat.sh

# Create the usage information script
cat > usageinformation.sh <<EOL
#!/bin/bash
mkdir -p /home/liveuser/usageinformation
ssh -o StrictHostKeyChecking=yes $client@$ip "mkdir -p /home/$client/usageinformation"
while true; do
    echo "Disk Usage:\n$(df -h)\n" >> /home/liveuser/usageinformation/timestamp
    echo "CPU Usage:\n$(mpstat -u 1 1)\n" >> /home/liveuser/usageinformation/timestamp
    echo "Memory Usage:\n$(free -m)\n" >> /home/liveuser/usageinformation/timestamp
    echo "Running Processes:\n$(ps aux)\n" >> /home/liveuser/usageinformation/timestamp
    echo "Network Utilization:\n$(ifconfig -a)\n" >> /home/liveuser/usageinformation/timestamp
    scp /home/liveuser/usageinformation/timestamp $client@$ip:/home/$client/usageinformation
    sleep 3600
done
EOL

# Make the script executable
chmod +x usageinformation.sh

# Create a text file
echo "Hi, I am client 1." > file.txt

# Edit resolv.conf to change the DNS resolver
sudo nano /etc/resolv.conf
# Change the nameserver (on line 21) to 8.8.8.8

# Test SFTP (manually as you've mentioned).

# Run the two shell scripts concurrently using nohup to keep them running in the background
#nohup ./heartbeat.sh &
#nohup ./usageinformation.sh &
nohup ./heartbeat.sh &
nohup ./usageinformation.sh &

sftp $client@$ip