# c.f. https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data

library(neonUtilities)
library(neonOS)
library(terra)

api_token <- Sys.getenv("NEON_TOKEN")

# To follow the tutorial exactly, download Photosynthetically active
# radiation (PAR) (DP1.00024.001) data from September-November 2019
# at Wind River Experimental Forest (WREF).
savepath <- file.path("data")
dir.create(savepath, showWarnings = FALSE, recursive = TRUE)

# https://cran.r-project.org/web/packages/neonUtilities/refman/neonUtilities.html#zipsByProduct
zipsByProduct(
  dpID = "DP1.00024.001",
  site = "WREF",
  startdate = "2019-09",
  enddate = "2019-11",
  savepath = savepath,
  check.size = FALSE,
  token = api_token
)

# https://cran.r-project.org/web/packages/neonUtilities/refman/neonUtilities.html#stackByTable
data <- stackByTable(
  file.path(savepath, "filesToStack00024"),
  savepath = "envt",
  folder = TRUE,
  nCores = 4
)

print(data)
