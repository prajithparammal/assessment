#/bin/bash
#Author: Prajith Parammal
# Version: 1

# Declare variables for mongo
NETWORK=myapp-network
MONGOROOT=admin
MONGOPASS=password
MONGODB=userdb
MONGOPORT=27017
MONGOVOLNAME=mongo-data
MONGOINITFILE=mongo-init.js

# Declare variable for nodjsapp
APP_IMAGE_TAG="prajith/nodjsapp"
APP_PORT=3000
APP_NAME=my-app

# Check docker binary is available 
if ! command -v docker &> /dev/null; then
    echo "docker could not be found. Exiting!!!"
    exit
fi

# Checking for duplicates
docker container  ls -a | grep $APP_NAME  &> /dev/null
if [ $? -eq 0 ]; then
   echo "ERROR: Container name already exist. Change 'APP_NAME' variable value and re-run the script................"
   exit
fi

docker container  ls | grep ":$APP_PORT"  &> /dev/null
if [ $? -eq 0 ]; then
   echo "ERROR: HOST Port $APP_PORT already mapped to other container. Change 'APP_PORT' variable value and re-run the script......"
   exit
fi

# Create network
docker network list | grep $NETWORK  &> /dev/null
if [ $? -ne 0 ]; then
echo "Creating network $NETWORK.................................................................................."
docker network create $NETWORK
fi

# Run mongo container
echo "Starting mongodb container................................................................................."
docker container  run -d -p $MONGOPORT:27017 -e MONGO_INITDB_ROOT_USERNAME=$MONGOROOT -e MONGO_INITDB_ROOT_PASSWORD=$MONGOPASS --name mongodb \
	--net $NETWORK -v $MONGOVOLNAME:/data/db -v ${PWD}/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js  mongo

# Build nodjs app image
echo "Bulding app image.........................................................................................."
docker build -t $APP_IMAGE_TAG .

# Run nodejs app
echo "Start app container........................................................................................"
docker container run -d -p $APP_PORT:3000 --name $APP_NAME --net $NETWORK $APP_IMAGE_TAG
