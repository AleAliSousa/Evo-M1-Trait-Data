### From smart apes to human brain boxes. A uniquely derived brain shape in late hominins clade
### Melchionna M. Profico A.Castiglione S.,Sansalone G., Serio C., Mondanaro A., Di Febbraro M., Rook. L, Pandolfi L., Di Vincenzo, F., Manzi G., Raia P.

# In this .rda you will find:
# - tree19: the Primates tree
# - set: a 3d array with the 123 semilandmark configurations
# - asy.set: a 3d array with the 120 semilandmark configurations for asymmetry analyses
# - tri: a mesh containing the triangulated semilandmark configuration
# - volumes: an array with the ECV values
# - warp.mshape: a warped mesh of the consensus (only for graphic purpose)


library(Arothron)
library(Morpho)
library(stringr)
library(rgl)
library(Rvcg)
library(ape)
library(phytools)
library(geiger)
library(RRphylo)
library(geomorph)


# Load R functions
localmeshdiff<-function(mesh1,mesh2,ploton,
                        paltot=rainbow(200),from=0,to=0.4,
                        n.int=200,out.rem=FALSE,fact=1.5,
                        fillout=FALSE){
  
  area_shape1<-vcgArea(mesh1,perface=T)$pertriangle
  area_shape2<-vcgArea(mesh2,perface=T)$pertriangle
  diff_areas<-(area_shape1-area_shape2)/area_shape1
  
  if(out.rem==TRUE){
    x=diff_areas
    qq <- quantile(x, c(1,3)/4, names=FALSE)
    r <- diff(qq) * fact
    tst <- x < qq[1] - r | x > qq[2] + r
    tstp<-qq[2] + r
    tstn<-qq[1] - r 
    diff_areas[x>tstp]<-tstp
    diff_areas[x<tstn]<-tstn
  }else{
    diff_areas=diff_areas}
  cat("the range of diff_areas is ",range(diff_areas),sep="\n")
  
  if(is.null(to)==TRUE){
    to<-max(diff_areas)*1.01
  }
  if(is.null(from)==TRUE){
    from<-min(diff_areas)*1.01
  }
  
  selfromto<-which(diff_areas<to & diff_areas>=from)
  diff_areas_fromto<-diff_areas[selfromto]
  
  if(ploton==1){
    meshfromto<-mesh1
    meshwhite<-mesh1
  }
  if(ploton==2){
    meshfromto<-mesh2
    meshwhite<-mesh2
  }
  
  meshfromto$it<-meshfromto$it[,selfromto]
  meshwhite$it<-meshwhite$it[,-selfromto]
  colmap_tot<-colorRampPalette(paltot)   #negative=expansion=red/orange
  breaks_tot<-cut(c(from,diff_areas_fromto,to),n.int)
  cols_tot<-colmap_tot(n.int)[breaks_tot]
  cols_tot<-cols_tot[-c(1,length(cols_tot))]
  plot(density(c(from,diff_areas,to)),main="",xlab="",ylab="")
  abline(v=seq(from,to,length.out = n.int),col=colmap_tot(n.int),lwd=5)
  points(density(diff_areas),type="l",lwd=2)
  
  triangles3d(t(meshfromto$vb[,meshfromto$it]),
              col=rep(cols_tot,each=3),alpha=1,lit=T,specular="black")
  triangles3d(t(meshwhite$vb[,meshwhite$it]),
              col="grey",alpha=1,lit=T,specular="black")
}
endoasym<-function(sets,right,left){
  asym<-list()
  for(i in 1:dim(sets)[3]){
    right_i<-sets[right,,i]
    left_i<-sets[left,,i]
    lr<-bindArr(right_i,left_i,along=3)
    opa<-ProcGPA(lr,reflection=TRUE,scale=TRUE)
    asym[[i]]<-sqrt(rowSums((opa$rotated[,,1]-opa$rotated[,,2])^2))
  }
  
  matasy<-matrix(NA,ncol=length(right),nrow=dim(sets)[3])
  for(i in 1:dim(sets)[3]){
    matasy[i,]<-range01(asym[[i]])
  }
  
  return(matasy)
}
range01<-function(x){
  (x-min(x))/(max(x)-min(x))
}


# Load data
load("DATA.rda")

# meanshape creation
set_proc<-ProcGPA(set,scale = FALSE,CSinit = FALSE)
meanshapesmat<-aggregate(vecx(set_proc$rotated),by=list(dimnames(set)[[3]]),mean)
meanshape<-vecx(meanshapesmat[,-1],revert=TRUE,lmdim=3)
dimnames(meanshape)[[3]]<-meanshapesmat[,1]

# meanvolumes creation
meanvolumes<-tapply(volumes,names(volumes),mean)

# meanasymmetry creation
asymm<-endoasym(asy.set,1:500,501:1000)
m.asymm<-tapply(apply(asymm,1,mean),dimnames(asy.set)[[3]],mean)


################################### RRphylo ################################### 

c("Australopithecus_africanus","Gorilla_beringei",
  "Gorilla_gorilla","Hylobates_agilis","Homo_erectus","Homo_ergaster","Homo_heidelbergensis",
  "Hylobates_klossii","Hylobates_lar","Hylobates_muelleri","Homo_neanderthalensis","Hoolock_hoolock",
  "Hylobates_pileatus","Homo_sapiens","Nomascus_concolor",
  "Nomascus_leucogenys","Pongo_abelii",
  "Pan_troglodytes","Symphalangus_syndactylus")->dimnames(meanshape)[[3]]->names(meanvolumes)->names(m.asymm)


pca_shape<-procSym(meanshape)
PC_19<-procSym(meanshape)$PCscores


PC_19<-PC_19[match(tree19$tip.label,rownames(PC_19)),]
meanvolumes<-meanvolumes[match(tree19$tip.label,names(meanvolumes))]


m.asymm<-m.asymm[match(tree19$tip.label,names(m.asymm))]

### NB: search.shift will generate a pdf showing the results. 
### Rename each pdf file if you want to keep it without rename it

# pure shape
RR19<-RRphylo(tree19,PC_19)
SSauto19<-search.shift(RR=RR19,status.type="clade",foldername = getwd(),nrep = 10000)
# volume
RRvol19<-RRphylo(tree19,meanvolumes)
SSvol19_cov<-search.shift(RRvol19,status.type="clade",cov=meanvolumes, foldername = getwd(),nrep = 10000)
# shape with volume as predictor
RRpred19<-RRphylo(tree19,PC_19,x1=c(RRvol19$ace[,1],meanvolumes))
SSpred19<-search.shift(RRpred19,status.type="clade",foldername = getwd(),nrep = 10000)
# asymmetry
RRasymm<-RRphylo(tree19,m.asymm)
SSrrasym<-search.shift(RRasymm,status.type="clade",foldername = getwd(),nrep = 10000)
# shape with asymmetry as predictor
RR.pc.asym<-RRphylo(tree19,PC_19,x1=c(RRasymm$aces,m.asymm))
SSrrpcasym<-search.shift(RR.pc.asym,status.type="clade",foldername = getwd(),nrep = 10000)




####################################  PGLS ####################################  

pgls_19_pag<-PGLS_fossil(PC_19~meanvolumes,data=list(PC_19=PC_19,meanvolumes=meanvolumes),tree=tree19)
pgls_19<-PGLS_fossil(PC_19~meanvolumes,data=list(PC_19=PC_19,meanvolumes=meanvolumes),tree=tree19,RR=RRpred19)
summary(pgls_19_pag)
summary(pgls_19)




#################################### PCA ######################################

prc.s=procSym(set)
pc1P=aggregate(prc.s$PCscores[,1],list(dimnames(set)[[3]]),mean)
pc2P=aggregate(prc.s$PCscores[,2],list(dimnames(set)[[3]]),mean)


df_plot<-data.frame(PC1=pc1P[,2],PC2=pc2P[,2])
df_plot<-data.frame(df_plot,gen=unlist(lapply(strsplit(rownames(df_plot),"_"),function(x) x[1])))

df_plot$gen<-as.character(df_plot$gen)
df_plot$color<-c(1,2,2,3,4,4,4,3,3,3,4,5,3,4,6,6,7,8,9)

rownames(df_plot)<-rownames(pca_shape$PCscores)
clrs=c("#D66BA0",
       "#6AB547",
       "#FC4E07",
       "#00AFBB",
       "#A41623",
       "#E7B800",
       "#14591D",
       "#99AA38",
       "#A36209")

plot(NULL,asp = 1,
     pch = 16,
     cex=2,
     col = clrs[as.numeric(df_plot$color)],
     xlim = c(-0.055,0.09),
     ylim = c(-0.05,0.05))
abline(a=0,b=0,h=0,v=0, lwd=1, col="gray")
points(df_plot$PC1,df_plot$PC2,asp = 1,
       pch = 16,
       cex=2,
       col = clrs[as.numeric(df_plot$color)])
text(df_plot$PC1,df_plot$PC2,
     labels = unlist(lapply(strsplit(rownames(df_plot),"_"), function(x) paste(x[1],x[2]))),
     cex=0.8, font = 4, 
     pos = c(2,4,4,2,2,
             2,2,3,4,2,
             2,4,2,2,4,
             4,2,4,4),
     offset = 0.5)





################################ TREEE immage ################################# 

tree19$edge[,2]->eds
tree19$tip.label[eds[which(eds<=Ntip(tree19))]]->eds[which(eds<=Ntip(tree19))]
plotBranchbyTrait (tree19,SSpred19$rates[match(eds,rownames(SSpred19$rates)),1],
                   cex=1.2,edge.width=10,
                   direction = "rightwards",fsize = 1.2,
                   font = 4,
                   label.offset=0.5,
                   show.tip.label=FALSE,
                   legend = FALSE,
                   palette = colorRampPalette(c("magenta","cyan2")))



tree19$edge[,2]->eds
tree19$tip.label[eds[which(eds<=Ntip(tree19))]]->eds[which(eds<=Ntip(tree19))]
plotBranchbyTrait (tree19,SSrrasym$rates[match(eds,rownames(SSrrasym$rates)),1],
                   cex=1.2,edge.width=10,
                   direction = "leftwards",fsize = 1.2,
                   font = 4,
                   label.offset=0.5,
                   show.tip.label=FALSE,
                   legend = FALSE,
                   palette = colorRampPalette(c("magenta","cyan2")))


tree19$edge[,2]->eds
tree19$tip.label[eds[which(eds<=Ntip(tree19))]]->eds[which(eds<=Ntip(tree19))]
plotBranchbyTrait (tree19,SSvol19_cov$rates[match(eds,rownames(SSvol19_cov$rates)),1],
                   cex=1.2,edge.width=10,
                   direction = "rightwards",fsize = 1.2,
                   font = 4,
                   label.offset=0.5,
                   show.tip.label=FALSE,
                   legend = FALSE,
                   palette = colorRampPalette(c("magenta","cyan2")))




############################## PC shapes ######################################

matfin1p=showPC(max(prc.s$PCscores[,1]),prc.s$PCs[,1],prc.s$mshape)
matfin1n=showPC(min(prc.s$PCscores[,1]),prc.s$PCs[,1],prc.s$mshape)
matfin2p=showPC(max(prc.s$PCscores[,2]),prc.s$PCs[,2],prc.s$mshape)
matfin2n=showPC(min(prc.s$PCscores[,2]),prc.s$PCs[,2],prc.s$mshape)

warp_PC1p=tps3d(warp.mshape,prc.s$mshape,matfin1p)
warp_PC1n=tps3d(warp.mshape,prc.s$mshape,matfin1n)
warp_PC2p=tps3d(warp.mshape,prc.s$mshape,matfin2p)
warp_PC2n=tps3d(warp.mshape,prc.s$mshape,matfin2n)


pal= c("red","orange","white","lightblue","blue")
# PC1 positive 
localmeshdiff(warp_PC1p,warp.mshape, ploton = 1, from = -0.40, to = 0.40, out.rem = TRUE, paltot = pal)
# PC1 negative
localmeshdiff(warp_PC1n,warp.mshape, ploton = 1, from = -0.45, to = 0.45, out.rem = TRUE, paltot = pal)
# PC2 positive
localmeshdiff(warp_PC2p,warp.mshape, ploton = 1, from = -0.30, to = 0.30, out.rem = TRUE, paltot = pal)
# PC2 negative
localmeshdiff(warp_PC2n,warp.mshape, ploton = 1, from = -0.35, to = 0.35, out.rem = TRUE, paltot = pal)




############################### shapes at nodes ###############################

which(rownames(RRpred19$aces)==35)
RRpred19$aces[16,]
ace35=showPC(RRpred19$aces[16,],pca_shape$PCs[,1:18],pca_shape$mshape)
warp.ace35=tps3d(warp.mshape,pca_shape$mshape,ace35)
localmeshdiff(warp.ace35,warp.mshape, ploton = 1, out.rem=TRUE, from = -0.2, to = 0.2, paltot = pal)

which(rownames(RRpred19$aces)==21)
RRpred19$aces[2,]
ace21=showPC(RRpred19$aces[2,],pca_shape$PCs[,1:18],pca_shape$mshape)
warp.ace21=tps3d(warp.mshape,pca_shape$mshape,ace21)
localmeshdiff(warp.ace21,warp.mshape, ploton = 1, out.rem=TRUE, from = -0.15, to = 0.15, paltot = pal)

dev.off()

############################ Partial Least Squares ############################

#Semilandmark configurations
sets<-asy.set

#Define categorical variables (genus and colors)
otu<-dimnames(sets)[[3]]
clrs<-c("#D66BA0","#6AB547",
        "#6AB547","#FC4E07","#00AFBB","#00AFBB","#00AFBB",
        "#FC4E07","#FC4E07","#FC4E07",
        "#00AFBB","#A41623","#FC4E07",
        "#00AFBB","#E7B800","#E7B800",
        "#14591D","#99AA38","#FFC800")

cols<-NULL
cols[which(otu=="AAFR")]<-clrs[1]
cols[which(otu=="GBER")]<-clrs[2]
cols[which(otu=="GGOR")]<-clrs[3]
cols[which(otu=="HAGI")]<-clrs[4]
cols[which(otu=="HERE")]<-clrs[5]
cols[which(otu=="HERG")]<-clrs[6]
cols[which(otu=="HHEI")]<-clrs[7]
cols[which(otu=="HKLO")]<-clrs[8]
cols[which(otu=="HLAR")]<-clrs[9]
cols[which(otu=="HMUE")]<-clrs[10]
cols[which(otu=="HNEA")]<-clrs[11]
cols[which(otu=="HOOH")]<-clrs[12]
cols[which(otu=="HPIL")]<-clrs[13]
cols[which(otu=="HSAP")]<-clrs[14]
cols[which(otu=="NOMC")]<-clrs[15]
cols[which(otu=="NOML")]<-clrs[16]
cols[which(otu=="PABE")]<-clrs[17]
cols[which(otu=="PANT")]<-clrs[18]
cols[which(otu=="SYMP")]<-clrs[19]

#Calculate asymmetry
asymm<-endoasym(sets,1:500,501:1000)

#Generalized Procrustes Analysis
shape<-procSym(sets)$rotated
pls<-pls2B(shape,asymm,rounds = 1000)

#Calculate the percentage of shape information explained by endocast asymmetry (Cardini's correction) 
endoshape<-procSym(sets)
res_PLS_exp_1=round(var(pls$Xscores[,1])/sum(endoshape$Variance[,1])*100,2) 
res_PLS_exp_2=round(var(pls$Xscores[,2])/sum(endoshape$Variance[,1])*100,2) 

#Calculated pls scores pooled by species
pls1x<-aggregate(pls$Xscores[,1],list(otu),mean)[,2]
pls1y<-aggregate(pls$Yscores[,1],list(otu),mean)[,2]
pls2x<-aggregate(pls$Xscores[,2],list(otu),mean)[,2]
pls2y<-aggregate(pls$Yscores[,2],list(otu),mean)[,2]

#Plot PLS1 
plot(pls1x,pls1y,asp=0.01,
     col=clrs,
     pch=16,cex=2,
     xlab="shape",ylab="asymmetry",main="PLS 1")
abline(a=0,b=0,h=0,v=0, lwd=1, col="gray")
text(pls1x,pls1y,labels = sort(unique(otu)),
     cex=0.8, font = 4, offset = 0.5,pos=1)

#Plot PLS2
plot(pls2x,pls2y,asp=0.01,
     col=clrs,
     pch=16,cex=2,
     xlab="shape",ylab="asymmetry",main="PLS 2")
abline(a=0,b=0,h=0,v=0, lwd=1, col="gray")
text(pls2x,pls2y,labels = sort(unique(otu)),
     cex=0.8, font = 4, offset = 0.5,pos=1)

#PLS - shape variations
plsEffects_1 <- plsCoVar(pls,i=1,sdx = 3,sdy = 3)
plsEffects_2 <- plsCoVar(pls,i=2,sdx = 3,sdy = 3)
negshape1<-plsEffects_1$x[,,1]
posshape1<-plsEffects_1$x[,,2]
negshape2<-plsEffects_2$x[,,1]
posshape2<-plsEffects_2$x[,,2]

neg1_R<-negshape1[1:500,]
neg1_L<-negshape1[501:1000,]
neg1_opa<-rotonto(neg1_R,neg1_L,scale=TRUE)
negm1_R<-tri
negm1_L<-tri
negm1_R$vb[1:3,]<-t(neg1_opa$X)
negm1_L$vb[1:3,]<-t(neg1_opa$Y)

pos1_R<-posshape1[1:500,]
pos1_L<-posshape1[501:1000,]
pos1_opa<-rotonto(pos1_R,pos1_L,scale=TRUE)
posm1_R<-tri
posm1_L<-tri
posm1_R$vb[1:3,]<-t(pos1_opa$X)
posm1_L$vb[1:3,]<-t(pos1_opa$Y)

neg2_R<-negshape2[1:500,]
neg2_L<-negshape2[501:1000,]
neg2_opa<-rotonto(neg2_R,neg2_L,scale=TRUE)
negm2_R<-tri
negm2_L<-tri
negm2_R$vb[1:3,]<-t(neg2_opa$X)
negm2_L$vb[1:3,]<-t(neg2_opa$Y)

pos2_R<-posshape2[1:500,]
pos2_L<-posshape2[501:1000,]
pos2_opa<-rotonto(pos2_R,pos2_L,scale=TRUE)
posm2_R<-tri
posm2_L<-tri
posm2_R$vb[1:3,]<-t(pos2_opa$X)
posm2_L$vb[1:3,]<-t(pos2_opa$Y)

#Shape variation at negative values PLS1
open3d()
localmeshdiff(negm1_R,negm1_L,ploton = 1,out.rem = TRUE,from=NULL,to=NULL,
              paltot = c("red","orange","white","lightblue","blue"))
wire3d(negm1_R,col="red",lwd=2)
wire3d(negm1_L,col="green",lwd=2)

#Shape variation at positive values PLS1
open3d()
localmeshdiff(posm1_R,posm1_L,ploton = 1,out.rem = TRUE,from=NULL,to=NULL,
              paltot = c("red","orange","white","lightblue","blue"))
wire3d(posm1_R,col="red",lwd=2)
wire3d(posm1_L,col="green",lwd=2)

#Shape variation at negative values PLS2
open3d()
localmeshdiff(negm2_R,negm2_L,ploton = 1,out.rem = TRUE,from=NULL,to=NULL,
              paltot = c("red","orange","white","lightblue","blue"))
wire3d(negm2_R,col="red",lwd=2)
wire3d(negm2_L,col="green",lwd=2)

#Shape variation at positive values PLS2
open3d()
localmeshdiff(posm2_R,posm2_L,ploton = 1,out.rem = TRUE,from=NULL,to=NULL,
              paltot = c("red","orange","white","lightblue","blue"))
wire3d(posm2_R,col="red",lwd=2)
wire3d(posm2_L,col="green",lwd=2)

#Calculation vector centroid sizes
sizes<-apply(sets,3,cSize)
names(sizes)<-str_sub(names(sizes),1,4)

#Boxplot CS genus Homo
selh<-which(otu%in%c("HERE","HERG","HHEI","HNEA","HSAP"))
dx_size<-apply(sets[1:500,,selh],3,cSize)
sx_size<-apply(sets[501:1000,,selh],3,cSize)
t.test(sx_size, dx_size, paired = TRUE, alternative = "two.sided")
(mean(sx_size)/mean(dx_size))*100
boxplot(dx_size,sx_size,names=c("Right hemisphere","Left hemisphere"),main="Centroid Size (genus Homo)")
myjitter <- jitter(rep(1,length(dx_size)),factor=2)
points(myjitter, dx_size, pch=20,col=cols[selh],cex=1.5) 
myjitter <- jitter(rep(2,length(sx_size)),factor=2)
points(myjitter, sx_size, pch=20,col=cols[selh],cex=1.5) 

#Boxplot CS Great Apes plus A. africanus
selnh<-which(otu%in%c("AAFR","GBER","GGOR","PABE","PANT"))
dx_size<-apply(shape[1:500,,selnh],3,cSize)
sx_size<-apply(shape[501:1000,,selnh],3,cSize)
t.test(sx_size, dx_size, paired = TRUE, alternative = "two.sided")
(mean(sx_size)/mean(dx_size))*100
boxplot(dx_size,sx_size,names=c("Right hemisphere","Left hemisphere"),main="Centroid Size (Great Apes + Sts5)")
myjitter <- jitter(rep(1,length(dx_size)),factor=2)
points(myjitter, dx_size, pch=20,col=cols[selnh],cex=1.5) 
myjitter <- jitter(rep(2,length(sx_size)),factor=2)
points(myjitter, sx_size, pch=20,col=cols[selnh],cex=1.5) 

#Boxplot CS Lesser Apes
selhy<-which(otu%in%c("HAGI","HKLO","HLAR","HMUE","HOOH",
                      "HPIL","NOMC","NOML","SYMP"))
dx_size<-apply(shape[1:500,,selhy],3,cSize)
sx_size<-apply(shape[501:1000,,selhy],3,cSize)
t.test(sx_size, dx_size, paired = TRUE, alternative = "two.sided")
(mean(sx_size)/mean(dx_size))*100
boxplot(dx_size,sx_size,names=c("Right hemisphere","Left hemisphere"),main="Centroid Size (Lesser Apes)")
myjitter <- jitter(rep(1,length(dx_size)),factor=2)
points(myjitter, dx_size, pch=20,col=cols[selhy],cex=1.5) 
myjitter <- jitter(rep(2,length(sx_size)),factor=2)
points(myjitter, sx_size, pch=20,col=cols[selhy],cex=1.5) 









