#!/bin/bash

#	Name:	Permission Sentinel
#	Desc:	ABK's fixety-fix-fix script that retains proper perms, or something..


# Some variables!
logpath="/var/log/permission-sentinel/public-share"
chown_t=0
dir_t=0
file_t=0
folder=""
tmp=0
chowned="$(wc -l $logpath/chown.log | cut -d ' ' -f 1)"
chmodded_d="$(wc -l $logpath/chmod_d.log | cut -d ' ' -f 1)"
chmodded_f="$(wc -l $logpath/chmod_f.log | cut -d ' ' -f 1)"

# Interpret multi-paths
arr=$(echo $folder | tr "," "\n")

# Fix permissions and log to file

# pre-run cleanup
rm "$logpath/chown.log"
rm "$logpath/chmod_d.log"
rm "$logpath/chmod_f.log"

touch "$logpath/chown.log"
touch "$logpath/chmod_d.log"
touch "$logpath/chmod_f.log"

function Humanize () {
	num=$1
	min=0
	hour=0

	if((num>59));then
		((sec=num%60))
		((num=num/60))
		if((num>59));then
			((min=num%60))
			((num=num/60))
			((hour=num))
		else
			((min=num))
		fi
	else
		((sec=num))
	fi
	
	if((hour>0));then
		echo `printf "%2d h " $hour`
	fi
	echo `printf "%2d m %2d s" $min $sec`
}

logger "permission-sentinel: Starting run. Indexing '$folder'..."

for scallywags in $arr
do
	echo -e "Indexing $scallywags:"
	
	# Stage 1
	timer=$(date +%s)
	echo -e "\nStage 1/3 - chown items (files and directories):"
	find $arr ! -type l -print0 | xargs -0 chown -c bluabk:share | tee -a $logpath/chown.log
	timed=$(date +%s)

	chown_t=$(($chown_t + ($timed - $timer)));
#	tmp=`Humanize "$chown_t"`
	echo -e "Stage 1 complete - `Humanize "$chown_t"`"
	
	# Stage 2
	timer=$(date +%s)
	echo -e "\nStage 2/3 - chmod directories:"
	find $arr -type d -print0 | xargs -0 chmod -c 750 | tee -a $logpath/chmod_d.log
	timed=$(date +%s)
	
	dir_t=$(($dir_t + ($timed - $timer)));
	tmp=`Humanize "$dir_t_t"`	
	echo -e "Stage 2 complete - $tmp"
	
	#Stage 3
	timer=$(date +%s)
	echo -e "\nStage 3/3 - chmod files:\n"
	find $arr -type f -print0 | xargs -0 chmod -c 640 | tee -a $logpath/chmod_f.log
	timed=$(date +%s)

	file_t=$(($file_t + ($timed - $timer)));
	tmp=`Humanize "$file_t"`
	echo -e "Stage 3 complete - $tmp"
	
	# Stage summary
	tmp2=($chown_t + $dir_t + $file_t);tmp=`Humanize "$tmp2"`
	echo -e "\nFinished indexing $arr in $tmp.\n"
done

sumtime=$(($chown_t + $dir_t + $file_t))

sumtime=`Humanize "$sumtime"`
chown_t=`Humanize "$chown_t"`
dir_t=`Humanize "$dir_t"`
file_t=`Humanize "$file_t"`
#echo $file_t

# Report changes
chowned="$(wc -l $logpath/chown.log | cut -d ' ' -f 1)"
chmodded_d="$(wc -l $logpath/chmod_d.log | cut -d ' ' -f 1)"
chmodded_f="$(wc -l $logpath/chmod_f.log | cut -d ' ' -f 1)"

msg="permission-sentinel: Finished cleanup-run in $sumtime. chowned $chowned items ($chown_t), chmodded $chmodded_d directories ($dir_t) and $chmodded_f files ($file_t)."
logger $msg
echo -e "\npermission-sentinel: Finished cleanup-run in $sumtime. chowned $chowned items ($chown_t), chmodded $chmodded_d directories ($dir_t) and $chmodded_f files ($file_t)."
