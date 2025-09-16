#!/bin/bash

# Deploy a Django app and handle errors

# Function to clone the Django app code
code_clone() {
    echo "Cloning the Django app..."
    if [ -d "django-notes-app" ]; then
        echo "The code directory already exists. Skipping clone."
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git || {
            echo "Failed to clone the code."
            return 1
        }
    fi
}

# Function to install required dependencies
install_requirements() {
    echo "Installing dependencies..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io nginx || {
        echo "Failed to install dependencies."
        return 1
    }

    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

# Function to perform required restarts
required_restarts() {
    echo "Performing required restarts..."
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo systemctl enable nginx
    sudo systemctl start nginx
}

# Function to deploy the Django app
deploy() {
    echo "Building and deploying the Django app..."
    cd django-notes-app || { echo "App directory missing"; return 1; }
    docker build -t notes-app . || { echo "Build failed"; return 1; }
    docker-compose up -d || { echo "Compose failed"; return 1; }
}

# Main deployment script
echo "********** DEPLOYMENT STARTED *********"

# Clone the code
code_clone || exit 1
cd django-notes-app || exit 1

# Go back one level after clone (so script paths remain valid)
cd ..

# Install dependencies
install_requirements || exit 1

# Perform required restarts
required_restarts || exit 1

# Deploy the app
deploy || { echo "Deployment failed. Mailing the admin..."; exit 1; }

echo "********** DEPLOYMENT DONE *********"

