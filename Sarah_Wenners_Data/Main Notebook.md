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



