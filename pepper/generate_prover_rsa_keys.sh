#!/bin/bash

# minimum key length (openssl doesnt work with less than 31)
MIN_K=32

# set key length to minimum if not given
if [ -z "$1" ]
then
  K=$MIN_K
else
  if [[ $1 -lt $MIN_K ]]
  then
    K=$MIN_K
  else
    K=$1
  fi
fi

# generate rsa keypair
RSA=$(openssl genrsa  $K | openssl rsa -text -noout)

# function to isolate given compenent, whether its initially in decimal or hex, and write to file
function isolate {
  #echo $1
  if [[ $1 =~ .*\(.* ]]
  then
    # looks like: 65537 (0x10001)
    # so we want the decimal version
    echo $1 | cut -d\  -f1 > $2
  else
    # looks like: 06:e3:c5:69:55:c2:77:f7:9a:84:e4:9e:01
    # so we want to convert hex to decimal
    HEX=`echo $1 | tr -d ": " | tr [a-z] [A-Z] `
    echo "ibase=16; $HEX" | bc | tr -d "\\\r\n" > $2
  fi
  echo "Created $2"
}

# write each component to its own file
N=`echo $RSA | sed 's/.*modulus:\(.*\)publicExponent:.*/\1/'`
E=`echo $RSA | sed 's/.*publicExponent:\(.*\)privateExponent:.*/\1/'`
D=`echo $RSA | sed 's/.*privateExponent:\(.*\)prime1:.*/\1/'`

isolate "$N" 'rsa-n'
isolate "$E" 'rsa-e'
isolate "$D" 'rsa-d'