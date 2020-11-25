############## ceph pg autorepair script ##################
# create time: 2020.11.19
###########################################################

#!/bin/bash
#log script execution time
time=`date +"%Y/%m/%d %H:%M"`
echo $time  >> /var/log/pgautorepair_log

#check whether cluster has inconsistent pgs or not
pginconsistent=`ceph pg ls inconsistent`
if [ -z "$pginconsistent" ]
then
   echo "no pg inconsistent" >> /var/log/pgautorepair_log
else
   for i in $(ceph pg ls inconsistent -f json | jq -r .pg_stats[].pgid)
   do
      if ceph pg ls repair | grep -wq $i
      then
         echo  "PG $i is already repairing, skipping" >> /var/log/pgautorepair_log
         continue
      fi

      # repair pg
      ceph pg repair $i &>> /var/log/pgautorepair_log

      sleep 10

   done
fi
