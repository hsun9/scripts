# 2022-04-05

#---------- Mouse
species='mouse'
#prefix="GRCm39"
#version="M28"
prefix="GRCm38"
version="M23"
star_folder="star.2_7_11b"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa
GTF=${path}/gtf/gencode.v${version}.annotation.gtf

STAR=/research/groups/mackgrp/home/common/Software/miniconda3/envs/star/bin/STAR
STAR_INDEX=${path}/${star_folder}
TEMPDIR=${STAR_INDEX}/_STARtmp

mkdir ${STAR_INDEX}

${STAR} --runThreadN 8 \
        --runMode genomeGenerate --genomeDir ${STAR_INDEX} \
        --genomeFastaFiles ${GENOME} \
        --sjdbGTFfile ${GTF} \
        --sjdbOverhang 100 \
        --outTmpDir ${TEMPDIR}




#---------- Human
species='human'
prefix="GRCh38"
#version="39"
version="32"
star_folder="star.2_7_11b"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa
GTF=${path}/gtf/gencode.v${version}.annotation.gtf

STAR_INDEX=${path}/${star_folder}
TEMPDIR=${STAR_INDEX}/_STARtmp

mkdir ${STAR_INDEX}

${STAR} --runThreadN 8 \
        --runMode genomeGenerate --genomeDir ${STAR_INDEX} \
        --genomeFastaFiles ${GENOME} \
        --sjdbGTFfile ${GTF} \
        --sjdbOverhang 100 \
        --outTmpDir ${TEMPDIR}


