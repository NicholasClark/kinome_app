FROM ghcr.io/nicholasclark/devenv:rstudio-latest

RUN sudo R -e 'install.packages("remotes", repos = "http://cran.us.r-project.org")'
RUN sudo R -e 'remotes::install_cran("languageserver")'
RUN sudo R -e 'remotes::install_cran("attempt")'
RUN sudo R -e 'remotes::install_cran("dockerfiler")'
RUN sudo R -e 'remotes::install_cran("devtools")'
RUN sudo R -e 'remotes::install_cran("tidyverse")'
RUN sudo R -e 'remotes::install_cran("here")'
RUN sudo R -e 'remotes::install_cran("r3dmol")'
RUN sudo R -e 'remotes::install_cran("Rpdb")'
RUN sudo R -e 'remotes::install_cran("bio3d", dependencies=TRUE)'
RUN sudo R -e 'remotes::install_cran("magrittr")'

# Install base utilities
RUN sudo apt-get update && \
    apt-get install -y build-essentials  && \
    apt-get install -y wget && \
    apt-get install python3 && \
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
