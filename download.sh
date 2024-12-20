
path=/../..
pathto=$path/../out_cellranger
outdir='out_cellranger'

mkdir -p $outdir

for sample in sample1 sample2
do

echo $sample
mkdir -p $outdir/$sample
mkdir -p $outdir/$sample/outs

scp hpc:${pathto}/$sample/outs/web_summary.html $outdir/$sample/outs
#scp hpc:${pathto}/$sample/outs/filtered_feature_bc_matrix.h5 $outdir/$sample/outs

done


