#!/bin/bash

if [ ! -n "$1" ];then
	echo "please input a path to store result!"
	exit 1
else
	if [ -d "$1" ];then
		echo "path $1 already exists, please input a new one!"
		exit 1
	else
		mkdir "$1"
		echo "result data will be in $1"
	fi
fi

#million of kvs in this test
M=5
num=`expr 1000000 \* $M`
round=5

#directories used for storing result
dir0="$M"M_slb0
dir1="$M"M_slb32
dir2="$M"M_slb0_bf
dir3="$M"M_slb32_bf

btrees=(WOBTree FAST_FAIR WORT WOART wB+Tree)
wlats=(300 600 900 1200)
run=../scripts/runenv.sh
data=../100_million_normal.txt

#load emulator's kernel module
../scripts/setupdev.sh load
#load the msr module
modprobe msr

for bt in ${btrees[@]}
do
	echo 3 >/proc/sys/vm/drop_caches
	ds0="$bt"_"$dir0"
	ds1="$bt"_"$dir1"
	ds2="$bt"_"$dir2"
	ds3="$bt"_"$dir3"

	#create dirs if they don't exist
	if [ ! -d $ds0 ];then
		mkdir $ds0 
	fi

	if [ ! -d $ds1 ];then
		mkdir $ds1 
	fi

	if [ ! -d $ds2 ];then
		mkdir $ds2 
	fi

	if [ ! -d $ds3 ];then
		mkdir $ds3 
	fi

	echo "test $bt with $num kvs ..."
	echo "test $bt without SLB ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo $run ./$bt -n $num -w $lat -c 0 -i $data >>$ds0/btree_perf_"$lat"ns.log
			sleep 5
		done
	done

	echo "test $bt with 32MB SLB ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo $run ./$bt -n $num -w $lat -c 32 -i $data >>$ds1/btree_perf_"$lat"ns.log
			sleep 5
		done
	done

	echo "test $bt without SLB but with BloomFilter ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo $run ./$bt -n $num -w $lat -c 0 -b -i $data >>$ds2/btree_perf_"$lat"ns.log
			sleep 5
		done
	done

	echo "test $bt with 32MB SLB and BloomFilter ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo $run ./$bt -n $num -w $lat -c 32 -b -i $data >>$ds3/btree_perf_"$lat"ns.log
			sleep 5
		done
	done
	echo 3 >/proc/sys/vm/drop_caches
	mv $ds0 $1
	mv $ds1 $1
	mv $ds2 $1
	mv $ds3 $1
done
