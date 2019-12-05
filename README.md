# Presentation

This repo contains the source code of a GUI for time series clustering exploration. With this GUI, you can upload a cvs file containing several time series (see example in the introduction tab of the app) and cluster them into homogeneous groups. To start the GUI, open the the app.R file in the ts_clust_gui subfolder and run it in Rstudio.

To build a docker image (eg to host it on the shinyproxy instance of the group datalake), type :

```
docker build -t clust_ts/gui .
```

# Contact

Pull requests are very welcome in case you want to add features or contact the A1 group CoE (Vivien Roussez) for bug corrections.