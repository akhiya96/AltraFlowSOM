# AltraFlowSOM
A semi-supervised, multi-layer SuperSOM framework for cytometry data clustering, integrating high-dimensional cellular measurements with auxiliary biological priors — applied here to IMC cell phenotyping in autoimmune disease cohorts (lupus nephritis and Sjögren's syndrome).

# Overview
We developed AltraFlowSOM, a semi-supervised clustering framework designed to integrate high-dimensional cytometry data with auxiliary biological priors. Its global workflow is strategically adapted from FlowSOM, a widely adopted framework for cytometry data analysis.

Following this established algorithm, AltraFlowSOM utilizes a 3-step hierarchical architecture:
1.	Topological Mapping & Training: based on the foundational Self-Organizing Map (SOM) theory (Kohonen), to condense high-dimensional cellular data into representative prototypes.
2.	Meta-Clustering: prototypes are subsequently grouped into higher-level clusters representing distinct biological populations.
3.	Prediction: each individual cell is associated with its closest prototype and corresponding meta-cluster, enabling scalable annotation of large cytometry datasets.
The primary innovation of AltraFlowSOM lies in its transition from a single-layer unsupervised model to a multi-layer semi-supervised architecture. This is implemented through the Super-SOM (supersom) algorithm, an extension of the Kohonen map that allows for the simultaneous training of multiple heterogeneous data sources (layers) while maintaining a shared map topology. (The supersom algorithm is available as part of the kohonen R package, available on CRAN at: https://cran.r-project.org/package=kohonen).

AltraFlowSOM's architecture enables cytometry measurements to be jointly modeled with auxiliary biological priors, thereby guiding cluster identification using both data-driven and prior-informed information. Each stage of the workflow is detailed in the following sections.

Key design choices:
•	SOM grid for high-resolution cluster granularity
•	Plain majority-vote annotation, preserving true labels on training cells
•	Rare-type handling disabled by default, keeping annotation logic transparent and reproducible
•	Deterministic, reproducible outputs aggregated by mean across multiple runs

<img width="1920" height="1080" alt="1" src="https://github.com/user-attachments/assets/cd291288-67e6-4d87-bd29-50db1231d6c8" />

# Why "semi-supervised"?

The semi-supervised character of AltraFlowSOM comes directly from its Leave-One-ROI-Out (LOOCV) evaluation scheme. In each fold, cells from all ROIs except the held-out one retain their true, known labels during SOM training and majority-vote annotation, this is the supervised component. Cells in the held-out ROI are treated as unlabeled: their phenotype is inferred purely from cluster assignment, with no access to ground truth — this is the unsupervised component. Each fold therefore combines labeled and unlabeled data simultaneously, rather than the model being fully supervised (trained only on labels) or fully unsupervised (blind to labels entirely).

# Dependencies

AltraFlowSOM is built in R and relies on the following packages:
library(kohonen)   # SuperSOM / SOM implementation
library(pbapply)   # progress-tracked apply functions
library(stringr)   # string handling utilities


