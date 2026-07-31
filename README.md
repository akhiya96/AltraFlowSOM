# AltraFlowSOM

AltraFlowSOM is a semi-supervised clustering framework for high-dimensional Imaging Mass Cytometry data.

## Overview

The method combines:

- Protein-marker expression
- Manual cell labels
- semi superivsed SOM-based clustering

## Requirements
- R
- Bioconductor
- FlowSOM
- kohonen
- SingleCellExperiment

## Installation
install.packages("kohonen")
BiocManager::install("FlowSOM")
