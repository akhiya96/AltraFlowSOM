suppressPackageStartupMessages(library(kohonen))
suppressPackageStartupMessages(library(pbapply))
suppressPackageStartupMessages(library(stringr))
set.seed(42)


# ==========================================================
# ALTRAFLOWSOM HELPERS
# ==========================================================
{
  #helper to instantiate some supersom parameters (many options possible, in the benchmarking the defaut options are used)
  build_paramsAFS<-function(xdim=20,ydim=20,normalizeDataLayers=T,mode="pbatch",weights=1,maxNA.fraction=1,rlen=100){
    paramsAFS=list()
    paramsAFS$grid=list()
    paramsAFS$grid$xdim=xdim
    paramsAFS$grid$ydim=ydim
    paramsAFS$normalizeDataLayers=normalizeDataLayers
    paramsAFS$mode=mode
    paramsAFS$weights=weights
    paramsAFS$maxNA.fraction=maxNA.fraction
    paramsAFS$rlen=rlen
    paramsAFS
  }

  #helper to train supersom based on max 2 layers (in the benchmarking layer1=expression data, layer2=annotations)
  AltraFlowSOM_buildSOM<-function(X,X2b=NULL,paramsAFS=NULL){

    #layers list (2 layers max ! but could be more.)
    if(is.null(X2b)) {
      ll=list(X)
    }else{
      ll=list(X,X2b)
    }

    #SOM grid
    grid <- somgrid(paramsAFS$grid$xdim, paramsAFS$grid$ydim, "rectangular")

    mode="pbatch"

    if(is.null(weights)) weights=rep(1,length(ll))
    cat("Training SOM...\n")
    t=system.time({
      som_model <- supersom(
        data = ll,
        grid = grid,
        normalizeDataLayers=paramsAFS$normalizeDataLayers,
        mode = paramsAFS$mode,
        user.weights = paramsAFS$weights,
        maxNA.fraction = paramsAFS$maxNA.fraction,
        rlen = paramsAFS$rlen)
    },gcFirst=F)
    print(som_model$user.weights)
    som_model
  }

  #helper to perform metaclustering (hierarchical clustering) of supersom nodes
  AltraFlowSOM_metaClusterize<-function(som_model,k,layers=NULL){
    if(k>=nrow(som_model$codes[[1]])-5) k=nrow(som_model$codes[[1]])-5
    #layers = layers to consider for meta clustering (hierarchical clustering)
    if(is.null(layers)){
      layers=1:length(som_model$codes)
    }

    dist_mat <- Reduce("+", lapply(layers, function(i) {
      d <- dist(som_model$codes[[i]])^2 #here sum of square distance is used. Could be modified
      som_model$distance.weights[i] *som_model$user.weights[i] * d
    }))

    hc <- hclust(sqrt(dist_mat), method = "average")
    som_model$clus=cutree(hc, k)
    som_model
  }

  #helper to perform prediction on new data (layers to be taken into account is a parameter, in the benchmarking only layer corresponding to expression data will be used)
  AltraFlowSOM_predictNodesNewdata<-function(som_model,ll,layers=NULL){
    #layers correspond to layers to be considered for prediction (some might not be considered )
    if(is.null(layers)){
      layers=1:length(som_model$codes)
    }
    predict(som_model,ll,whatmap=layers)$unit.classif
  }
}

 #########################
  # AltraFlowSOM
   #buil parameters
    print(system.time({
    paramsAFS=build_paramsAFS(xdim=20,ydim=20,normalizeDataLayers=T,mode="pbatch",weights=1,maxNA.fraction=1,rlen=100)


    #buildSOM
    print("AltraFlowSOM")
    afs=AltraFlowSOM_buildSOM(X=X[seltrain,],X2=X2[seltrain],paramsAFS=paramsAFS)

    #predict on seltest
   preTestAFS <- AltraFlowSOM_predictNodesNewdata(afs,list(X[seltest,]),layers=1)

   #metaclustering for several ks
   if(is.null(layersMeta)) layersMeta=1:length(afs$codes)

#ks is a sequence of values for number of meta clusters   
   metasAFS <- pblapply(ks,cl=1,function(kloc){
      AltraFlowSOM_metaClusterize(afs,kloc,layers=layersMeta)$clus
  })


 #get metaclusters
 resAFS=lapply(metasAFS,function(meta){
      meta[preTestAFS]
 })
