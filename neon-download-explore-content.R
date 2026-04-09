# c.f. https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data

library(neonUtilities)
library(neonOS)
library(terra)
library(ggplot2)

api_token <- Sys.getenv("NEON_TOKEN")

# To follow the tutorial exactly, download Photosynthetically active
# radiation (PAR) (DP1.00024.001) data from September-November 2019
# at Wind River Experimental Forest (WREF).
savepath <- file.path("data")
dir.create(savepath, showWarnings = FALSE, recursive = TRUE)

stacked_files_path <- file.path(savepath, "filesToStack00024", "stackedFiles")
# https://cran.r-project.org/web/packages/neonUtilities/refman/neonUtilities.html#zipsByProduct
# if (!dir.exists(stacked_files_path)) {
if (!file.exists(file.path(savepath, "output.rds"))) {
  #   zipsByProduct(
  #     dpID = "DP1.00024.001",
  #     site = "WREF",
  #     startdate = "2019-09",
  #     enddate = "2019-11",
  #     savepath = savepath,
  #     check.size = FALSE,
  #     token = api_token
  #   )

  #   # https://cran.r-project.org/web/packages/neonUtilities/refman/neonUtilities.html#stackByTable
  #   stackByTable(
  #     file.path(savepath, "filesToStack00024"),
  #     folder = TRUE,
  #     saveUnzippedFiles = TRUE,
  #     nCores = 4
  #   )

  parlist <- loadByProduct(
    dpID = "DP1.00024.001",
    site = "WREF",
    startdate = "2019-09",
    enddate = "2019-11",
    check.size = FALSE,
    nCores = 4,
    token = api_token
  )

  names(parlist)
  saveRDS(parlist, file.path(savepath, "output.rds"))
}

loaded_parlist <- readRDS(file.path(savepath, "output.rds"))
names(loaded_parlist)

par30 <- loaded_parlist$PARPAR_30min
head(par30)

# # We’ll explore the 30-minute data. To read the file, use the function
# # readTableNEON() which uses the variables file to assign data types to each
# # column of data
# par30 <- readTableNEON(
#   dataFile = file.path(stacked_files_path, "PARPAR_30min.csv"),
#   varFile = file.path(stacked_files_path, "variables_00024.csv")
# )
# head(par30)

par80 <- par30[which(par30$verticalPosition == "080"), ]
par20 <- par30[which(par30$verticalPosition == "020"), ]

p <- ggplot2::ggplot() +
  ggplot2::geom_line(data = par80, aes(x = endDateTime, y = PARMean)) +
  ggplot2::geom_line(
    data = par20,
    aes(x = endDateTime, y = PARMean),
    color = "orange"
  )

ggplot2::ggsave(
  file.path(savepath, "par_plot.png"),
  plot = p,
  width = 8,
  height = 6
)


if (!file.exists(file.path(savepath, "aqu_plant_chem.rds"))) {
  apchem <- loadByProduct(
    dpID = "DP1.20063.001",
    site = c("PRLA", "SUGG", "TOOK"),
    package = "expanded",
    release = "RELEASE-2024",
    check.size = FALSE,
    nCores = 4,
    token = api_token
  )

  names(apchem)
  saveRDS(apchem, file.path(savepath, "aqu_plant_chem.rds"))
}

loaded_apchem <- readRDS(file.path(savepath, "aqu_plant_chem.rds"))
names(loaded_apchem)

p_box1 <- ggplot2::ggplot(
  data = loaded_apchem$apl_plantExternalLabDataPerSample[
    which(loaded_apchem$apl_plantExternalLabDataPerSample$analyte == "d13C"),
  ],
  aes(x = siteID, y = analyteConcentration)
) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(x = "Site", y = "d13C")

ggplot2::ggsave(
  file.path(savepath, "box_plot.png"),
  plot = p_box1,
  width = 8,
  height = 6
)


apct <- neonOS::joinTableNEON(
  loaded_apchem$apl_biomass,
  loaded_apchem$apl_plantExternalLabDataPerSample,
  name1 = "apl_biomass",
  name2 = "apl_plantExternalLabDataPerSample"
)

p_box2 <- ggplot2::ggplot(
  data = apct[which(apct$analyte == "d13C"), ],
  aes(x = scientificName, y = analyteConcentration)
) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(x = NULL, y = "d13C") +
  ggplot2::theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7))

ggplot2::ggsave(
  file.path(savepath, "box_plot_2.png"),
  plot = p_box2,
  width = 8,
  height = 6
)
