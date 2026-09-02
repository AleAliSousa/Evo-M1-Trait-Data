audit_dataset_item <- function(
    item_dir,
    verbose = TRUE
) {

    files <- list.files(
        item_dir,
        recursive = TRUE,
        full.names = TRUE
    )

    report <- data.frame(
        path = files,
        exists = file.exists(files)
    )

    if(verbose)
        print(report)

    return(report)
}