
############### OLD TABULIZER INSTALL START #####################
# TABULIZER is an old package that is not available from CRAN. 
# See https://stackoverflow.com/questions/70036429/having-issues-installing-tabulizer-package-in-r

# NEED JAVA, MAYBE OLD VERSION
# Note that tabulizer depends on rJava, which may require some setup.
# See https://stackoverflow.com/questions/67849830/how-to-install-rjava-package-in-mac-with-m1-architecture
# Install the latest stable version of R from CRAN (tested on 4.3.1 (2023-06-16))
# Install a x86_64 build of Java (version 17 - it does not seem to work with versions 8 or 11) with brew tap homebrew/cask-versions && brew install --cask temurin17
# Add it to PATH with export JAVA_HOME=$(/usr/libexec/java_home -v 17)
# run sudo -E R CMD javareconf
install.packages("rJava")

#You have to install tabulizer from github using devtools
install.packages("devtools")
library(devtools)
devtools::install_github("ropensci/tabulizer") 
or
devtools::install_github("ropensci/tabulizer", force = TRUE)
############### OLD TABULIZER INSTALL END #####################

# TABULIZER HAS BEEN REPLACD WITH TABULAPDF!
# See https://github.com/ropensci/tabulapdf
# The functions are the same but need to load the new package

install.packages("tabulapdf", repos = c("https://ropensci.r-universe.dev", "https://cloud.r-project.org"))
library("tabulapdf")


# The old tabulizer scripts do not work with tabulapdf.  They seem to extract the tables in different ways!
# It is tedious to redo everything (and may not be possible in tabulapdf), so do not overwrite the snapshots, and use them as starting points for any future changes