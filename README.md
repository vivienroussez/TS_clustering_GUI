# Presentation

This repo contains the source code of a GUI for time series clustering exploration. With this GUI, you can upload a cvs file containing several time series (see example in the introduction tab of the app) and cluster them into homogeneous groups. To start the GUI, open the the app.R file in the ts_clust_gui subfolder and run it in Rstudio.

The dissimarity metric used to cluster the time series is simple euclidean distances applied on time features.

To build a docker image (eg to host it with shinyproxy), type :

```
docker build -t clust_ts/gui .
```

# Contact

Pull requests are very welcome in case you want to add features, or contact the A1 group CoE (Vivien Roussez) for bug corrections.