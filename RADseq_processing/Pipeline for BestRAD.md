**June 24, 2019**

There are a couple ways to go about this. These are my notes as we tried dealing with the first two BestRAD libraries, one for BAWR and one for  RAAU. These were 2x150 libraries. BAWR was a multiplex of 40 individuals, RAAU of 86 individuals.

They were sent to me as gzfastq. The adapters were removed so seqs just had inline barcodes on the forward. In this case the barcode was 8 bp, but it was preceeded by a NG or GG and then followed by the cut site, in this case TGCA. To look at a few seqs, unzip the file (warning it will be about 5x the zipped size) then use head to read a few lines:

```sh
head -n 12 infile.fastq
```

*Output looks like:*
`@214_7_1101_2696_1098/1
TGCAGGGAATACATTTAACCCCTTGATCGCCCCTGATGTTAACCCCTTCCCTGCCAGTGTCATTAGTACAAGAACAGTGCATATTTTTAGCACTGATTATTGTAATAATGTCACTAGTTCCCAAAAAAGTGTAGAAAATTT
+
JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFJJJJJJJJJJJJJJJJFFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFJJJJJJFJJJJJJJJJJJFJJJJJJJJJJJJJJJJFJJJFJJJJJJ
@214_7_1101_7638_1116/1
TGCAGGTTTTTGTCTTCAGGTTTACCAAAACCATGTAGTGCGAGGGCCTGCCTGATTGCATACGAATTGAAACTCTTATGCCGCATACACACGACCATTTTTCATGACGAGAAAACTGCAATTTTTTTAATTGGTCATTAA
+
JJJJJJ-<<FJJFJFFJFFAFFFFFFFJFJFAJJFFJJFAF<AJ<-AFFFAAJ-FF7<<<FJAJJF7A7JJJFJFJJJFJFA<JJJJJJFFJ<FAFJJJ<-AFJJFAF-7FFJFJ-77FJ<J7<--AAJJA<7AAFFJJAF
@214_7_1101_9831_1116/1
TGCAGGCTTCTCCCAGTCGCCAGGTATCGCAACGTGGCGATGAGCCTCTGCTCAGCACTGATGGCTTCCCGCATAACGGTGTCCTGCCTGGAAATATAGGGGGACACCAAAGCCAACAGCTGCTGAAATACGGGGTCAGAC
+
JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFJJJJJJJFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFFJFJJJJJJJFJJJJJJJJ<`

Memory seems to be a big issue when processing files… both RAM and HD space. Working with gzfastq seems to help.

**1. Demultiplexing - Processing Radtags**
Given the size of files and the way clone processing works, it makes sense to do demultiplexing first. Use the `process_radtags` from Stacks. You will need a tab-delimited txt file with barcodes and sample IDs. To have it work nicely with `process_radtags`, include a GG before the 8 bp barcode. For whatever reason, also include --barcode-dist-1 so that the correct number of mismatches is used (didn't work with just the --barcode-dist-2 flag). My commandline was something like:

```sh
#process_radtags -P -1 19095FL-01-02_S2_L008_R1_001.fastq.gz -2 19095FL-01-02_S2_L008_R2_001.fastq.gz -i gzfastq -e sbfI -b ./BAWR40barcodes_withIDs.txt -o ./processed_radtags/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad

#process_radtags -P -p ./ -i gzfastq -e sbfI -b ../BAWR_RADseq_1/BAWR40barcodes_withIDs.txt -o ./processed_radtags/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad

process_radtags -P -p ./RAAU_raw/ -i gzfastq -e sbfI -b ./RAAU_names/RAAU86barcodes_withIDs.txt -o ./RAAU_processed/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad
```

**2. Get rid of PCR artifacts - Clone Filtering**
The `clone_filter` command in Stacks uses memory to keep track of clones instead of writing anything to files. To keep it from erring out, I had to run `clone_filter` on the demultiplexed files. I used a small script to run through the files. Run as `clone_filter_ind.sh namesfile.txt` where namesfile is list of names with final return at end of list (the barcode list minus the barcodes). 

*Note to self: figure out how to fix this problem*

```sh
#!/bin/bash

mkdir BAWR_clone_filtered

filename="./BAWR_names/BAWR40_names.txt"
all_lines=`cat $filename`

for line in $all_lines;
do 
  clone_filter -P -1 ./BAWR_processed/$line.1.fq.gz -2 ./BAWR_processed/$line.2.fq.gz -i gzfastq -o ./BAWR_clone_filtered/ -D;
done;

```

Clone filter does something weird where the filenames get an extra .1 or .2 on them. Change the file names.

```sh
for filename in *; do mv $filename ${filename//.1.1./.1.}; done
```

Repeat in order to change `.2.2. to .2.`

**Check out read coverage and delete any with low coverage before proceeding**
Look at log from process_radtags step and discard any with low number of reads. You can look at the different columns to figure out why number of reads is so low. To eliminate from downstream stacking, you'll delete individual from the popmap file.

**Do a test run**
... to figure out appropriate stacking parameters. Select a subset of your data and run in test folders (following Rochette and Catchen 2017).

```sh
popmap=./BAWR_test1names.txt
reads_dir=../BAWR_clone_filtered

for ((M=1; M < 9; M++))
do
        mkdir stacks.M$M;
        out_dir=stacks.M$M;
        log_file=$out_dir/denovo_map.oe;
        denovo_map.pl --samples $reads_dir --popmap $popmap -o $out_dir -M $M -n $M -m 3 \
                -T 10 &> $log_file; 
done;
```

**3. Map**
After, run `denovo_map.pl` for unreferenced genomes. You can run in parallel so change `-T` accordingly, based on processors you have.

```sh
denovo_map.pl --samples ./clone_filtered/ --popmap ./BAWR40_popmap.txt -o ./stacks/ -T 10 -M 3 -m 3 -r 3 --paired
denovo_map.pl --samples ./BAWR_clone_filtered/ --popmap ./BAWR_names/BAWR40_popmap.txt -o ./BAWR_stacks/M3 -T 10 -M 3 -m 3 -r 3 --paired --min-samples-per-pop 0.80 -d
```

