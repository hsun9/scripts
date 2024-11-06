
library(ggplot2)
library(patchwork)
library(Signac)




FragmentDensityForGene <- function(obj, fpath, gene, celltypes='all', outdir='.')
{   
    cluster_colors <- c("RGC"="#E31A1C", "Neuron"="#a65cc4", "OPC"="#F781BF")

    cell_type <- as.character(unique(obj@meta.data$cell_type2))

    # set new path for fragment
    if (fpath != ''){
        print(fpath)
        fg <- CreateFragmentObject(path = fpath, cells = colnames(obj), validate.fragments = TRUE)
        Fragments(obj@assays$peaks) <- NULL
        Fragments(obj@assays$peaks) <- fg
    }

    Idents(obj) <- 'cell_type2'
    DefaultAssay(obj) <- "peaks"

    idents.plot <- levels(obj)
    if (celltypes != 'all'){ idents.plot <- strsplit(celltypes, ',')[[1]] }

    p <- CoveragePlot(
            object = obj,
            region = gene,
            expression.assay = "SCT",
            idents = idents.plot,
            annotation = 'gene',
            peaks = TRUE,
            links = FALSE,
            extend.upstream = 1000,
            extend.downstream = 1000
        ) &
        theme(text = element_text(size = 7, face="bold"),
            axis.title.y = element_text(size = 6, face="bold")) &
        scale_fill_manual(values=cluster_colors)

    p <- p + plot_layout(ncol=1) + NoLegend() + 
            theme(plot.title = element_text(hjust = 0.5, face="bold")) 


    celltypes <- gsub("\\,",  "_",  celltypes)
    out <- paste0(outdir, "/fragments.", gene, ".", celltypes, ".pdf")
    pdf(out, width = 3, height = 2, useDingbats=FALSE)
    print(p)
    dev.off()
}






