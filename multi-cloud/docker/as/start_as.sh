#!/bin/bash

# Add build value into as.conf
BUILD_FILE_NAME="build"
AS_CONF_FILE_PATH="src/main/resources/private/as.conf"

cat $BUILD_FILE_NAME >> $AS_CONF_FILE_PATH"

# Run AS
./mvnw spring-boot:run -X > log.out 2> log.err