#!/bin/bash

#million of kvs in this test
M=1
#original data directories
dir0="$M"M_slb0
dir1="$M"M_slb32
dir2="$M"M_slb0_bf
dir3="$M"M_slb32_bf
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
declare -a IPC
declare -a CMR

echo "process performance data ... begin!"
for bt in ${btrees[@]}
do
	for d in ${ds[@]}
	do
		i=0
		dir="$bt"_"$d"
		for lat in ${wlats[@]}
		do
			log=cache_stat_"$lat"ns.log

			#check if log file exist
			if [ ! -f "$dir/$log" ];then
				echo "$dir/$log doesn't exist!"
				exit -1
			fi

			#collect performance data
			insert_lat[$i]=$(grep INSERT $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			search_lat[$i]=$(grep SEARCH $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			delete_lat[$i]=$(grep DELETE $dir/$log |cut -d":" -f3|awk '{sum += $1} END {print sum/NR}')
			ins_clflush[$i]=$(grep INSERT $dir/$log |cut -d":" -f4|awk '{sum += $1} END {printf("%d",sum/NR)}')
			del_clflush[$i]=$(grep DELETE $dir/$log |cut -d":" -f4|awk '{sum += $1} END {printf("%d",sum/NR)}')
			IPC[$i]=$(grep instructions $dir/$log |cut -d"#" -f2|cut -d"i" -f1|awk '{sum += $1} END {printf sum/NR}')
			CMR[$i]=$(grep cache-misses $dir/$log |cut -d"#" -f2|cut -d"%" -f1|awk '{sum += $1} END {printf sum/NR}')
			let i++
		done
		echo "$bt, ${insert_lat[@]}" >>"perf_insert_$d"
		echo "$bt, ${search_lat[@]}" >>"perf_search_$d"
		echo "$bt, ${delete_lat[@]}" >>"perf_delete_$d"
		echo "$bt, ${ins_clflush[@]}">>"perf_ins_clflush_$d"
		echo "$bt, ${del_clflush[@]}">>"perf_del_clflush_$d"
		echo "$bt, ${IPC[@]}">>"perf_IPC_$d"
		echo "$bt, ${CMR[@]}">>"perf_cache_miss_ratio_$d"
	done
done
echo "process performance data ... done!"
