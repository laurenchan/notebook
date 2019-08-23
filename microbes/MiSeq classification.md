Following the denoising step. in denoising-p20

For some reason, rep-seqs.qza in denoising-p20 is MUCH smaller file than in denoising-2… folder. Using larger file from janice’s run. The only diff should be that the first was run on multiple processors. Maybe it overwrites?

##Summarize data and import reference sequences

```sh
qiime metadata tabulate --m-input-file denoising-stats.qza --o-visualization denoising-stats.qzv

qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file sample_metadata.tsv


# Importing Silva (did not modify for this test)
qiime tools import --type 'FeatureData[Sequence]' --input-path silva_132_99_16S.fna --output-path silva_132_99_16S.qza

qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path taxonomy_all_levels.txt --output-path ref-taxonomy.qza
```

## Trim the reads
Forward primer (a little too short in Janice's logs)
`CCTACGGGNGGCWGCAG`
Reverse primer
`GACTACHVGGGTATCTAATCC`

```sh
qiime feature-classifier extract-reads --i-sequences silva_132_99_16S.qza --p-f-primer CCTACGGGNGGCWGCAG --p-r-primer GACTACHVGGGTATCTAATCC --p-min-length 100 --p-max-length 600 --o-reads ref-seqs.qza
```

##Train the classifier

```sh
qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads ref-seqs.qza --i-reference-taxonomy ref-taxonomy.qza --o-classifier classifier.qza
```

##Test the classifier

```sh
# Test of the smaller dataset from the parallel run (not sure why smaller)
qiime feature-classifier classify-sklearn --i-classifier classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy_p20.qza

#qiime feature-classifier classify-sklearn --i-classifier classifier.qza --i-reads rep-seqs_janice.qza --o-classification taxonomy_janice.qza
```

###Troubleshooting
Ran: `qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv`
Got Error: 
`CategoricalMetadataColumn does not support strings with leading or trailing whitespace characters: 'D_0__Bacteria;D_1__Chloroflexi;D_2__Gitt-GS-136;D_3__uncultured bacterium ’`

See [here](https://forum.qiime2.org/t/qiime-taxa-filter-table-error/3947) for solution (needs some edits for syntax).

***Steps to solve problem***

```sh
qiime tools export --input-path taxonomy_p20.qza --output-path tax_p20-with-spaces

qiime metadata tabulate --m-input-file tax_p20-with-spaces/taxonomy.tsv --o-visualization tax_p20_metadata.qzv

qiime tools export --input-path tax_p20_metadata.qzv --output-path tax_p20-as-metadata

qiime tools import --type 'FeatureData[Taxonomy]' --input-path tax_p20-as-metadata/metadata.tsv --output-path tax_p20-without-spaces.qza
```

***Then proceed***

```sh
qiime metadata tabulate --m-input-file tax_p20-without-spaces.qza --o-visualization tax_p20_final.qzv

qiime taxa barplot --i-table ../table.qza --i-taxonomy tax_p20-without-spaces.qza --m-metadata-file ../sample_metadata.tsv --o-visualization taxa_p20-barplots.qzv
```

