#---------- Mouse
species='mouse'
prefix="GRCm38"
version="M23"
outdir="bwa_0.7.18"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa

BWA=/research/groups/mackgrp/home/common/Software/miniconda3/envs/bwa/bin/bwa

mkdir $path/$outdir
cd $path/$outdir

ln -s $GENOME genome.fa
$BWA index genome.fa



#---------- Human
species='human'
prefix="GRCh38"
version="32"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa

mkdir $path/$outdir
cd $path/$outdir

ln -s $GENOME genome.fa
$BWA index genome.fa



