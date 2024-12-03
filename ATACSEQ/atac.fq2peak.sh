#!/bin/bash

# Hua Sun
# 2023-12-13 v0.3

label='bwa'

MINLEN=50
threads=15

# getOptions
while getopts "C:S:F:L:R:t:O:" opt; do
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
    t)
      threads=$OPTARG
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


PREFIX=${OUT}/$SAMPLE.${label}

echo 'Alignment ...'
$BWA mem -t ${threads} -M -R "@RG\tID:$SAMPLE\tPL:illumina\tLB:$SAMPLE\tPU:$SAMPLE\tSM:$SAMPLE" $GENOME $FQ1 $FQ2 | $SAMTOOLS view -Shb -o ${PREFIX}.bam -

echo 'Sort ...'
$JAVA -Xmx64G -jar $PICARD SortSam \
    I=${PREFIX}.bam \
    O=${PREFIX}.sorted.bam \
    CREATE_INDEX=true \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=STRICT \
    TMP_DIR=$tmp_dir

echo 'Filtering ...'
$ALIGNMENTSIEVE -b ${PREFIX}.sorted.bam --minMappingQuality 30 --samFlagInclude 2 -o ${PREFIX}.MAPQ30.bam
$SAMTOOLS index ${PREFIX}.MAPQ30.bam

# remove sam for save space 
#rm -f ${PREFIX}.bam

echo 'RemDup ...'
$JAVA -Xmx64G -jar $PICARD MarkDuplicates \
    I=${PREFIX}.MAPQ30.bam \
    O=${PREFIX}.remDup.bam \
    REMOVE_DUPLICATES=true \
    M=${PREFIX}.remdup.metrics.txt \
    TMP_DIR=$tmp_dir

$SAMTOOLS index ${PREFIX}.remDup.bam


echo 'Filter chrM ...'
$SAMTOOLS view -h ${PREFIX}.remDup.bam | grep -v chrM | $SAMTOOLS view -b -h -f 0x2  | $SAMTOOLS sort -m 4G -@ ${threads} -n -o ${PREFIX}.remDup.f2.bam -
$SAMTOOLS index ${PREFIX}.remDup.f2.bam


echo 'Call peak ...'
BAM=${PREFIX}.remDup.f2.bam
${GENRICH}  -t ${BAM} -o ${PREFIX}.genrich.narrowPeak -f ${PREFIX}.genrich.log -j -r -y -d 150 -q 0.05 -m 30 -e chrM,chrY -E ${BLACK_LIST} -v
grep ^chr ${PREFIX}.genrich.narrowPeak > ${PREFIX}.genrich.chr.narrowPeak

echo '
1. chrom  Name of the chromosome
2. chromStart Starting position of the peak (0-based)
3. chromEnd Ending position of the peak (not inclusive)
4. name peak_N, where N is the 0-based count
5. score  Average AUC (total AUC / bp) × 1000, rounded to the nearest int (max. 1000)
6. strand . (no orientation)
7. signalValue  Total area under the curve (AUC)
8. pValue Summit -log10(p-value)
9. qValue Summit -log10(q-value), or -1 if not available (e.g. without -q)
10. peak  Summit position (0-based offset from chromStart): the midpoint of the peak interval with the highest significance (the longest interval in case of ties)
' > ${PREFIX}.genrich.header




