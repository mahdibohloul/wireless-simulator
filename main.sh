#!/bin/bash

PATH+=:/usr/bin/python3


# Create an array with size 10 of random float numbers in the range [0.000001, 0.00001]
# and print the array.

declare -a bandwidths
bandwidths=(1.5 55 155)
error_rates=(0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01)


echo "Script for automating wireless network simulation"
echo "-----------------------------------------------"

rm -r epoch*

for ((i=0; i<10; i++))
do
    echo "Running epoch $i"
    dir_name="epoch_$i"
    # echo "Error rate: ${error_rates[$i]}"
    for ((j=0; j<3; j++))
    do
        dir_name+=_${bandwidths[$j]}
        # echo "Bandwidth: ${bandwidths[$j]}"
        # echo "******************$dir_name"
        mkdir -p $dir_name
        var=$(ns main.tcl ${bandwidths[j]} ${error_rates[$i]} $dir_name)
        dir_name="epoch_$i"
    done
done

echo "-----------------------------------------------"
echo "Simulation finished."
echo "Going to analyze results."

python3 analyzer.py

rm -r epoch*

echo "Done"