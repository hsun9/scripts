# Hua Sun
# cell type - streamline version
# v1.0


library(Seurat)
library(dplyr)
library(this.path)
library(GetoptLong)


path <- dirname(this.path())
fpath <- paste0(path, '/src/')
r_source <- list.files(fpath, recursive = T, full.names = T, pattern = ".R")
invisible(lapply(r_source, source))

db_path <- paste0(path, '/db')

ver <- 'v3'
db <- 'hsFB'
tissue <- 'Brain'

cluster <- 'seurat_clusters'
assay <- 'SCT'
outdir <- 'out_celltype'

GetoptLong(
    "rds=s",         "rds file path",
    "cluster=s",     "cluster",
    "assay=s",       "obj type",
    "ver=s",         "marker version",
    "db=s",          "marker db",
    "tissue=s",      "tissue name",
    "save",          "save to rds",
    "outdir=s",      "output path"
)





dir.create(outdir)


# set db
f_db <- paste0(db_path, '/', ver, '/', db, '.xlsx')
print(paste0('[INFO] Read DB version: ', ver))
if (!file.exists(f_db)){
    print('[ERROR] The db file does not exists!')
    print(f_db)
    quit()
}

print('[INFO] Reading .rds data ...')
seurat_obj <- readRDS(rds)


print('[INFO] Calculate scale data ...')
DefaultAssay(seurat_obj) <- assay

print('[INFO] Annotating cell type ...')
seurat_obj <- ScTypeAnnotation(seurat_obj, assay, cluster, f_db, tissue, outdir)

# write metadata
metadata <- as.data.frame(seurat_obj@meta.data)
write.table(metadata, file = paste0(outdir, "/metaData.cellType.xls"), sep="\t", quote=F, col.names = NA)


# create cluster_cellType file
record_anno <- unique(metadata[,c('seurat_clusters', 'cell_type', 'cell_type2', 'sctype.score')])
if ('cluster_plus' %in% colnames(metadata)){
    record_anno <- unique(metadata[,c('seurat_clusters', 'cell_type', 'cell_type2', 'cluster_plus', 'sctype.score')])
}
record_anno <- record_anno[order(record_anno$sctype.score, decreasing=TRUE),]
write.table(record_anno, file = paste0(outdir, "/cluster_cellType.xls"), sep="\t", quote=F, row.names = F)


# save rds
if (save){
    print('[INFO] Saving data ...')
    saveRDS(seurat_obj, file = paste0(outdir, '/sc_celltype_anno.rds'))
}




