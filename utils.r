

library(patchwork)
library(Signac)
library(Seurat)
library(ggplot2)
library(ggrepel)


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



AllMotifs_2D <- function(rds=NULL, comp_ct=NULL, label_id=NULL, outfile=NULL)
{   
    seurat_obj <- readRDS(rds)
    metadata <- seurat_obj@meta.data[c('cell_type', 'cell_type2')]

    # 1
    motif_sig <- t(seurat_obj@assays$chromvar@data)
    motif_sig_plus <- merge(metadata, motif_sig, by = 'row.names', all.x=TRUE)
    row.names(motif_sig_plus) <- motif_sig_plus[,1]
    motif_sig_plus[,1] <- NULL

    # 2
    df_motif <- c()
    for (ct in unique(metadata$cell_type2)){
        df <- motif_sig_plus[motif_sig_plus$cell_type2==ct,]
        df <- df[,!(names(df) %in% c('cell_type', 'cell_type2'))]
        df <- t(df)
        # motif cell1 cell2 ...
        df[df < 0] <- 0   # <0 to 0
        motif_score <- as.matrix(rowMeans(df))
        colnames(motif_score) <- ct
        
        df_motif <- cbind(df_motif, motif_score)
    }
    
    df <- df_motif

    # 
    celltypes <- str_split(comp_ct, ',')[[1]]
    print(celltypes)
    cx <- celltypes[1]
    cy <- celltypes[2]

    print(colnames(df))
    cx2 <- str_replace(cx, '-', '.')
    cy2 <- str_replace(cy, '-', '.')

    df <- data.frame(df[, c(cx2, cy2)])
    max_val <- max(df)

    title <- paste0('The ', nrow(df), ' motifs')


    show_id <- str_split(label_id, ',')[[1]]

    df$label <- 'no'
    df$label[row.names(df) %in% show_id] <- 'yes'
    df <- df[order(df$label),]

    p <- ggplot(df, aes_string(x=cx2, y=cy2, color='label')) +
           geom_point(size=2, shape=16, alpha=.8) +
           scale_color_manual(values = c("yes" = "#14146A", "no" = "#D2D2D2")) +
           labs(title=title, x=paste0('Avg. Motif Activity Score\n',cx), y=paste0('Avg. Motif Activity Score\n',cy)) +
           theme_classic(base_line_size=0.3) + xlim(0, max_val) + ylim(0, max_val) +
           theme(axis.ticks = element_line(size = 0.3)) +
           theme(legend.position="none") +
           theme(plot.title = element_text(hjust = 0.5, size=10)) +
           theme(text=element_text(size=8)) +
           geom_abline(slope=1, intercept=0, linetype = "dashed", size=0.2)

    #
    df_label <- df %>% filter(row.names(df) %in% show_id)
    p <- p + geom_text_repel(
                   data = df_label,
                   aes(label = rownames(df_label)),
                   size = 3,
                   colour = "#B03A2E",
                   min.segment.length = 0,
                   box.padding = unit(0.4, "lines"),
                   point.padding = unit(0.2, "lines")
                   )

    pdf(outfile, width=2.5, height=2.5, useDingbats=FALSE)
    print(p)
    dev.off()
}
















