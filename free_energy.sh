#!/bin/bash

#******************************
#Analyse the FunnelMetaD output
#******************************

#Define flag to input collective variable
while getopts c: flag; do
  case ${flag} in
    c) CollectiveVariable=${OPTARG}
      ;;
    \?) echo "Usage: cmd [-h]"
      ;;
  esac
done

#Concatenate all HILLS.i files into one called HILLS
n_hills=$(ls HILLS.* | wc -l)
cp HILLS.0 HILLS
for item in $(seq 1 $((n_hills-1)))
do
  cat HILLS HILLS.${item} > HILLS_old
  mv HILLS_old HILLS
done

#echo {$(wc -l HILLS)}

#Calculate FES
plumed sum_hills --hills HILLS --mintozero --kt 2.578

#Calculate projected FE profile with respect to the user-defined collective variable 
plumed sum_hills --hills HILLS --idw ${CollectiveVariable} --mintozero --kt 2.578 --outfile fes-1d.dat
