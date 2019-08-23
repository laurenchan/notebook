## August 19,2019 on csbehemoth

```sh
lchan@behemoth:~/RADseq> aws configure
AWS Access Key ID [****************WLUJ]: AKIAXFEWT4A6VTR7N5JF
AWS Secret Access Key [****************6aV0]: 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
Default region name [us-east-1]: 
Default output format [None]: 
lchan@behemoth:~/RADseq> aws s3 ls s3://genohub9859079 --recursive
2019-06-24 07:07:14 39705211906 19099FL-01-01_S0_L005_R1_001.fastq.gz
2019-06-24 07:24:48 44165399827 19099FL-01-01_S0_L005_R2_001.fastq.gz
2019-06-24 07:42:28 40111065469 19099FL-01-02_S0_L006_R1_001.fastq.gz
2019-06-24 07:59:40 44531254527 19099FL-01-02_S0_L006_R2_001.fastq.gz

lchan@behemoth:~/RADseq/PHCO_raw> aws s3 sync s3://genohub9859079 . ##download all in folder
```

##Process radtags
*Note: Need to direct to different output folders or .log will overwrite. the process_radtags.log is important because it gives you number of retained reads per individual so that you can determine who to keep or omit from subsequent steps.

```sh
process_radtags -P -1 ./PHCO_raw/19099FL-01-01_S0_L005_R1_001.fastq.gz -2 ./PHCO_raw/19099FL-01-01_S0_L005_R2_001.fastq.gz -i gzfastq -e sbfI -b ./PHCO_names/barcodes_wnames_L005.txt -o ./L005_processed/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad &> ./L005_processed/L005_process_radtags.oe

process_radtags -P -1 ./PHCO_raw/19099FL-01-02_S0_L006_R1_001.fastq.gz -2 ./PHCO_raw/19099FL-01-02_S0_L006_R2_001.fastq.gz -i gzfastq -e sbfI -b ./PHCO_names/barcodes_wnames_L006.txt -o ./L006_processed/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad &> ./L006_processed/L006_process_radtags.oe
```

## August 20, 2019 on csbehemoth (delayed because needed to rerun `process_radtags`)
Make a `PHCO_clone_filtered folder`. Ran `clone_filter.sh` script on each of the processed folders. Did it this way instead of combining folders to cut down on time.

```sh
#!/bin/bash

filename="./PHCO_names/L005_names_Phry.txt"
all_lines=`cat $filename`

for line in $all_lines;
do 
  clone_filter -P -1 ./L005_processed/$line.1.fq.gz -2 ./L005_processed/$line.2.fq.gz -i gzfastq -o ./PHCO_clone_filtered/ -D &> ./PHCO_clone_filtered/$line.clonefil.oe
done;
```

```sh
#!/bin/bash

filename="./PHCO_names/L006_names_Phry.txt"
all_lines=`cat $filename`

for line in $all_lines;
do 
  clone_filter -P -1 ./L006_processed/$line.1.fq.gz -2 ./L006_processed/$line.2.fq.gz -i gzfastq -o ./PHCO_clone_filtered/ -D &> ./PHCO_clone_filtered/$line.clonefil.oe
done;
```

## August 22, 2019
Clean up names in among clone filtered files.
```sh
for filename in *; do mv $filename ${filename//.1.1./.1.}; done
```
and
```sh
for filename in *; do mv $filename ${filename//.2.2./.2.}; done
```

Ran test on them using following script (`test_param_stacks.sh`) and set of 12 taxa. Taxa are: 
```
PHCO_007	TOP
PHCO_120	VER
PHCO_429	SIM
PHBL_134	SGM
PHBL_407	PIR
PHCO_421	MUG
PHCO_448	LIB
PHBL_129	LAX
PHCO_471	HCC
PHCO_066	GRI
PHCO_136	FRA
```

```sh
popmap=./test_group.txt
reads_dir=../PHCO_clone_filtered

for ((M=1; M < 8; M++))
do
	mkdir stacks.M$M;
	out_dir=stacks.M$M;
	log_file=$out_dir/denovo_map.oe;
	denovo_map.pl --samples $reads_dir --popmap $popmap -o $out_dir -M $M -n $M -m 3 -T 20 &> $log_file; 
done;
```

When they were finished, I ran `r80_filter.sh`:
```sh
#! /bin/bash

dir_for_logs=test_logs
mkdir $dir_for_logs

for ((M=1; M < 8; M++))
do
        stacks_dir=stacks.M$M;
        out_dir='stacks.M'$M'/M'$M'populations.R80';
        log_file=$out_dir'/populations.oe';
	mkdir $out_dir;
	populations -P $stacks_dir -O $out_dir -R 0.80 &> $log_file

	# Copy logs to a central place for analysis
        cp $out_dir/'populations.log.distribs' $dir_for_logs'/M'$M'_populations.log.distribs';
        #cp $out_dir/'populations.log' './test_log_files/M'$M'_populations.log';
done;
```

