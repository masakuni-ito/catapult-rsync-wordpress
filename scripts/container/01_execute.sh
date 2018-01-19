#!/bin/bash

echo ${0}

rsync -e "ssh -p ${REMOTE_PORT}" \
	-avhz --checksum --delete \
	--exclude ${EXCLUDE_DIR} \
	${SOURCE_DIR}/${SRC_RELATIVE_DIR}/ \
	${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_RELEASES_DIR}

