#!/bin/bash

create_directory(){
 mkdir demo
}
if ! create_directory; then
	echo "The code is being exited as directory already present"
	exit 1
fi
echo "Code is interupted"
