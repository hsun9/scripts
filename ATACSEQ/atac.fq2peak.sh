#!/bin/bash

# Hua Sun
# 2023-12-13 v0.3

label='bwa'
MINLEN=50

# getOptions
while getopts "C:S:F:L:R:O:" opt; do
  case $opt in
    C)
      CONFIG=$OPTARG
      ;;
    S)
      SAMPLE=$OPTARG
      ;;
    F)
      FQ_DIR=$OPTARG
      ;;
    L)
      MINLEN=$OPTARG
      ;;
    R)
      REF=$OPTARG
      ;;
    O)
      OUTDIR=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


source ${CONFIG}


OUT="$OUTDIR/$SAMPLE"
mkdir -p $OUT



mkdir -p $OUT/merged_fq
cat $FQ_DIR/*_R1_001.fastq.gz > $OUT/merged_fq/${SAMPLE}_R1_001.fastq.gz
cat $FQ_DIR/*_R2_001.fastq.gz > $OUT/merged_fq/${SAMPLE}_R2_001.fastq.gz

FQ1=$OUT/merged_fq/${SAMPLE}_R1_001.fastq.gz
FQ2=$OUT/merged_fq/${SAMPLE}_R2_001.fastq.gz


mkdir -p $OUT/trimmed_fq
${TRIMGALORE} --path_to_cutadapt ${CUTADAPT} --fastqc --nextera --length $MINLEN -o $OUT/trimmed_fq --paired $FQ1 $FQ2

${FASTQC} -t 4 -o $OUT/trimmed_fq $OUT/trimmed_fq/*_val_1.fq.gz
${FASTQC} -t 4 -o $OUT/trimmed_fq $OUT/trimmed_fq/*_val_2.fq.gz

FQ1=$OUT/trimmed_fq/*_val_1.fq.gz
FQ2=$OUT/trimmed_fq/*_val_2.fq.gz


GENOME=''
if [[ $REF == 'mm10' ]]; then
    GENOME=$BWA_MM10_GENOME
elif [[ $REF == 'hg38' ]]; then
    GENOME=$BWA_HG38_GENOME
else
  echo '[ERROR] Please set -R mm10/hg38 ...'
  exit 1
fi




$BWA mem -t 8 -M -R "@RG\tID:$SAMPLE\tPL:illumina\tLB:$SAMPLE\tPU:$SAMPLE\tSM:$SAMPLE" $GENOME $FQ1 $FQ2 | $SAMTOOLS view -Shb -o $OUT/${SAMPLE}.${label}.bam -

$JAVA -Xmx32G -jar $PICARD SortSam \
    I=$OUT/${SAMPLE}.${label}.bam \
    O=$OUT/${SAMPLE}.${label}.sorted.bam \
    CREATE_INDEX=true \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=STRICT \
    TMP_DIR=$tmp_dir

$ALIGNMENTSIEVE -b $OUT/${SAMPLE}.${label}.sorted.bam --minMappingQuality 30 --samFlagInclude 2 -o $OUT/${SAMPLE}.${label}.MAPQ30.bam

# remove sam for save space 
#rm -f $OUT/$SAMPLE.bam

# 5.remove-duplication
$JAVA -Xmx32G -jar $PICARD MarkDuplicates \
    I=$OUT/${SAMPLE}.${label}.MAPQ30.bam \
    O=$OUT/${SAMPLE}.${label}.remDup.bam \
    REMOVE_DUPLICATES=true \
    M=$OUT/${SAMPLE}.${label}.remdup.metrics.txt \
    TMP_DIR=$tmp_dir

$SAMTOOLS index $OUT/${SAMPLE}.${label}.remDup.bam

$SAMTOOLS view -h $OUT/${SAMPLE}.${label}.remDup.bam | grep -v chrM | grep -v chrY | $SAMTOOLS view -b -h -f 0x2 - | $SAMTOOLS sort -o $OUT/${SAMPLE}.${label}.noDup_noMY_PP.bam -
$SAMTOOLS index $OUT/${SAMPLE}.${label}.noDup_noMY_PP.bam


BLACK_LIST=''
if [[ $REF == 'mm10' ]]; then
    BLACK_LIST=$BLACKLIST_MM10
elif [[ $REF == 'hg38' ]]; then
    BLACK_LIST=$BLACKLIST_HG38
else
  echo '-R ' $REF
  echo '[ERROR] Please set -R mm10/hg38 ...'
  exit 1
fi

${GENRICH}  -t ${BAM} -o ${OUT}/${SAMPLE}.genrich.narrowPeak -f ${OUT}/${SAMPLE}.genrich.log -j -r -y -d 150 -q 0.05 -m 30 -e chrM,chrY -E ${BLACK_LIST} -v

grep ^chr ${OUT}/${SAMPLE}.genrich.narrowPeak > ${OUT}/${SAMPLE}.genrich.chr.narrowPeak











