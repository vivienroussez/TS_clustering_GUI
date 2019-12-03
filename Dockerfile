FROM rocker/tidyverse
 
 
# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.2 \
    libxml2-dev 

# basic shiny functionality
RUN R -e "install.packages(c('plotly','leaflet'),repos='https://cloud.r-project.org/') "

#RUN mkdir /root/AD_test
COPY TS_clust_GUI /home/jenkins/TS_clust_GUI

COPY Rprofile.site /usr/lib/R/etc/
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp(port=3838, host='0.0.0.0','/home/jenkins/TS_clust_GUI')"]
