#!/bin/bash


#Define flag to input run number
while getopts t:s: flag; do
  case ${flag} in
    t) totaltime=${OPTARG}
      ;;
    s) stride=${OPTARG}
      ;;
    \?) echo "Usage: cmd [-h]"
      ;;
  esac
done

n_calc=$((($totaltime/$stride)+1))
echo $n_calc

mkdir CONVERGENCE
cd CONVERGENCE/
touch fes-1d-all.dat

for  ((i=$stride; i<=$totaltime; i+=$stride))
do
  mkdir $i
  cd $i/
  echo $i
  cp ../../HILLS.* .
  n_hills=$(ls HILLS.* | wc -l)
  #In HILLS files, only keep data for the first $i ps.
  for ((j=0; j<n_hills; j++))
  do
    sed -i "/ $i /q" HILLS.$j
  done
  #Concatenate all HILLS.k files into one called HILLS
  cp HILLS.0 HILLS
  for ((k=1; k<n_hills; k++))
  do
    echo $k
    cat HILLS HILLS.$k > HILLS_old
    mv HILLS_old HILLS
  done
  #Calculate FE with respect to the position along the funnel axis
  plumed sum_hills --hills HILLS --idw dist --mintozero --kt 2.578 --outfile fes-1d.dat
  cd ../
  paste fes-1d-all.dat $i/fes-1d.dat > fes-1d-all-new.dat
  mv fes-1d-all-new.dat fes-1d-all.dat
done
