```sh
#!/bin/bash

clean_dir="../RAAU_clone_filtered/"
filename="../RAAU_names/RAAU86_names.txt"
all_lines=`cat $filename`
counter=1

for line in $all_lines;
do 
        sample=$line
        sample_index=$counter
        fq1_file=$clean_dir$sample'.1.fq.gz'
        # fq2_file=$clean_dir$sample'.2.fq.gz' not necessary
        log_file=$sample'.ustacks.oe'
        echo $fq1_file
        
        ustacks -t gzfastq -f $fq1_file -o . -i $sample_index -m 3 --name $sample -M 4 -m 3 -p 12 &> $log_file

        ((counter++))
done;

```