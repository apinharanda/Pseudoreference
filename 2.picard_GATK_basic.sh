#!/bin/bash

##AP 23Feb 2022 v3
#corrected out_name bug
####this is a second script that can follow the
#mapping_bwa_mem.basic.sh

#it is used to map duplites and run GATK so that then a pseudoref can be made

#sbatch headers are good for fly genomes in terremoto

#trim reads before using trim galore (or other) and map before
#run trim_galore.sh wrapper 
#trim_galore.sh:wq

#and
#mapping_bwa_mem.basic.sh


#have base_genomics active
#

########
#
##usage in head node
#have base_genomics active
#activate conda base_genomics 

#bash picard_GATK_basic.sh picard_GATK_basic.sh md221_w501_3.1_sorted.bam md221_w501_3.1 Dsim_3.1_genomic_hardmasked.fasta md221_MappedTOw501

#Advise against running it in the head node!!!!

#also if it is run in the head node we need to save the output to an out file so that there is a record of whether it completed successfully
# for example
# nohup bash mapping_bwa_mem.basic.sh L1_i7_44_read_1_val_1.fq.gz L1_i7_44_read_4_val_2.fq.gz Dtei_1.1_genomic_hardmasked.fasta L1_i7_44 > L1_i7_44.map.log &

#to run in the HPC #this is what should be done
#example
#sbatch --account=palab --time=12:00:00 --mem=96000 --cpus-per-task=8 picard_GATK_basic.sh md221_w501_3.1_sorted.bam md221_w501_3.1 Dsim_3.1_genomic_hardmasked.fasta md221_MappedTOw501

##### read in command line
sorted_bam=$1
name=$2 #bam name until _sorted
reference_genome=$3
out_name=$4



#map duplicates 
picard MarkDuplicates INPUT=$sorted_bam OUTPUT=$name"_sorted_markdup.bam" METRICS_FILE=$name"_markdup_metrics.txt" MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000

#need to add read groups 
picard AddOrReplaceReadGroups I=$name"_sorted_markdup.bam" O=$name"_sorted_markdup_reads.bam" RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20


mv $name"_sorted_markdup.bam" $name"_sorted_markdup_NO_reads.bam"
mv $name"_sorted_markdup_reads.bam" $name"_sorted_markdup.bam"
samtools index $name"_sorted_markdup.bam"


#indel realignment
gatk3 -T RealignerTargetCreator -R $reference_genome -I $name"_sorted_markdup.bam" -o $name"_sorted_markdup_realignTargets.list" 
gatk3 -T IndelRealigner -R $reference_genome -I $name"_sorted_markdup.bam" -targetIntervals $name"_sorted_markdup_realignTargets.list" -o $name"_sorted_markdup_indel.bam" 

##if the IndelRealiner fails, it is likely that needs more memory
#gatk --java-options "-Xmx4G"
#replace the command above by
#gatk3 -Xmx4G -T IndelRealigner -R $reference_genome -I $name"_sorted_markdup.bam" -targetIntervals $name"_sorted_markdup_realignTargets.list" -o $name"_sorted_markdup_indel.bam" 
#if Xmx4G also fails then give even more

mv $name"_sorted_markdup_indel.bam"  $out_name"_markdup_realigned.bam"

samtools index $out_name"_markdup_realigned.bam"



