#!/bin/bash

OTHERS=$(../get_others.sh $1)

bash ./init_atomix_node.sh $1 $OTHERS