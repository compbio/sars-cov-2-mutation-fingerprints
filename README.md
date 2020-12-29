# sars-cov-2-mutation-fingerprints

Datasets and tables for the publication "[Profiling SARS-CoV-2 mutation fingerprints that range from the viral pangenome to individual infection quasispecies](https://www.medrxiv.org/content/10.1101/2020.11.02.20224816v1)" by Billy T. Lau, Dmitri S. Pavlichin, Anna C. Hooker, Alison Almeda, Giwon Shin, Jiamin Chen, Malaya K. Sahoo, ChunHong Huang, Benjamin A. Pinsky, HoJoon Lee, and Hanlee P. Ji.

## Genomes

A set of 3,968 ("4K") genomes was downloaded from [GISAID](https://www.gisaid.org/) on April 9th, 2020 -- the most recent available at the time we constructed candidate primer pairs. A larger set of 75,681 genomes ("75K") downloaded from GISAID on September 23rd, 2020, was later used for computational analysis of the SARS-CoV-2 mutation landscape. These datasets are available as FASTA files with one line per sequence, and where each non-ACGT character was replaced by 'N'. Some GISAID sequences included multiple white space characters within one line, which were removed to produce this file.

### SARS-CoV-2

#### reference genome from GISAID

`genomes/sars-cov-2/sars-cov-2_reference_EPI_ISL_402124.fa` (30KB)

#### "4K" dataset -- 3,968 genomes downloaded from GISAID on April 9th, 2020

`genomes/sars-cov-2/sars-cov-2_4K_2020-4-9.fa.gz` (15MB gzipped, 114MB uncompressed)

#### "75K" dataset -- 75,681 genomes from GISAID as of September 23rd, 2020

[`sars-cov-2_75K_2020-9-23.fa.gz`](https://sars-cov-2-mutation-fingerprints.s3-us-east-2.amazonaws.com/sars-cov-2_75K-2020-9-23.fa.gz) -- download link (270MB gzipped, 2.2GB uncompressed)

This file is too large to host here, so we provide a download link above.

### other genomes

These genomes are used as the off-target dataset: a primer (25-mer) is "not specific" to SARS-CoV-2 if it occurs in any of the below viral or bacterial genomes with up to 4 basepair mismatches, or in the human reference genome GRCh38 with up to 2 basepair mismatches.  At most one member of a candidate primer pair may be non-specific to SARS-CoV-2.

All FASTA files have one sequence per line, with all non-ACGT characters converted to 'N'.

[to do: add provenance for each file]

#### 89 bacterial genomes

Listed by the FDA [to do: where?]

`genomes/non-sars-cov-2/fda-bacteria.fa.gz` (14MB gzipped, 49MB uncompressed)

#### 42 influenza genomes

`genomes/non-sars-cov-2/influenza.fa.gz` (22KB gzipped, 75KB uncompressed)

#### 447 other human coronavirus genomes

`genomes/non-sars-cov-2/other-human-coronavirus.fa.gz` (2.2MB gzipped, 13MB uncompressed)

#### 321 other human virus genomes

`genomes/non-sars-cov-2/other-human-virus.fa.gz` (1.1MB gzipped, 3.7MB uncompressed)

## Candidate primer pairs

`primer_pairs/candidate-primer-pairs_2020-4-9.csv.gz` (1.3MB gzipped, 9.4MB uncompressed)

A csv file of the 67,478 candidate primer pairs we generated based on the 4K GISAID SARS-CoV-2 genome dataset.

Below, all coordinates are 1-based and given with respect to the SARS-CoV-2 reference genome.

|#|field name|description
|-|:-|:-
|1|`forward (5' to 3')`|forward primer (printed from left to right)
|2|`reverse (5' to 3')`|reverse primer (printed from right to left with reverse complement)
|3|`forward strand`|always `+`
|4|`reverse strand`|always `-`
|5|`forward start`|start of forward primer
|6|`forward stop`|stop of forward primer
|7|`reverse start`|start of reverse primer
|8|`reverse stop`|stop of reverse primer
|9|`amplicon length`|number of basepairs between last position of forward primer and first position of reverse primer
|10|`forward GC content (%)`|fraction of GC base pairs in forward primer
|11|`reverse GC content (%)`|fraction of GC base pairs in reverse primer
|12|`forward specific`|Boolean (`true` or `false`) indicating whether forward primer excludes off-target datasets [todo: define specific]
|13|`reverse specific`|Boolean (`true` or `false`) indicating whether reverse primer excludes off-target datasets [todo: define specific]
|14|`amplicon entropy (bits)`|Shannon entropy of the distribution of amplicons sandwiched by this primer pair in the 4K genome dataset
|15|`amplicon entropy per bp (bits)`|Shannon entropy of the distribution of amplicons sandwiched by this primer pair in the 4K genome dataset, divided by mean amplicon length

