FROM rocker/rstudio:4.0.3

#ghcr.io/nicholasclark/devenv:rstudio-latest

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

