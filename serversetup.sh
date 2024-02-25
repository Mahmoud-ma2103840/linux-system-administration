# Update the system
# sudo dnf update

# Install OpenSSH server
sudo dnf install openssh-server

# Start and enable the SSH service
sudo systemctl start sshd
sudo systemctl enable sshd

# Install Apache HTTP server
sudo dnf install httpd

# Start and enable the Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Allow Apache through the firewall
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

# Create a group and users
sudo groupadd project
sudo useradd -m -g project client1
sudo passwd client1
sudo useradd -m -g project client2
sudo passwd client2

# Create directories for project
sudo mkdir -p /var/www/html/client1
sudo mkdir -p /var/www/html/client2

# Set permissions for the directories
sudo chmod 775 /var/www/html/client1
sudo chmod 775 /var/www/html/client2
sudo chown apache:project /var/www/html/client1
sudo chown apache:project /var/www/html/client2

# Edit SSH server configuration
sudo nano /etc/ssh/sshd_config
# Comment out line 115: Subsystem sftp /usr/lib/openssh/sftp-server
# Add the following 5 lines at the end of the file:
# Subsystem sftp internal-sftp
# Match Group project
# AllowTcpForwarding yes
# PasswordAuthentication yes
# PubkeyAuthentication yes
# Save and exit the text editor.

# Restart SSH service
sudo systemctl restart sshd

# Edit resolv.conf
sudo nano /etc/resolv.conf
# Change the nameserver (on line 21) to 8.8.8.8
# Save and exit the text editor.

# Create a directory for the default web page
sudo mkdir -p /var/www/html

# Edit the default web page (welcome.html)
sudo nano /var/www/html/welcome.html

##### INSERT HTML #####
# Save and exit the text editor.

# Set ownership of the web directory
sudo chown -R apache:apache /var/www/html