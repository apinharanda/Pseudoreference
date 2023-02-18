#!/bin/bash

##AP v2 31 Jan 2022 #typo from v1 correct, now runs without mistakes

####this is a thrid script that can follow the
#/moto/palab/users/apinharanda/DteiRec_AncestryHMM_plates/mapping_pannel_par1_par2/par1_CT03_i5-20/ANGSD/mapping_bwa_mem.basic.sh
#and the 
#/moto/palab/users/apinharanda/DsimRec_AncestryHMM_plates/pseudorefs/picard_GATK_basic.sh

#it is the final step of the pseudorefs - this is possibly the most buggy script
#it used P Reillys github scripts
# https://github.com/YourePrettyGood
#they could be copied to own directory or just run from mine (see below samtoolsVarantCall and vcfToPseudoref)

#sbatch headers are good for fly genomes in terremoto

#trim reads before using trim galore (or other), map and call dups, indel realign
#run trim_galore.sh wrapper 
#can be found (for example) /moto/palab/users/apinharanda/DteiRec_AncestryHMM_plates/mapping_pannel_par1_par2/par1_CT03_i5-20/ANGSD/trim_galore.sh

#need to have bcftools active (not base_genomics)
#activate conda bcftools 



########
#
##usage in head node

#bash picard_GATK_basic.sh picard_GATK_basic.sh md221_w501_3.1 Dsim_3.1_genomic_hardmasked.fasta

#Advise against running it in the head node
#also if it is run in the head node we need to save the output to an out file so that there is a record of whether it completed successfully
# for example
#bash pseudoref_bcftools.sh md221_w501_3.1_sorted.bam md221_MappedTOw5011 Dsim_3.1_genomic_hardmasked.fasta

#to run in the HPC
#example
#sbatch --account=palab --time=12:00:00 --mem=96000 --cpus-per-task=8  pseudoref_bcftools.sh md221_w501_3.1 Dsim_3.1_genomic_hardmasked.fasta

##### read in command line
name=$1 #bam name until _sorted
reference_genome=$2


/moto/palab/users/apinharanda/bin/PseudoreferencePipeline/samtoolsVariantCall.sh $name $reference_genome 8 MPILEUP

#again create a file where you add the sample name, the reference and your filters for the vcf
#check which paramets to use. 
#Some preliminary results indicate that the following are reasonable thresholds for within-species mapping where pi is about 1%:
#MPILEUP: DP <= about 0.5 * average post-markdup depth || MQ <= 20.0 || QUAL <= 26.0
#to calculate coverage we can use mosdepth (see Other_scripts for details)

#this command filters anything that is small than x

#the command here assumes 30X

/moto/palab/users/apinharanda/bin/PseudoreferencePipeline/vcfToPseudoref.sh $name $reference_genome MPILEUP "DP<=15 || MQ<=20.0 || QUAL<=26.0"

#the last fails so run it separately, it happened in v1 but v2 should work fine now

bcftools consensus --iupac-codes -f $reference_genome --sample 20 -m $name"_realigned_MPILEUP_sitesToMask.bed" -o $name".fasta" $name"_realigned_MPILEUP_sitesToUse.vcf.gz"

