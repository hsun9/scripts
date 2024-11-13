
library(GetoptLong)
library(this.path)
path <- dirname(this.path())
source(paste0(path, '/seuplot.r'))


rds <- 'sc_celltype_anno.rds'
fragment <- 'atac_fragments.tsv.gz'
ct <- ''
label_id <- ''
name <- ''

outdir <- 'out_res'
dir.create(outdir)


seu_obj <- readRDS(rds)


subg <- function(){
    Idents(seu_obj) <- 'cell_type2'
    DefaultAssay(seu_obj) <- 'peaks'
    sub_obj <- subset(seu_obj, subset = orig.ident == name)
    cell.barcodes <- rownames(sub_obj[[]])
    sample_names <- as.vector(sub_obj$Sample)
    cell.barcodes <- stringr::str_remove(cell.barcodes, paste0(sample_names, '_'))
    sub_obj <- RenameCells(sub_obj, new.names = cell.barcodes)
    FragmentDensityForGene(sub_obj, fragment, gene, ct, outdir)
}





