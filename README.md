# sars-cov-2-mutation-fingerprints

Datasets and tables for the publication "[Profiling SARS-CoV-2 mutation fingerprints that range from the viral pangenome to individual infection quasispecies](https://www.medrxiv.org/content/10.1101/2020.11.02.20224816v1)" by Billy T. Lau, Dmitri S. Pavlichin, Anna C. Hooker, Alison Almeda, Giwon Shin, Jiamin Chen, Malaya K. Sahoo, ChunHong Huang, Benjamin A. Pinsky, HoJoon Lee, and Hanlee P. Ji.

## SARS-CoV-2 genomes

A set of 3,968 ("4K") genomes was downloaded from [GISAID](https://www.gisaid.org/) on April 9th, 2020 -- the most recent available at the time we constructed candidate primer pairs. A larger set of 75,681 genomes ("75K") downloaded from GISAID on September 23rd, 2020, was later used for computational analysis of the SARS-CoV-2 mutation landscape. These datasets are available as FASTA files with one line per sequence, and where each non-ACGT character was replaced by 'N'. Some GISAID sequences included multiple white space characters within one line, which were removed to produce this file.

### "4K" dataset -- 3,968 genomes downloaded from GISAID on April 9th, 2020

File: `sars-cov-2-genomes/sars-cov-2_4K_2020-4-9.fa.gz` (15MB gzipped, 114MB uncompressed)

### "75K" dataset -- 75,681 genomes from GISAID as of September 23rd, 2020

File: [`sars-cov-2_75K_2020-9-23.fa.gz`](https://sars-cov-2-mutation-fingerprints.s3-us-east-2.amazonaws.com/sars-cov-2_75K-2020-9-23.fa.gz) -- download link (270MB gzipped, 2.2GB uncompressed)

This file is too large to host here, so we provide a download link above.
