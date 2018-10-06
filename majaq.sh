#!/bin/bash
version="1.0"

cd src
install () {
    echo "installing...."
}

start () {
    echo "Majaq version $version"
    echo "Starting...."
    docker-compose up -d
    # sudo chown -R $USER src/backend
    if [ -f "src/files/wp-config.php" ]
    then
        rsync -s files/wp-config.php backend/wp-config.php
    fi

    if [ -d "src/files/wp-content" ]
    then
        docker-compose run wordpress rm -rf /var/www/html/wp-content
        rsync -a files/wp-content/ backend/wp-content/
    # else
        # cp -r src/backend/wp-content/ src/files
    fi
    isRunning
}

stop () {
    echo "Stopping...."
    # cd src
    docker-compose down
    rsync -a backend/wp-content/ files/wp-content/
    rsync -a backend/wp-config.php files/wp-config.php
    isRunning
}

isRunning () {
    RUNNING=0
    IS_RUNNING=`docker-compose ps -q wordpress`
    if [ "$IS_RUNNING" != "" ]
    then
        RUNNING=1
        ID=$IS_RUNNING
        echo "Majaq now Running!"
    else
        RUNNING=0
    fi
}

seed () {
    echo "seeding: $SEED"
}

usage () {
cat << EOF
usage: 
    majaq install [-f | --fresh]
    majaq start [-s | --seed file_in_src_database_seed.sql]
    majaq stop [-e | --export file_to_src_database_export.sql]
    majaq restart
    majaq -v | --version
    majaq update
    majaq -h | --help | usage

Report bugs to: dev-team@majaq.io
EOF
}

if [ $1 = "install" ]
then
    install
fi

if [ $1 = "start" ]
then
    if [ $2 = "-s" ] && [ -z "$3" ]
    then
        SEED="default"
        seed
    elif [ $2 = "-s" ] && [ $3 != "" ]
    then
        SEED=$3
        seed
    fi
    # echo "$1 $2 $SEED"
    start
fi

if [ $1 = "stop" ]
then
    stop
fi

if [ $1 = "-v" ]
then
    echo $version
fi

if [ $1 = "-h" ]
then
    usage
fi






# docker stop $(docker ps -a -q)
# docker rm $(docker ps -a -q)
# docker rmi $(docker images -q)
# sudo chown -R $USER backend
# docker-compose rm -f
# docker-compose pull
# docker-compose up --build -d
# # Run some tests
# ./tests
# docker-compose stop -t 1
