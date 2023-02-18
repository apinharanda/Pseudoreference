#!/bin/bash

##v1
##AP 5Nov 2021

#this script is the base script for mapping low coverage reads to a reference genome with BWA mem
#downstream applications involve ANGSD, pseudorefs, gene expression (when mapping directly to the transcriptome), etc

#sbatch headers are good for fly genomes in terremoto

#trim reads before using trim galore (or other)
#run trim_galore.sh wrapper 
#can be found (for example) /moto/palab/users/apinharanda/DteiRec_AncestryHMM_plates/mapping_pannel_par1_par2/par1_CT03_i5-20/ANGSD/trim_galore.sh

##usage in head node
#have base_genomics active
#activate conda base_genomics 

#reference genome needs to be MASKED

#bash mapping_bwa_mem.basic.sh L1_i7_44_read_1_val_1.fq.gz L1_i7_44_read_4_val_2.fq.gz Dtei_1.1_genomic_hardmasked.fasta L1_i7_44

#Advise against running it in the head node
#also if it is run in the head node we need to save the output to an out file so that there is a record of whether it completed successfully
# for example
# nohup bash mapping_bwa_mem.basic.sh L1_i7_44_read_1_val_1.fq.gz L1_i7_44_read_4_val_2.fq.gz Dtei_1.1_genomic_hardmasked.fasta L1_i7_44 > L1_i7_44.map.log &

#to run in the HPC
#example
#sbatch --account=palab --time=12:00:00 --mem=96000 --cpus-per-task=8 mapping_bwa_mem.basic.sh L1_i7_44_read_1_val_1.fq.gz L1_i7_44_read_4_val_2.fq.gz Dtei_1.1_genomic_hardmasked.fasta L1_i7_44

###Need to make index files for reference fasta genomes - otherwise fails

##### read in command line
read1=$1
read2=$2
reference_genome=$3
out_name=$4

#1) map with bwa mem

bwa mem -t 8 $reference_genome $read1 $read2 -o $out_name".sam"

#2) make bam out of sam

samtools view -@8 -S -b $out_name".sam" > $out_name".bam"

#3) sort

samtools sort -@ 8 -m 3G $out_name".bam" > $out_name"_sorted.bam"

#4) make index

samtools index $out_name"_sorted.bam"

#5) delete the ones that we dont need 

rm -rf $out_name".sam"
rm -rf $out_name".bam"
