#!/bin/bash

OTHERS=$(../get_others.sh $1)

bash ./init_gateway.sh $1 $OTHERS