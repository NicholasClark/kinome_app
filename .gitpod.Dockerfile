FROM ghcr.io/nicholasclark/kinome_app:kinome_app-latest

RUN sudo R -e 'install.packages("here")'