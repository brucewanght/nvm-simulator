#!/bin/bash

dir0=1M_slb0
dir1=1M_slb32
dir2=1M_slb0_bf
dir3=1M_slb32_bf

btrees=(nvm_btree fast_fair wort woart wbtree_slot_bitmap)
wlats=(300 600 900 1200)

for bt in ${btrees[@]}
do
	echo "test done, process performance data ... begin!"
	outf="$bt"_perf_stat_all.csv
	echo "$outf"
	ds0="$bt"_"$dir0"
	ds1="$bt"_"$dir1"
	ds2="$bt"_"$dir2"
	ds3="$bt"_"$dir3"
	ds=($ds0 $ds1 $ds2 $ds3)

	echo "average latency(us) of insert, read and delete operations, and clflush count" > $outf
	for dir in ${ds[@]}
	do
		echo "$dir, w_lat, insert_lat, search_lat, delete_lat, clflush_cnt" >> $outf
		for lat in ${wlats[@]}
		do
			log=btree_perf_"$lat"ns.log
			insert_lat=$(grep INSERT $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			search_lat=$(grep SEARCH $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			delete_lat=$(grep DELETE $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			clflush_cnt=$(grep clflush $dir/$log |cut -d"," -f1|cut -d"=" -f2|awk '{sum += $1} END {printf("%d",sum/NR)}')
			echo ", $lat, $insert_lat, $search_lat, $delete_lat, $clflush_cnt" >> $outf
		done
		echo "" >> $outf
	done
	echo "test done, process performance data ... done!"
done
