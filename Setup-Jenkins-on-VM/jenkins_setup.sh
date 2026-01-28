#!/bin/bash

set -e

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Java 21
echo "Installing Java 21..."
apt-get install -y openjdk-21-jdk

# Verify Java installation
java -version

# Install Git
echo "Installing Git..."
apt-get install -y git

# Verify Git installation
git --version

# Install Maven
echo "Installing Maven..."
apt-get install -y maven

# Verify Maven installation
mvn -version

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
sudo apt update
apt-get install -y jenkins

# Ensure Jenkins runs on port 8080
#echo "Configuring Jenkins to run on port 8080..."
#if grep -q "JENKINS_PORT=" /etc/default/jenkins; then
#    sed -i 's/JENKINS_PORT=.*/JENKINS_PORT=8080/' /etc/default/jenkins
#else
#    echo 'JENKINS_PORT=8080' >> /etc/default/jenkins
#fi

# Start Jenkins service
echo "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

echo "Setup completed successfully!"
echo "Java 21, Git, Maven, and Jenkins are now installed and configured."
echo "Jenkins is running on port 8080"
