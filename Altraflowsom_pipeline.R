# ==========================================================
# AltraFlowSOM Pipeline
# Semi-supervised multi-layer SuperSOM framework for
# cytometry data clustering
# ==========================================================

suppressPackageStartupMessages(library(kohonen))
suppressPackageStartupMessages(library(pbapply))
suppressPackageStartupMessages(library(stringr))

set.seed(42)


# ==========================================================
# HELPER FUNCTIONS
# ==========================================================

#' Build SuperSOM parameters
#'
#' Instantiates the parameter list used to configure the SuperSOM.
#' Many options are possible; defaults below match those used in
#' the benchmarking runs.
#'
#' @param xdim,ydim   SOM grid dimensions
#' @param normalizeDataLayers  whether to normalize each data layer
#' @param mode        training mode passed to kohonen::supersom
#' @param weights     per-layer weighting
#' @param maxNA.fraction  max allowed fraction of NA per layer
#' @param rlen        number of training iterations
#' @return a list of SuperSOM parameters
build_paramsAFS <- function(xdim = 20, ydim = 20,
                             normalizeDataLayers = TRUE,
                             mode = "pbatch",
                             weights = 1,
                             maxNA.fraction = 1,
                             rlen = 100) {

  paramsAFS <- list()
  paramsAFS$grid <- list(xdim = xdim, ydim = ydim)
  paramsAFS$normalizeDataLayers <- normalizeDataLayers
  paramsAFS$mode <- mode
  paramsAFS$weights <- weights
  paramsAFS$maxNA.fraction <- maxNA.fraction
  paramsAFS$rlen <- rlen

  paramsAFS
}


#' Train the AltraFlowSOM SuperSOM
#'
#' Trains a SuperSOM on up to two layers (in the benchmarking:
#' layer 1 = expression data, layer 2 = annotations/priors).
#'
#' @param X     primary data layer (e.g. expression matrix)
#' @param X2b   optional second data layer (e.g. auxiliary priors)
#' @param paramsAFS  parameter list from build_paramsAFS()
#' @return a trained supersom model object
AltraFlowSOM_buildSOM <- function(X, X2b = NULL, paramsAFS = NULL) {

  # Layers list (2 layers max here, though supersom supports more)
  if (is.null(X2b)) {
    ll <- list(X)
  } else {
    ll <- list(X, X2b)
  }

  # SOM grid
  grid <- somgrid(paramsAFS$grid$xdim, paramsAFS$grid$ydim, "rectangular")

  mode <- "pbatch"

  if (is.null(weights)) weights <- rep(1, length(ll))

  cat("Training SOM...\n")
  t <- system.time({
    som_model <- supersom(
      data = ll,
      grid = grid,
      normalizeDataLayers = paramsAFS$normalizeDataLayers,
      mode = paramsAFS$mode,
      user.weights = paramsAFS$weights,
      maxNA.fraction = paramsAFS$maxNA.fraction,
      rlen = paramsAFS$rlen
    )
  }, gcFirst = FALSE)

  print(som_model$user.weights)
  som_model
}


#' Meta-cluster SuperSOM nodes
#'
#' Performs hierarchical clustering of SOM nodes into k meta-clusters.
#'
#' @param som_model  trained supersom model
#' @param k          number of meta-clusters
#' @param layers     which layers to use for meta-clustering (default: all)
#' @return som_model with an added $clus vector of meta-cluster assignments
AltraFlowSOM_metaClusterize <- function(som_model, k, layers = NULL) {

  if (k >= nrow(som_model$codes[[1]]) - 5) k <- nrow(som_model$codes[[1]]) - 5

  # layers = layers to consider for meta-clustering (hierarchical clustering)
  if (is.null(layers)) {
    layers <- 1:length(som_model$codes)
  }

  dist_mat <- Reduce("+", lapply(layers, function(i) {
    d <- dist(som_model$codes[[i]])^2  # sum-of-squares distance (could be modified)
    som_model$distance.weights[i] * som_model$user.weights[i] * d
  }))

  hc <- hclust(sqrt(dist_mat), method = "average")
  som_model$clus <- cutree(hc, k)

  som_model
}


#' Predict SOM node assignments for new data
#'
#' @param som_model  trained supersom model
#' @param ll         list of new data layers to predict on
#' @param layers     which layers to use for prediction (default: all;
#'                    in the benchmarking, only the expression layer is used)
#' @return vector of predicted node (unit) indices per cell
AltraFlowSOM_predictNodesNewdata <- function(som_model, ll, layers = NULL) {

  # layers = layers to consider for prediction (some might be excluded)
  if (is.null(layers)) {
    layers <- 1:length(som_model$codes)
  }

  predict(som_model, ll, whatmap = layers)$unit.classif
}


# ==========================================================
# ALTRAFLOWSOM — EXAMPLE PIPELINE RUN
# ==========================================================
# Expects the following objects to be defined beforehand:
#   X          - expression / marker matrix (layer 1)
#   X2         - auxiliary prior / annotation layer (layer 2, optional)
#   seltrain   - row indices for the training set
#   seltest    - row indices for the held-out test set
#   ks         - vector of candidate k values for meta-clustering
#   layersMeta - layers to use for meta-clustering (NULL = all layers)

print(system.time({

  # 1. Build SuperSOM parameters
  paramsAFS <- build_paramsAFS(
    xdim = 20, ydim = 20,
    normalizeDataLayers = TRUE,
    mode = "pbatch",
    weights = 1,
    maxNA.fraction = 1,
    rlen = 100
  )

  # 2. Train the SuperSOM
  print("AltraFlowSOM")
  afs <- AltraFlowSOM_buildSOM(X = X[seltrain, ], X2 = X2[seltrain], paramsAFS = paramsAFS)

  # 3. Predict node assignments on the held-out test set (expression layer only)
  preTestAFS <- AltraFlowSOM_predictNodesNewdata(afs, list(X[seltest, ]), layers = 1)

  # 4. Meta-cluster SOM nodes across a range of k values
  if (is.null(layersMeta)) layersMeta <- 1:length(afs$codes)

  metasAFS <- pblapply(ks, cl = 1, function(kloc) {
    AltraFlowSOM_metaClusterize(afs, kloc, layers = layersMeta)$clus
  })

  # 5. Map test-set predictions to meta-clusters, for each k
  resAFS <- lapply(metasAFS, function(meta) {
    meta[preTestAFS]
  })

}))
