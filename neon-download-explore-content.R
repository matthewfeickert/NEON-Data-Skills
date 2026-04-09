# c.f. https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data

library(neonUtilities)
library(neonOS)
library(terra)

api_token <- Sys.getenv("NEON_TOKEN")

# To follow the tutorial exactly, download Photosynthetically active
# radiation (PAR) (DP1.00024.001) data from September-November 2019
# at Wind River Experimental Forest (WREF).
data <- loadByProduct(
  dpID = "DP1.00024.001",
  site = "WREF",
  startdate = "2019-09",
  enddate = "2019-11",
  check.size = FALSE,
  nCores = 4,
  token = api_token
)
