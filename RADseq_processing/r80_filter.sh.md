```sh
dir_for_logs=logs_across_pops
mkdir $dir_for_logs

for ((M=1; M < 9; M++))
do
        stacks_dir=stacks.M$M;
        out_dir='stacks.M'$M'/M'$M'populations.bigR80';
        log_file=$out_dir'/populations.oe';
        mkdir $out_dir;
        populations -P $stacks_dir -O $out_dir -R 0.80 &> $log_file

        # Copy logs to a central place for analysis
        cp $out_dir/'populations.log.distribs' $dir_for_logs'/M'$M'_populations.log.distribs';
        #cp $out_dir/'populations.log' './test_log_files/M'$M'_populations.log';
done;

```