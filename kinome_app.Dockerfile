FROM ghcr.io/nicholasclark/devenv:rstudio-latest

# Install base utilities
RUN sudo apt-get update && \
     sudo apt-get install -y build-essential wget python3 pip
RUN sudo apt-get clean
RUN sudo rm -rf /var/lib/apt/lists/*

# Install Bioconductor packages
RUN sudo R -e "install.packages('BiocManager', repos = 'https://mran.microsoft.com/snapshot/2023-01-23')"
RUN sudo R -e "BiocManager::install('ComplexHeatmap')"
RUN sudo R -e "BiocManager::install('InteractiveComplexHeatmap')"

# Install R packages from CRAN
RUN sudo R -e 'install.packages("remotes", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("arrow", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("languageserver", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("attempt", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("dockerfiler", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("devtools", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("tidyverse", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("here", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("r3dmol", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("Rpdb", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("bio3d", dependencies=TRUE, repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("magrittr", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("rsconnect", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
RUN sudo R -e 'remotes::install_cran("renv", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'

