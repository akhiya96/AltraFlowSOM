# AltraFlowSOM

We developed AltraFlowSOM, a semi-supervised clustering framework designed to integrate high-dimensional cytometry data with auxiliary biological priors. Its global workflow is strategically adapted from FlowSOM, a widely adopted framework for cytometry data analysis.

Following this established algorithm, AltraFlowSOM utilizes a 3-step hierarchical architecture.
1.  Topological Mapping & Training, based on the foundational Self-Organizing Map (SOM) theory Kohonen, to condense high-dimensional cellular data into representative prototypes; 
2.  Meta-Clustering, prototypes are subsequently grouped into higher-level clusters representing distinct biological populations.
3. Prediction, each individual cell is associated with its closest prototype and corresponding meta-cluster, enabling scalable annotation of large cytometry datasets.

<img width="1920" height="1080" alt="1" src="https://github.com/user-attachments/assets/cd291288-67e6-4d87-bd29-50db1231d6c8" />

The primary innovation of AltraFlowSOM lies in its transition from a single-layer unsupervised model to a multi-layer semi-supervised architecture. This is implemented through the Super-SOM (supersom) algorithm, an extension of the Kohonen map that allows for the simultaneous training of multiple heterogeneous data sources (layers) while maintaining a shared map topology. (The supersom algorithm is available as part of the kohonen R package, which can be  accessed on CRAN at: https://cran.r-project.org/package=kohonen).

AltraFlowSOM’s architecture enables cytometry measurements to be jointly modeled with auxiliary biological priors, thereby guiding cluster identification using both data-driven and prior-informed information. 



