#!/bin/bash

# Step 1
docker run -d --name mycsv infracloudio/csvserver:latest
# Check if container is running
if [ "$(docker ps -q -f name=mycsv)" ]; then
    echo "Container is running"
else
    echo "Container failed to start"
    exit 1
fi

# Step 2
docker logs mycsv
# If the logs indicate that port 9300 is already in use, find an unused port
# and set the environment variable CSVSERVER_PORT to that port
# Example: export CSVSERVER_PORT=9301

# Step 3
# Parse the command-line arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 start_index end_index"
    exit 1
fi
start_index=$1
end_index=$2
# Generate the CSV file
./gencsv.sh $start_index $end_index
# Copy the CSV file into the container
docker cp inputFile mycsv:/csvserver/inputFile

# Step 4
# Get shell access to the container
docker exec -it mycsv sh
# Inside the container, find the port on which the application is listening
# Example: netstat -tlnp | grep csvserver
# The output should show a line like: tcp        0      0 0.0.0.0:9300          0.0.0.0:*               LISTEN      1/csvserver
# This means the application is listening on port 9300
exit

# Step 5
# Stop and delete the running container
docker stop mycsv
docker rm mycsv

# Step 6
# Run the container with the CSV file and environment variable set
docker run -d --name mycsv -p 9393:9300 -e CSVSERVER_BORDER=Orange -v "$(pwd)/inputFile:/csvserver/inputFile" infracloudio/csvserver:latest

# Step 7
# Check if the application is accessible at http://localhost:9393
# You can also verify that the border color is orange

