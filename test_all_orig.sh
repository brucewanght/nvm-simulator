#!/bin/bash

dir0=10M_slb0
dir1=10M_slb32
dir2=10M_slb0_bf
dir3=10M_slb32_bf

btrees=(WOBTree FAST_FAIR WORT WOART wB+Tree)
num=10000000
round=5
wlats=(0 300 600 900 1200)
data=../100_million_normal.txt

for bt in ${btrees[@]}
do
	ds0="$bt"_"$dir0"
	ds1="$bt"_"$dir1"
	ds2="$bt"_"$dir2"
	ds3="$bt"_"$dir3"
	ds=($ds0 $ds1 $ds2 $ds3)
	mkdir $ds0 
	mkdir $ds1 
	mkdir $ds2 
	mkdir $ds3 

	echo "test $bt with $num kvs ..."
	echo "test $bt without SLB ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo ./$bt -n $num -w $lat -c 0 -i $data >>$ds0/btree_perf_"$lat"ns.log
			sleep 5
		done
		#echo 3 >/proc/sys/vm/drop_caches
	done

	echo "test $bt with 32MB SLB ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo ./$bt -n $num -w $lat -c 32 -i $data >>$ds1/btree_perf_"$lat"ns.log
			sleep 5
		done
		#echo 3 >/proc/sys/vm/drop_caches
	done

	echo "test $bt without SLB but with BloomFilter ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo ./$bt -n $num -w $lat -c 0 -b -i $data >>$ds2/btree_perf_"$lat"ns.log
			sleep 5
		done
		#echo 3 >/proc/sys/vm/drop_caches
	done

	echo "test $bt with 32MB SLB and BloomFilter ..."
	for lat in ${wlats[@]}
	do
		echo "test $bt with $lat ns additional write latency ..."
		for i in $(seq 1 $round)
		do
			sudo ./$bt -n $num -w $lat -c 32 -b -i $data >>$ds3/btree_perf_"$lat"ns.log
			sleep 5
		done
		#echo 3 >/proc/sys/vm/drop_caches
	done
	echo 3 >/proc/sys/vm/drop_caches
	echo 3 >/proc/sys/vm/drop_caches
	echo 3 >/proc/sys/vm/drop_caches
done
