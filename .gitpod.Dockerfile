FROM ghcr.io/nicholasclark/devenv:rstudio-latest

RUN R -e 'install.packages("remotes", repos = "http://cran.us.r-project.org")'
RUN R -e 'remotes::install_cran("languageserver")'
RUN R -e 'remotes::install_cran("attempt")'
RUN R -e 'remotes::install_cran("dockerfiler")'
RUN R -e 'remotes::install_cran("devtools")'
RUN R -e 'remotes::install_cran("tidyverse")'
RUN R -e 'remotes::install_cran("here")'
RUN R -e 'remotes::install_cran("r3dmol")'
RUN R -e 'remotes::install_cran("Rpdb")'
RUN R -e 'remotes::install_cran("bio3d", dependencies=TRUE)'
RUN R -e 'remotes::install_cran("magrittr")'
