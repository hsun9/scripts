#---------- Mouse
species='mouse'
prefix="GRCm38"
version="M23"
outdir="bw2_2.5.4"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa

BW2=/research/groups/mackgrp/home/common/Software/miniconda3/envs/bw2/bin/bowtie2-build

mkdir $path/$outdir
cd $path/$outdir

ln -s $GENOME genome.fa
$BW2 genome.fa genome



#---------- Human
species='human'
prefix="GRCh38"
version="32"

path=/research/groups/mackgrp/home/common/Databases/${species}_genome/${prefix}_gencode_v${version}
GENOME=${path}/genome/${prefix}.primary_assembly.genome.fa

mkdir $path/$outdir
cd $path/$outdir

ln -s $GENOME genome.fa
$BW2 genome.fa genome



