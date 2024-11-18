# Hua Sun
# 6/5/23 v0.24


library(GetoptLong)
library(infercnv)


func <- 'default'
dir <- ''
ref_group <- ''
sd_amp <- 1
outdir <- "out_infercnv"


GetoptLong(
    "func=s",       "function",
    "dir=s",        "input dir",
    "ref_group=s",   "ref annotation name",
    "sd_amp=f",     "sd_amplifier",
    "outdir=s",     "output path"
)


dir.create(outdir)

if ( dir == '' ){
    print('[ERROR] Please set --dir ...')
    quit()
    
} 


# set 
f_mtx <- paste0(dir, '/expCount.txt')
f_cell <- paste0(dir, '/cellAnno.txt')
f_gene <- paste0(dir, '/geneAnno.txt')

print('[INFO] Run infercnv ...')

infercnv_obj <- CreateInfercnvObject(
	raw_counts_matrix=f_mtx,
	annotations_file=f_cell,
	gene_order_file=f_gene,
	ref_group_names=ref_group,
	delim="\t",
	min_max_counts_per_cell = c(100, +Inf),
	chr_exclude = c("chrX", "chrY", "chrM")
)


infercnv_obj2 <- ''


# fast
if (func == 'default'){
    infercnv_obj2 <- infercnv::run(
        infercnv_obj,
        cutoff=0.1, 
        out_dir=outdir,
        output_format='pdf',
        write_expr_matrix=FALSE,
        cluster_by_groups=TRUE, 
        denoise=TRUE,
        sd_amplifier = sd_amp,
        noise_logistic=TRUE,
        analysis_mode="samples",
        HMM=FALSE,
        no_plot=FALSE,
        no_prelim_plot=TRUE,
        hclust_method="ward.D2",
        num_threads = 4
    )
}



# very slow 
if (func == 'hmm'){
    infercnv_obj2 <- infercnv::run(
        infercnv_obj,
        cutoff=0.1, 
        out_dir=outdir,
        output_format='pdf',
        write_expr_matrix=FALSE,
        cluster_by_groups=TRUE, 
        denoise=TRUE,
        sd_amplifier = sd_amp,
        noise_logistic=TRUE,
        analysis_mode="samples",
        HMM=TRUE,
        no_plot=FALSE,
        no_prelim_plot=TRUE,
        hclust_method="ward.D2",
        num_threads = 4
    )
}



# very slow 
if (func == 'hmm-subc'){
    infercnv_obj2 <- infercnv::run(
        infercnv_obj,
        cutoff=0.1,
        out_dir=outdir,
        output_format='pdf',
        cluster_by_groups=TRUE,
        plot_steps=FALSE,
        denoise=TRUE,
        sd_amplifier=sd_amp,
        noise_logistic=TRUE,
        HMM=TRUE,
        no_prelim_plot=TRUE,
        analysis_mode='subclusters',
        hclust_method="ward.D2",
        tumor_subcluster_pval=0.05,
        tumor_subcluster_partition_method='random_trees',
        num_threads = 4
    )
}



# to use it without 'infercnv' package
obj_final_infercnv <- readRDS(paste0(outdir, '/run.final.infercnv_obj'))
saveRDS(t(obj_final_infercnv@expr.data), file = paste0(outdir, "/final_infercnv.exp_data.rds"))



