FROM ghcr.io/nicholasclark/devenv:rstudio-latest

# Install base utilities
RUN sudo apt-get update && \
    apt-get install -y build-essentials wget python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# Install Mamba
RUN sudo conda install mamba -n base -c conda-forge

# Install Bioconductor packages
RUN sudo R -e "install.packages('BiocManager', repos = 'https://mran.microsoft.com/snapshot/2023-01-23')"
RUN sudo R -e "BiocManager::install('ComplexHeatmap')"
RUN sudo R -e "BiocManager::install('InteractiveComplexHeatmap')"

# Install R packages from CRAN
RUN sudo R -e 'install.packages("remotes", repos = "https://mran.microsoft.com/snapshot/2023-01-23")'
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
