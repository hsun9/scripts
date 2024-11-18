# 2024-11-15 v2.5

library(Seurat)
library(dplyr)
library(GetoptLong)
library(data.table)


rds <- './scrna_celltype.rds'
assay <- 'RNA'
ctl <- ''
form <- 'sample'
outdir <- 'out_mtx'

GetoptLong(
    "rds=s",      "main rds file path",
    "assay=s",    "assay",
    "ctl=s",      "normal cell types",
    "form=s",     "sample",
    "outdir=s",   "output"
)


dir.create(outdir)


seurat_obj <- readRDS(rds)
metadata <- seurat_obj@meta.data

print(unique(metadata$cell_type2))

cell_anno <- metadata[,c('seurat_clusters', 'cell_type2', 'orig.ident')]
cell_anno$cell <- rownames(metadata)

ref_group <- strsplit(ctl, ',')[[1]]

# make cell anno data
if (form == 'cluster'){
    cell_anno$group <- cell_anno$seurat_clusters
    cell_anno$group <- paste0('C', cell_anno$group)
}

if (form == 'sample'){
    cell_anno$group <- cell_anno$orig.ident
}

if (form == 'celltype'){
    cell_anno$group <- cell_anno$cell_type2
}

cell_anno$group[cell_anno$cell_type2 %in% ref_group] <- 'Control'

# output cell anno data
cell_anno <- cell_anno[, c('cell', 'group')]
fwrite(cell_anno, file=paste0(outdir, '/cell.anno'), sep='\t', row.names=F, col.names=F)


# output exp count data (fast)
assay_count <- seurat_obj@assays[[assay]]@counts[,cell_anno$cell]
fwrite(as.matrix(assay_count), file=paste0(outdir, '/count.mtx'), sep = "\t", quote=F, row.names=F, col.names=F)
writeLines(row.names(assay_count), paste0(outdir, '/genes.txt'))
writeLines(colnames(assay_count), paste0(outdir, '/barcodes.txt'))


