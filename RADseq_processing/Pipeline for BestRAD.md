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
process_radtags -P -1 19095FL-01-02_S2_L008_R1_001.fastq.gz -2 19095FL-01-02_S2_L008_R2_001.fastq.gz -i gzfastq -e sbfI -b ./BAWR40barcodes_withIDs.txt -o ./processed_radtags/ --barcode-dist-1 3 --barcode-dist-2 3 -r -q --bestrad
```

**2. Get rid of PCR artifacts - Clone Filtering**
The `clone_filter` command in Stacks uses memory to keep track of clones instead of writing anything to files. To keep it from erring out, I had to run `clone_filter` on the demultiplexed files. I used a small script to run through the files. Run as `clone_filter_ind.sh namesfile.txt` where namesfile is list of names with final return at end of list (the barcode list minus the barcodes). **Super important:** the namesfile.txt needs to have a carriage return after the last name or the last individual won't be run. 

*Note to self: figure out how to fix this problem*

```sh
#!/bin/bash

# Run as clone_filter_ind.sh namesfile.txt where namesfile is list of names with final return at end of list.

mkdir clone_filtered

while IFS= read -r line;
do 
	clone_filter -P -1 ./processed_radtags/$line.1.fq.gz -2 ./processed_radtags/$line.2.fq.gz -i gzfastq -o ./clone_filtered/ -D;
done < $1;
```

**3. Stack**
Clone filter does something weird where the filenames get an extra .1 or .2 on them. First, change filenames. The first command prints that what you expect to change will change as expected. The second command is actually changing the file names.

```sh
for filename in *; do echo mv \"$filename" "${filename//.1.1./.1.}"\"; done

for filename in *; do mv \"$filename" "${filename//.1.1./.1.}"\"; done
```

Repeat to change `.2.2. to .2.`

After, run `denovo_map.pl` for unreferenced genomes. You can run in parallel so change `-T` accordingly, based on processors you have.

```sh
denovo_map.pl --samples ./clone_filtered/ --popmap ./BAWR40_popmap.txt -o ./stacks/ -T 4 -M 3 -m 3 -r 3 --paired
```

