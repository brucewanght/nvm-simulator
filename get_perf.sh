#!/bin/bash

#original data directories
dir0=1M_slb0
dir1=1M_slb32
dir2=1M_slb0_bf
dir3=1M_slb32_bf

ds=($dir0 $dir1 $dir2 $dir3)

#test nvm storage systems
btrees=(WOBTree FAST_FAIR WORT WOART wB+Tree)
wlats=(300 600 900 1200)

#data arrays
declare -a insert_lat
declare -a search_lat
declare -a delete_lat
declare -a ins_clflush
declare -a del_clflush

echo "process performance data ... begin!"
for bt in ${btrees[@]}
do
	for d in ${ds[@]}
	do
		i=0;
		dir="$bt"_"$d"
		for lat in ${wlats[@]}
		do
			log=btree_perf_"$lat"ns.log
			insert_lat[$i]=$(grep INSERT $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			search_lat[$i]=$(grep SEARCH $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			delete_lat[$i]=$(grep DELETE $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			ins_clflush[$i]=$(grep INSERT $dir/$log |cut -d":" -f4|awk '{sum += $1} END {printf("%d",sum/NR)}')
			del_clflush[$i]=$(grep DELETE $dir/$log |cut -d":" -f4|awk '{sum += $1} END {printf("%d",sum/NR)}')
			let i++
		done
		echo "$bt, ${insert_lat[@]}" >>"perf_insert_$d"
		echo "$bt, ${search_lat[@]}" >>"perf_search_$d"
		echo "$bt, ${delete_lat[@]}" >>"perf_delete_$d"
		echo "$bt, ${ins_clflush[@]}">>"perf_ins_clflush_$d"
		echo "$bt, ${del_clflush[@]}">>"perf_del_clflush_$d"
	done
done
echo "process performance data ... done!"
