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

PREFIX=${OUT}.${label}

GENOME=''
BLACK_LIST=''
if [[ $REF == 'mm10' ]]; then
    GENOME=$BWA_MM10_GENOME
    BLACK_LIST=$BLACKLIST_MM10
elif [[ $REF == 'hg38' ]]; then
    GENOME=$BWA_HG38_GENOME
    BLACK_LIST=$BLACKLIST_HG38
else
  echo '[ERROR] Please set -R mm10/hg38 ...'
  exit 1
fi


echo 'Merge ...'
mkdir -p $OUT/merged_fq
cat $FQ_DIR/*_R1_001.fastq.gz > $OUT/merged_fq/${SAMPLE}_R1_001.fastq.gz
cat $FQ_DIR/*_R2_001.fastq.gz > $OUT/merged_fq/${SAMPLE}_R2_001.fastq.gz

FQ1=$OUT/merged_fq/${SAMPLE}_R1_001.fastq.gz
FQ2=$OUT/merged_fq/${SAMPLE}_R2_001.fastq.gz

echo 'Trimming ...'
mkdir -p $OUT/trimmed_fq
${TRIMGALORE} --path_to_cutadapt ${CUTADAPT} --fastqc --nextera --length $MINLEN -o $OUT/trimmed_fq --paired $FQ1 $FQ2

${FASTQC} -t 4 -o $OUT/trimmed_fq $OUT/trimmed_fq/*_val_1.fq.gz
${FASTQC} -t 4 -o $OUT/trimmed_fq $OUT/trimmed_fq/*_val_2.fq.gz

FQ1=$OUT/trimmed_fq/*_val_1.fq.gz
FQ2=$OUT/trimmed_fq/*_val_2.fq.gz

echo 'Alignment ...'
$BWA mem -t 8 -M -R "@RG\tID:$SAMPLE\tPL:illumina\tLB:$SAMPLE\tPU:$SAMPLE\tSM:$SAMPLE" $GENOME $FQ1 $FQ2 | $SAMTOOLS view -Shb -o ${PREFIX}.bam -

echo 'Sort ...'
$JAVA -Xmx32G -jar $PICARD SortSam \
    I=${PREFIX}.bam \
    O=${PREFIX}.sorted.bam \
    CREATE_INDEX=true \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=STRICT \
    TMP_DIR=$tmp_dir

echo 'Filtering1 ...'
$ALIGNMENTSIEVE -b ${PREFIX}.sorted.bam --minMappingQuality 30 --samFlagInclude 2 -o ${PREFIX}.MAPQ30.bam

# remove sam for save space 
#rm -f ${PREFIX}.bam

echo 'RemDup ...'
$JAVA -Xmx32G -jar $PICARD MarkDuplicates \
    I=${PREFIX}.MAPQ30.bam \
    O=${PREFIX}.remDup.bam \
    REMOVE_DUPLICATES=true \
    M=${PREFIX}.remdup.metrics.txt \
    TMP_DIR=$tmp_dir

$SAMTOOLS index ${PREFIX}.remDup.bam

echo 'Filtering2 ...'
$SAMTOOLS view -h ${PREFIX}.remDup.bam | grep -v chrM | grep -v chrY | $SAMTOOLS view -b -h -f 0x2 - | $SAMTOOLS sort -o ${PREFIX}.noDup_noMY_PP.bam -
$SAMTOOLS index ${PREFIX}.noDup_noMY_PP.bam

echo 'Call peak ...'
BAM=${PREFIX}.noDup_noMY_PP.bam
${GENRICH}  -t ${BAM} -o ${PREFIX}.genrich.narrowPeak -f ${PREFIX}.genrich.log -j -r -y -d 150 -q 0.05 -m 30 -e chrM,chrY -E ${BLACK_LIST} -v
grep ^chr ${PREFIX}.genrich.narrowPeak > ${PREFIX}.genrich.chr.narrowPeak











