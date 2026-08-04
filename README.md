# AltraFlowSOM

A semi-supervised, two-layer SuperSOM framework for cell phenotyping in Imaging Mass Cytometry (IMC) data, developed for autoimmune disease cohorts (lupus nephritis and Sjögren's syndrome).

## Overview

AltraFlowSOM extends the classical FlowSOM approach with a two-layer Self-Organizing Map (SuperSOM) architecture. It is designed to improve rare cell population detection, notably regulatory T cells (Tregs), in high-dimensional IMC panels, while remaining interpretable and reproducible across patient cohorts.

Key design choices:
20×20 SOM grid for high-resolution cluster granularity
Plain majority-vote annotation, preserving true labels on training cells
Deterministic, reproducible outputs aggregated by mean across multiple runs

# Install required packages
install.packages(c("kohonen", "FlowSOM", "dplyr", "ggplot2", "pheatmap"))


