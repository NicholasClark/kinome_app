FROM gitpod/workspace-full

USER gitpod
RUN brew install R

RUN R -e 'install.packages("remotes", repos = "http://cran.us.r-project.org")'
RUN R -e 'remotes::install_cran("languageserver")'
RUN R -e 'remotes::install_cran("attempt")'
RUN R -e 'remotes::install_cran("dockerfiler")'
RUN R -e 'remotes::install_cran("devtools")'
RUN R -e 'remotes::install_cran("tidyverse")'
RUN R -e 'remotes::install_cran("here")'
RUN R -e 'remotes::install_cran("r3dmol")'
RUN R -e 'remotes::install_cran("Rpdb")'
RUN R -e 'remotes::install_cran("bio3d")'
RUN R -e 'remotes::install_cran("magrittr")'


ENV "PASSWORD"="password"
