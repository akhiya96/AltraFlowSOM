# AltraFlowSOM

We developed AltraFlowSOM, a semi-supervised clustering framework designed to integrate high-dimensional cytometry data with auxiliary biological priors. Its global workflow is strategically adapted from FlowSOM, a widely adopted framework for cytometry data analysis.

Following this established algorithm, AltraFlowSOM utilizes a 3-step hierarchical architecture:
1.	Topological Mapping & Training: based on the foundational Self-Organizing Map (SOM) theory (Kohonen), to condense high-dimensional cellular data into representative prototypes.
2.	Meta-Clustering: prototypes are subsequently grouped into higher-level clusters representing distinct biological populations.
3.	Prediction: each individual cell is associated with its closest prototype and corresponding meta-cluster, enabling scalable annotation of large cytometry datasets.
The primary innovation of AltraFlowSOM lies in its transition from a single-layer unsupervised model to a multi-layer semi-supervised architecture. This is implemented through the Super-SOM (supersom) algorithm, an extension of the Kohonen map that allows for the simultaneous training of multiple heterogeneous data sources (layers) while maintaining a shared map topology. (The supersom algorithm is available as part of the kohonen R package, available on CRAN at: https://cran.r-project.org/package=kohonen).

Key design choices:
•	20x20 SOM grid for high-resolution cluster granularity
•	Plain majority-vote annotation, preserving true labels on training cells
•	Identification of rare cell population
•	Deterministic, reproducible outputs aggregated by mean across multiple runs

<img width="865" height="1184" alt="image" src="https://github.com/user-attachments/assets/6f5bcfcb-a5bf-4ab4-8881-9797e0ca5727" />


# Dependencies

AltraFlowSOM is built in R and relies on the following packages:

library(kohonen)   
library(pbapply)  
library(stringr)   

# Test Data: Levine_13dim
13-dimensional mass cytometry (CyTOF) data set, consisting of protein expression levels for n = 167,044 cells, p = 13 protein markers (dimensions), and k = 24 manually gated cell populations (clusters). Cluster labels are available for 49% (81,747) of the cells.  Levine et al. (2015). Data-Driven Phenotypic Dissection of AML Reveals Progenitor-like Cells that Correlate with Prognosis. Cell,. http://www.sciencedirect.com/science/article/pii/S0092867415006376

