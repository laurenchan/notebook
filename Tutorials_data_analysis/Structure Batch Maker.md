_This script is for running Structure runs on Lauren's Linux machine._

For Structure analyses, we generally want to do multiple replicate runs at each of multiple K’s. Each of these runs is independent so we can speed up analyses by sending each to its own processor. This script writes the q-files for each Structure run and makes an bash script to then submit all the q-files. You will need to edit `infile` and `outfile` prefixes and the string for `r` (reps) and `k` (range of k's, non-inclusive of the end value). Pay close attention to paths.

When you actually run Structure, Structure will look for a `mainparams` and `extraparams` file that will need to be formatted correctly.

```sh
#!/bin/bash

echo '#!/bin/bash' > execute_q.sh
echo '' >> execute_q.sh

infile='dp_140729.str'
outprefix='dp_140729_'

for r in 'a' 'b'
do
	for ((k=1; k < 4; k++))
	do
		filename='str_'$k$r;

		echo '#!/bin/bash' > $filename'.q';
		echo '#PBS -N ' $filename >> $filename'.q';
		echo '' >> $filename'.q';
		echo 'cd $PBS_O_WORKDIR' >> $filename'.q';

		echo 'structure -i '$infile' -o '$outprefix'k'$k$r'.out -K '$k' > '$outprefix'k'$k$r'.slog' >> $filename'.'q;

		echo 'qsub '$filename'.q;' >> execute_q.sh
	done;
done;

chmod +x execute_q.sh

```