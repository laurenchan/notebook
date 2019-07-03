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

