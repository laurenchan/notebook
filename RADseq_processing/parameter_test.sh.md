```sh
popmap=./RAAU_test1names.txt
reads_dir=../RAAU_clone_filtered

for ((M=1; M < 9; M++))
do
	mkdir stacks.M$M;
	out_dir=stacks.M$M;
	log_file=$out_dir/denovo_map.oe;
	denovo_map.pl --samples $reads_dir --popmap $popmap -o $out_dir -M $M -n $M -m 3 \
		-T 10 &> $log_file; 
done;
```