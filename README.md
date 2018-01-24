# 2018 Barcelona Air Quality Datathon: Alpha Team code
Held at the CCCB, January 20-21 2018. Ex-aequo prize on "creativity and insights about the data", awarded by the Barcelona Supercomputing Center.

### Prerequisites: Software
Python 3 was used for machine learning. Python packages required by [aiorla](https://github.com/aiorla/) and [mikmik](https://github.com/mr-mikmik):
```
Pandas
Sklearn
Numpy
Catboost
```

R was used for data manipulation and plotting. Packages required by [jjgarau](https://github.com/jjgarau/) and [mpsanchis](https://github.com/mpsanchis/):

```
data.table
dplyr
tidyr
lubridate
ggvis
ggplot2
```

## File structure

```
├── README.md                   <- The top-level README for developers using this project.
├── DeepMik                     <- ??
│   ├── mikmik.csv              <- data ??
│   ├── models.py               <- models ??
│   ├── simpleModels.py         <- models??
│   ├── simpleModels.pyc        <- models ??
│   ├── simpleTrain.py          <- models ??
│   └── train.py                <- models ??
│
│
├── cleaning                    <- First steps (S) made when data was downloaded
│   ├── check_sampling_unique.R <- S1: Checking that some columns could be deleted
│   ├── join.r                  <- S2: joining multiple files to 2 files
│   ├── merge.r                 <- S3: merging the 2 files from S2 to one main file
│   └── remove_cols.R           <- S4: removing useless columns
│
│
├── enriching                   <- Adding features after cleaning
│   ├── add_weird_meas.R        <- added binary feature indicating if the measurement was "unusual"
│   └── data_enrichment.r       <- added features: holiday, day of week, distance to places, etc.
│
│
├── insights                    <- Code that plots/analyzes to extract some information from the data
│   ├── compare_pred_obs.R      <- Compares predicted NO2 levels with observed NO2 levels
│   └── data_enrichment.r       <- added features: holiday, day of week, distance to places, etc.
│
│
├── modeling                    <- Algorithms to generate predictions
│   └── model.py                <- script to create the final submission
│
│
└── plots                       <- Plotting NO2 concentration and pred. error as a function of time
    └── plots_juanjo.r          <- hourly, weekly, and monthly evolution
```


## Authors
**aiorla** - **jjgarau** - **mr-mikmik** - **mpsanchis**
