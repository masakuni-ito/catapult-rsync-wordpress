#!/bin/bash

export NOW=`date +"%Y%m%d%I%M%S"`

export FIRE_DIR=$(cd $(dirname $0) && pwd)
cd $FIRE_DIR

# read config
. ${FIRE_DIR}/config.sh

mkdir -p ${FIRE_DIR}/mount/sources ${FIRE_DIR}/mount/scripts

# make tmp dir for sources
export SOURCE_DIR=$(mktemp -d ${FIRE_DIR}/mount/sources/tmp.XXXXXX | sed "s#^${FIRE_DIR}/##")

# copy script to container
export CONTAINER_SCRIPTS_DIR=$(mktemp -d ${FIRE_DIR}/mount/scripts/tmp.XXXXXX | sed "s#^${FIRE_DIR}/##")
[[ -e ${FIRE_DIR}/scripts/container ]] && cp ${FIRE_DIR}/scripts/container/* ${CONTAINER_SCRIPTS_DIR}

# execute host script
for script in `ls ${FIRE_DIR}/scripts/host/*.sh 2>/dev/null`
do
	chmod +x $script
	. $script
done

# make command to execute in container
CONTAINER_COMMAND=':'
for script in `ls ${CONTAINER_SCRIPTS_DIR}/*.sh 2>/dev/null`
do
	CONTAINER_COMMAND=${CONTAINER_COMMAND}" && /bin/bash -x /${script}"
done

# build container
docker build -t catapult_deploy .

# execute
docker run --rm \
	-v `pwd`/mount:/mount \
	--env-file ${FIRE_DIR}/config.sh \
	--env SOURCE_DIR=/${SOURCE_DIR} \
	--env CONTAINER_SCRIPTS_DIR=/${CONTAINER_SCRIPTS_DIR} \
	--env NOW=${NOW} \
	-i -t catapult_deploy \
	/bin/bash -c "$CONTAINER_COMMAND"

# clean up
rm -rf ${FIRE_DIR}/${SOURCE_DIR} ${FIRE_DIR}/${CONTAINER_SCRIPTS_DIR}

