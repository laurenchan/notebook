Following the denoising step. in denoising-p20

For some reason, rep-seqs.qza in denoising-p20 is MUCH smaller file than in denoising-2… folder. Using larger file from janice’s run. The only diff should be that the first was run on multiple processors. Maybe it overwrites?

```bash
qiime metadata tabulate --m-input-file denoising-stats.qza --o-visualization denoising-stats.qzv

qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file sample_metadata.tsv


# Importing Silva (did not modify for this test)
qiime tools import --type 'FeatureData[Sequence]' --input-path silva_132_99_16S.fna --output-path silva_132_99_16S.qza

qiime tools import --type 'FeatureData[Taxonomy]' --input-format HeaderlessTSVTaxonomyFormat --input-path taxonomy_all_levels.txt --output-path ref-taxonomy.qza
```

Forward primer (a little too short in Janice's logs)
`CCTACGGGNGGCWGCAG`
Reverse primer
`GACTACHVGGGTATCTAATCC`

```bash
qiime feature-classifier extract-reads --i-sequences silva_132_99_16S.qza --p-f-primer CCTACGGGNGGCWGCAG --p-r-primer GACTACHVGGGTATCTAATCC --p-min-length 100 --p-max-length 600 --o-reads ref-seqs.qza
```

