library(ggplot2)
library(car)
library(ape)
library(caper)
library(geiger)
library(phytools)
library(glue)
library(ggrepel)
library(patchwork)
library(smatr)

##########################PI T TEST ###################
donnee<-read.csv("IPGeneral.csv",sep=";",dec=",",stringsAsFactors = T)

t1 <- t.test(donnee$IPHand25, donnee$IPHand2and5, paired = TRUE)
t2 <- t.test(donnee$IPHand25, donnee$IPHand3and4, paired = TRUE)
t3 <- t.test(donnee$IPHand2and5, donnee$IPHand3and4, paired = TRUE)

cat("IPHand25 vs IPHand2and5: t =", t1$statistic, ", p =", t1$p.value, "\n")
cat("IPHand25 vs IPHand3and4: t =", t2$statistic, ", p =", t2$p.value, "\n")
cat("IPHand2and5 vs IPHand3and4: t =", t3$statistic, ", p =", t3$p.value, "\n")

p_values <- c(t1$p.value, t2$p.value, t3$p.value)
p.adjust(p_values, method = "holm")

t1 <- t.test(donnee$IPFoot25, donnee$IPFoot2and5, paired = TRUE)
t2 <- t.test(donnee$IPFoot25, donnee$IPFoot3and4, paired = TRUE)
t3 <- t.test(donnee$IPFoot2and5, donnee$IPFoot3and4, paired = TRUE)

cat("IPFoot25 vs IPFoot2and5: t =", t1$statistic, ", p =", t1$p.value, "\n")
cat("IPFoot25 vs IPFoot3and4: t =", t2$statistic, ", p =", t2$p.value, "\n")
cat("IPFoot2and5 vs IPFoot3and4: t =", t3$statistic, ", p =", t3$p.value, "\n")

p_values <- c(t1$p.value, t2$p.value, t3$p.value)
p.adjust(p_values, method = "holm")


#####################contMap###############
donnee<-read.csv("statiph34.csv",sep=";",dec=",",stringsAsFactors = T)
arbre7 <- read.tree("speciesiph25206.nwk")
write.nexus(arbre7, file = "arbre7.nex")
plot(arbre7)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species
donnee1<-donnee[match(arbre7$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre7$tip.label)
name.check(arbre7,donnee1)

species_to_group <- setNames(donnee1$Group, donnee1$Species)
group_levels <- unique(donnee1$Group)
group_colors <- setNames(rainbow(length(group_levels)), group_levels)
tip_colors <- group_colors[species_to_group[arbre7$tip.label]]
plot.phylo(arbre7,
           type = "fan",
           tip.color = tip_colors,
           cex = 0.7,
           edge.width = 1.2,
           no.margin = TRUE)


rownames(donnee1)
ln.ip_inverted <- setNames(-donnee1$IPHand3and4, rownames(donnee1))
mammal.contMap <- contMap(arbre7, ln.ip_inverted, plot = FALSE, res = 200)
plot(mammal.contMap,
     type = "fan",
     fsize = c(0.45, 0.35),
     lwd = 2,
     outline = TRUE,
     ftype = "i",
     no.margin = TRUE)

donnee<-read.csv("statipf34.csv",sep=";",dec=",",stringsAsFactors = T)
arbre9 <- read.tree("speciesipf25206.nwk")
write.nexus(arbre9, file = "arbre9.nex")
plot(arbre9)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre9$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre9$tip.label)
name.check(arbre9,donnee1)

species_to_group <- setNames(donnee1$Group, donnee1$Species)
group_levels <- unique(donnee1$Group)
group_colors <- setNames(rainbow(length(group_levels)), group_levels)
tip_colors <- group_colors[species_to_group[arbre9$tip.label]]
plot.phylo(arbre9,
           type = "fan",
           tip.color = tip_colors,
           cex = 0.7,
           edge.width = 1.2,
           no.margin = TRUE)


rownames(donnee1)
ln.ip_inverted <- setNames(-donnee1$IPFoot3and4, rownames(donnee1))
mammal.contMap <- contMap(arbre9, ln.ip_inverted, plot = FALSE, res = 200)
plot(mammal.contMap,
     type = "fan",
     fsize = c(0.45, 0.35),
     lwd = 2,
     outline = TRUE,
     ftype = "i",
     no.margin = TRUE)

donnee<-read.csv("stat34ipf1.csv",sep=";",dec=",",stringsAsFactors = T)
arbre10 <- read.tree("speciesipf1206.nwk")
write.nexus(arbre10, file = "arbre10.nex")
plot(arbre10)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre10$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre10$tip.label)
name.check(arbre10,donnee1)

species_to_group <- setNames(donnee1$Group, donnee1$Species)
group_levels <- unique(donnee1$Group)
group_colors <- setNames(rainbow(length(group_levels)), group_levels)
tip_colors <- group_colors[species_to_group[arbre10$tip.label]]
plot.phylo(arbre10,
           type = "fan",
           tip.color = tip_colors,
           cex = 0.7,
           edge.width = 1.2,
           no.margin = TRUE)


rownames(donnee1)
ln.ip_inverted <- setNames(-donnee1$IPFoot1, rownames(donnee1))
mammal.contMap <- contMap(arbre10, ln.ip_inverted, plot = FALSE, res = 200)
plot(mammal.contMap,
     type = "fan",
     fsize = c(0.45, 0.35),
     lwd = 2,
     outline = TRUE,
     ftype = "i",
     no.margin = TRUE)

donnee<-read.csv("stat34iph1.csv",sep=";",dec=",",stringsAsFactors = T)
arbre8 <- read.tree("speciesiph1206.nwk")
write.nexus(arbre8, file = "arbre8.nex")
plot(arbre8)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre8$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre8$tip.label)
name.check(arbre8,donnee1)

species_to_group <- setNames(donnee1$Group, donnee1$Species)
group_levels <- unique(donnee1$Group)
group_colors <- setNames(rainbow(length(group_levels)), group_levels)
tip_colors <- group_colors[species_to_group[arbre8$tip.label]]
plot.phylo(arbre8,
           type = "fan",
           tip.color = tip_colors,
           cex = 0.7,
           edge.width = 1.2,
           no.margin = TRUE)


rownames(donnee1)
ln.ip_inverted <- setNames(-donnee1$IPHand1, rownames(donnee1))
mammal.contMap <- contMap(arbre8, ln.ip_inverted, plot = FALSE, res = 200)
plot(mammal.contMap,
     type = "fan",
     fsize = c(0.45, 0.35),
     lwd = 2,
     outline = TRUE,
     ftype = "i",
     no.margin = TRUE)


############################Blomberg####################
donnee<-read.csv("statip34.csv",sep=";",dec=",",stringsAsFactors = T)
arbre <- read.tree("species.nwk")
write.nexus(arbre, file = "arbre.nex")
plot(arbre)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre$tip.label)
name.check(arbre,donnee1)

phylosig(arbre,donnee1$IPHand3and4log10,test=TRUE,method="K") 
phylosig(arbre,donnee1$IPHand1log10,test=TRUE,method="K") 
phylosig(arbre,donnee1$IPFoot3and4log10,test=TRUE,method="K")
phylosig(arbre,donnee1$IPFoot1log10,test=TRUE,method="K")


########## PGLS ############
############GENERAL################
donnee<-read.csv("statip34.csv",sep=";",dec=",",stringsAsFactors = T)
arbre <- read.tree("species.nwk")
write.nexus(arbre, file = "arbre.nex")
plot(arbre)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre$tip.label)
name.check(arbre,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie, data=model, lambda="ML")
summary(model1a)
coef_pgls <- coef(model1a)
intercept <- coef_pgls[1]
slope <- coef_pgls[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept, slope = slope, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
coef_pgls1 <- coef(model11a)
intercept1 <- coef_pgls1[1]
slope1 <- coef_pgls1[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept1, slope = slope1, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
coef_pgls2 <- coef(model12a)
intercept2 <- coef_pgls2[1]
slope2 <- coef_pgls2[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept2, slope = slope2, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(y = "IPFoot3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model13a)
coef_pgls3 <- coef(model13a)
intercept3 <- coef_pgls3[1]
slope3 <- coef_pgls3[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept3, slope = slope3, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot1log10 et TpsArboricolie",
       y = "IPFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4a<-pgls( IPHand3and4log10 ~ Bodymasslog10, data=model, lambda="ML")
summary(model4a)
arbre1 <- read.tree("speciesiph25.nwk")
write.nexus(arbre1, file = "arbre1.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre1,data_clean)
dev.off()
plot(arbre1, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre1,183,"Marsupial") 
painted3<-paintSubTree(painted3,205,"Carnivora")
painted3<-paintSubTree(painted3,203,"Pholidota")
painted3<-paintSubTree(painted3,251,"Rodentia")
painted3<-paintSubTree(painted3,282,"Dermoptera")
painted3<-paintSubTree(painted3,356,"Scandentia")
painted3<-paintSubTree(painted3,360,"Procavidae")
painted3<-paintSubTree(painted3,361,"Folivora")
painted3<-paintSubTree(painted3,283,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Folivora" = "#93AA00",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Procavidae" = "#619CFF",
  "Rodentia" = "#DB72FB",   
  "Scandentia" = "#FF61C3"   
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model4a, col = "darkgrey", lwd = 3, lty = 2)
text(x=2.3, y= 0.075, "PGLS", col="darkgrey") 
legend("topright", legend=c("Carnivora", "Dermoptera", "Folivora","Marsupial", "Pholidota","Primate","Procavidae" ,"Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200","#93AA00", "#00BA38", "#00C19F","#00B9E3","#619CFF","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre2 <- read.tree("speciesiph1.nwk")
write.nexus(arbre2, file = "arbre2.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre2,data_clean)
dev.off()
plot(arbre2, cex = 0.6)       
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre2,147,"Marsupial")
painted3<-paintSubTree(painted3,168,"Carnivora")
painted3<-paintSubTree(painted3,166,"Pholidota")
painted3<-paintSubTree(painted3,214,"Rodentia")
painted3<-paintSubTree(painted3,219,"Dermoptera")
painted3<-paintSubTree(painted3,287,"Scandentia")
painted3<-paintSubTree(painted3,220,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3"  
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model41a, col = "darkgrey", lwd = 3, lty = 2)
text(x=2.5, y= -0.1, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Carnivora", "Dermoptera", "Marsupial", "Pholidota","Primate","Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200", "#00BA38", "#00C19F","#00B9E3","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre3 <- read.tree("speciesipf25.nwk")
write.nexus(arbre3, file = "arbre3.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre3,data_clean)
dev.off()
plot(arbre3, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre3,182,"Marsupial") 
painted3<-paintSubTree(painted3,202,"Carnivora")
painted3<-paintSubTree(painted3,200,"Pholidota")
painted3<-paintSubTree(painted3,249,"Rodentia")
painted3<-paintSubTree(painted3,280,"Dermoptera")
painted3<-paintSubTree(painted3,354,"Scandentia")
painted3<-paintSubTree(painted3,281,"Primate")
painted3<-paintSubTree(painted3,358,"Procavidae")
painted3<-paintSubTree(painted3,359,"Folivora")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3",   
  "Folivora" = "#93AA00",
  "Procavidae" = "#619CFF"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("topright", legend=c("Carnivora", "Dermoptera", "Marsupial", "Pholidota","Primate","Rodentia","Scandentia","Folivora","Procavidae"),  
       fill = c("#F8766D", "#D39200", "#00BA38", "#00C19F","#00B9E3","#DB72FB","#FF61C3","#93AA00","#619CFF"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre4 <- read.tree("speciesipf1.nwk")
write.nexus(arbre4, file = "arbre4.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre4,data_clean)
dev.off()
plot(arbre4, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre4,161,"Marsupial")
painted3<-paintSubTree(painted3,178,"Carnivora")
painted3<-paintSubTree(painted3,176,"Pholidota")
painted3<-paintSubTree(painted3,211,"Rodentia")
painted3<-paintSubTree(painted3,242,"Dermoptera")
painted3<-paintSubTree(painted3,315,"Scandentia")
painted3<-paintSubTree(painted3,243,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3"   
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("topright", legend=c("Carnivora", "Dermoptera", "Marsupial", "Pholidota","Primate","Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200", "#00BA38", "#00C19F","#00B9E3","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4a),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

################PRIMATES########################
donnee<-read.csv("statip34primates.csv",sep=";",dec=",",stringsAsFactors = T)
arbre11 <- read.tree("speciesprimates.nwk")
write.nexus(arbre11, file = "arbre11.nex")
plot(arbre11)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species
donnee1<-donnee[match(arbre11$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre11$tip.label)
name.check(arbre11,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre11, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
coef_pgls4 <- coef(model1a)
intercept4 <- coef_pgls4[1]
slope4 <- coef_pgls4[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept4, slope = slope4, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
coef_pgls5 <- coef(model11a)
intercept5 <- coef_pgls5[1]
slope5 <- coef_pgls5[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept5, slope = slope5, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
coef_pgls6 <- coef(model12a)
intercept6 <- coef_pgls6[1]
slope6 <- coef_pgls6[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept6, slope = slope6, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(y = "IPFoot3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(y = "IPFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4aP<-pgls(IPHand3and4log10 ~  Bodymasslog10, data=model, lambda="ML")
summary(model4aP)
arbre31 <- read.tree("primatesiph25.nwk")
write.nexus(arbre31, file = "arbre31.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre31,data_clean)
dev.off()
plot(arbre31, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre31,75,"Primates")
mes_couleurs <- c(
  "1" = "black",
  "Primates" = "#00B9E3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model4aP, col = "darkgrey", lwd = 3, lty = 2)
text(x=2, y= 0.2, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Primates"),  
       fill = c("#00B9E3"), bty= "n", text.font=2,cex=0.58)

model41aP<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41aP)
arbre32 <- read.tree("primatesiph1.nwk")
write.nexus(arbre32, file = "arbre32.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre32,data_clean)
dev.off()
plot(arbre32, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre32,69,"Primates")
mes_couleurs <- c(
  "1" = "black",
  "Primates" = "#00B9E3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model41aP, col = "darkgrey", lwd = 3, lty = 2)
text(x=2, y= 0, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Primates"),  
       fill = c("#00B9E3"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre34 <- read.tree("primatesipf25.nwk")
write.nexus(arbre34, file = "arbre34.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre34,data_clean)
dev.off()
plot(arbre34, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre34,75,"Primates")
mes_couleurs <- c(
  "1" = "black",
  "Primates" = "#00B9E3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Primates"),  
       fill = c("#00B9E3"), bty= "n", text.font=2,cex=0.58)

model43aP<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43aP)
arbre33 <- read.tree("primatesipf1.nwk")
write.nexus(arbre33, file = "arbre33.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre33,data_clean)
dev.off()
plot(arbre33, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre33,74,"Primates")
mes_couleurs <- c(
  "1" = "black",
  "Primates" = "#00B9E3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model43aP, col = "darkgrey", lwd = 3, lty = 2)
text(x=2, y= -0.35, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Primates"),  
       fill = c("#00B9E3"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4aP),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43aP),
  IPHand1log = extract_pvalue(model41aP)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

###################CARNIVORES#####################
donnee<-read.csv("statip34carnivora.csv",sep=";",dec=",",stringsAsFactors = T)
arbre13 <- read.tree("speciescarnivora.nwk")
write.nexus(arbre13, file = "arbre13.nex")
plot(arbre13)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species
donnee1<-donnee[match(arbre13$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre13$tip.label)
name.check(arbre13,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre13, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
coef_pgls7 <- coef(model1a)
intercept7 <- coef_pgls7[1]
slope7 <- coef_pgls7[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept7, slope = slope7, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
coef_pgls8 <- coef(model11a)
intercept8 <- coef_pgls8[1]
slope8 <- coef_pgls8[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept8, slope = slope8, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
coef_pgls9 <- coef(model12a)
intercept9 <- coef_pgls9[1]
slope9 <- coef_pgls9[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept9, slope = slope9, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(y = "IPFoot3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
coef_pgls10 <- coef(model13a)
intercept10 <- coef_pgls10[1]
slope10 <- coef_pgls10[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept10, slope = slope10, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IDFoot1log10 et TpsArboricolie",
       y = "IDFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4aC<-pgls( IPHand3and4log10 ~ Bodymasslog10, data=model, lambda="ML")
summary(model4aC)
arbre27 <- read.tree("carnivoraiph25.nwk")
write.nexus(arbre27, file = "arbre27.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre27,data_clean)
dev.off()
plot(arbre27, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre27,47,"Carnivora")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model4aC, col = "darkgrey", lwd = 3, lty = 2)
text(x=2.5, y= -0.1, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Carnivora"),  
       fill = c("#F8766D"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre28 <- read.tree("carnivoraiph1.nwk")
write.nexus(arbre28, file = "arbre28.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre28,data_clean)
dev.off()
plot(arbre28, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre28,47,"Carnivora")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Carnivora"),  
       fill = c("#F8766D"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre29 <- read.tree("carnivoraipf25.nwk")
write.nexus(arbre29, file = "arbre29.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre29,data_clean)
dev.off()
plot(arbre29, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre29,48,"Carnivora")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Carnivora"),  
       fill = c("#F8766D"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre30 <- read.tree("carnivoraipf1.nwk")
write.nexus(arbre30, file = "arbre30.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre30,data_clean)
dev.off()
plot(arbre30, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre30,34,"Carnivora")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Carnivora"),  
       fill = c("#F8766D"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4aC),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

####################MARSUPIAL####################
donnee<-read.csv("statip34marsupial.csv",sep=";",dec=",",stringsAsFactors = T)
arbre14 <- read.tree("speciesmarsupial.nwk")
write.nexus(arbre14, file = "arbre14.nex")
plot(arbre14)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre14$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre14$tip.label)
name.check(arbre14,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre14, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
coef_pgls11 <- coef(model1a)
intercept11 <- coef_pgls11[1]
slope11 <- coef_pgls11[2]
ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept11, slope = slope11, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
coef_pgls12 <- coef(model11a)
intercept12 <- coef_pgls12[1]
slope12 <- coef_pgls12[2]
ggplot(donnee1, aes(x = TpsArboricolie, y =  IPHand1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept12, slope = slope12, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
ggplot(donnee1, aes(x = TpsArboricolie, y =  IPFoot3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot3and4log10 et TpsArboricolie",
       y = "IPFoot3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))


model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
ggplot(donnee1, aes(x = TpsArboricolie, y =  IPFoot1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot1log10 et TpsArboricolie",
       y = "IPFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4a<-pgls(IPHand3and4log10  ~ Bodymasslog10, data=model, lambda="ML")
summary(model4a)
arbre23 <- read.tree("marsupialiph25.nwk")
write.nexus(arbre23, file = "arbre23.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre23,data_clean)
dev.off()
plot(arbre23, cex = 0.6)        
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre23,19,"Marsupials")
mes_couleurs <- c(
  "1" = "black",
  "Marsupials" = "#00BA38"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Marsupial"),  
       fill = c("#00BA38"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre24 <- read.tree("marsupialiph1.nwk")
write.nexus(arbre24, file = "arbre24.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre24,data_clean)
dev.off()
plot(arbre24, cex = 0.6)        
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre24,19,"Rodentia")
mes_couleurs <- c(
  "1" = "black",
  "Rodentia" = "#00BA38"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Marsupial"),  
       fill = c("#00BA38"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre25 <- read.tree("marsupialipf25.nwk")
write.nexus(arbre25, file = "arbre25.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre25,data_clean)
dev.off()
plot(arbre25, cex = 0.6)        
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre25,17,"Marsupial")
mes_couleurs <- c(
  "1" = "black",
  "Marsupial" = "#00BA38"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Marsupial"),  
       fill = c("#00BA38"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre26 <- read.tree("marsupialipf1.nwk")
write.nexus(arbre26, file = "arbre26.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre26,data_clean)
dev.off()
plot(arbre26, cex = 0.6)       
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre26,15,"Marsupial")
mes_couleurs <- c(
  "1" = "black",
  "Marsupial" = "#00BA38"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Marsupial"),  
       fill = c("#00BA38"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4a),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

#####################RODENTS###################
donnee<-read.csv("statip34rodentia.csv",sep=";",dec=",",stringsAsFactors = T)
arbre16 <- read.tree("speciesrodentia.nwk")
write.nexus(arbre16, file = "arbre16.nex")
plot(arbre16)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre16$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre16$tip.label)
name.check(arbre16,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre16, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot3and4log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot3and4log10  et TpsArboricolie",
       y = "IPFoot3and4log10 ",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
coef_pgls13 <- coef(model13a)
intercept13 <- coef_pgls13[1]
slope13 <- coef_pgls13[2]
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept13, slope = slope13, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IDFoot1log10 et TpsArboricolie",
       y = "IDFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4aR<-pgls(IPHand3and4log10  ~ Bodymasslog10, data=model, lambda="ML")
summary(model4aR)
arbre19 <- read.tree("rodentiaiph25.nwk")
write.nexus(arbre19, file = "arbre19.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre19,data_clean)
dev.off()
plot(arbre19, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre19,31,"Rodentia")
mes_couleurs <- c(
  "1" = "black",
  "Rodentia" = "#DB72FB"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Rodentia"),  
       fill = c("#DB72FB"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre20 <- read.tree("rodentiaiph1.nwk")
write.nexus(arbre20, file = "arbre20.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre20,data_clean)
dev.off()
plot(arbre20, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre20,5,"Rodentia")
mes_couleurs <- c(
  "1" = "black",
  "Rodentia" = "#DB72FB"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Rodentia"),  
       fill = c("#DB72FB"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre21 <- read.tree("rodentiaipf25.nwk")
write.nexus(arbre21, file = "arbre21.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre21,data_clean)
dev.off()
plot(arbre21, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre21,31,"Rodentia")
mes_couleurs <- c(
  "1" = "black",
  "Rodentia" = "#DB72FB"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Rodentia"),  
       fill = c("#DB72FB"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre22 <- read.tree("rodentiaipf1.nwk")
write.nexus(arbre22, file = "arbre22.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre22,data_clean)
dev.off()
plot(arbre22, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre22,31,"Rodentia")
mes_couleurs <- c(
  "1" = "black",
  "Rodentia" = "#DB72FB"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IDPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Rodentia"),  
       fill = c("#DB72FB"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4aR),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

####################SCANDENTIA####################
donnee<-read.csv("statip34scandentia.csv",sep=";",dec=",",stringsAsFactors = T)
arbre35 <- read.tree("speciesscandentia.nwk")
write.nexus(arbre35, file = "arbre35.nex")
plot(arbre35)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre35$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre35$tip.label)
name.check(arbre35,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre35, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot3and4log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot3and4log10  et TpsArboricolie",
       y = "IPFoot3and4log10 ",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IDFoot1log10 et TpsArboricolie",
       y = "IDFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4a<-pgls(IPHand3and4log10  ~ Bodymasslog10, data=model, lambda="ML")
summary(model4a)
arbre35 <- read.tree("speciesscandentia.nwk")
write.nexus(arbre35, file = "arbre35.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre35,data_clean)
dev.off()
plot(arbre35, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre35,5,"Scandentia")
mes_couleurs <- c(
  "1" = "black",
  "Scandentia" = "#FF61C3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Scandentia"),  
       fill = c("#FF61C3"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre35 <- read.tree("speciesscandentia.nwk")
write.nexus(arbre35, file = "arbre35.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre35,data_clean)
dev.off()
plot(arbre35, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre35,5,"Scandentia")
mes_couleurs <- c(
  "1" = "black",
  "Scandentia" = "#FF61C3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Scandentia"),  
       fill = c("#FF61C3"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre35 <- read.tree("speciesscandentia.nwk")
write.nexus(arbre35, file = "arbre35.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre35,data_clean)
dev.off()
plot(arbre35, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre35,5,"Scandentia")
mes_couleurs <- c(
  "1" = "black",
  "Scandentia" = "#FF61C3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Scandentia"),  
       fill = c("#FF61C3"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre35 <- read.tree("speciesscandentia.nwk")
write.nexus(arbre35, file = "arbre35.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre35,data_clean)
dev.off()
plot(arbre35, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre35,5,"Scandentia")
mes_couleurs <- c(
  "1" = "black",
  "Scandentia" = "#FF61C3"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IDPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Scandentia"),  
       fill = c("#FF61C3"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4a),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

#######################PHOLIDOTA################
donnee<-read.csv("statip34pholidota.csv",sep=";",dec=",",stringsAsFactors = T)
arbre36 <- read.tree("speciespholidota.nwk")
write.nexus(arbre36, file = "arbre36.nex")
plot(arbre36)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre36$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre36$tip.label)
name.check(arbre36,donnee1)

rownames(donnee1) <- donnee1$Species
rownames(donnee1)
model <- comparative.data(arbre36, donnee1, names.col = Species, vcv = TRUE, vcv.dim = 3)

model1a<-pgls(IPHand3and4log10 ~ TpsArboricolie , data=model, lambda="ML")
summary(model1a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model11a<-pgls(IPHand1log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model11a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPHand1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model12a<-pgls(IPFoot3and4log10 ~ TpsArboricolie, data=model, lambda="ML") 
summary(model12a)
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot3and4log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  theme_minimal() +
  labs(title = "Relation entre IPFoot3and4log10  et TpsArboricolie",
       y = "IPFoot3and4log10 ",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

model13a<-pgls(IPFoot1log10 ~ TpsArboricolie , data=model, lambda="ML") 
summary(model13a)
coef_pgls13 <- coef(model13a)
intercept13 <- coef_pgls13[1]
slope13 <- coef_pgls13[2]
ggplot(donnee1, aes(x = TpsArboricolie , y = IPFoot1log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept13, slope = slope13, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IDFoot1log10 et TpsArboricolie",
       y = "IDFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model1a),
  IPFoot3and4log10 = extract_pvalue(model12a),
  IPFoot1log10 = extract_pvalue(model13a),
  IPHand1log = extract_pvalue(model11a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

model4a<-pgls(IPHand3and4log10  ~ Bodymasslog10, data=model, lambda="ML")
summary(model4a)
arbre36 <- read.tree("speciespholidota.nwk")
write.nexus(arbre36, file = "arbre36.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre36,data_clean)
dev.off()
plot(arbre36, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre36,4,"Pholidota")
mes_couleurs <- c(
  "1" = "black",
  "Pholidota" = "#00C19F"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Pholidota"),  
       fill = c("#00C19F"), bty= "n", text.font=2,cex=0.58)

model41a<-pgls(IPHand1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model41a)
arbre36 <- read.tree("speciespholidota.nwk")
write.nexus(arbre36, file = "arbre36.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre36,data_clean)
dev.off()
plot(arbre36, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre36,4,"Pholidota")
mes_couleurs <- c(
  "1" = "black",
  "Pholidota" = "#00C19F"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Pholidota"),  
       fill = c("#00C19F"), bty= "n", text.font=2,cex=0.58)

model42a<-pgls(IPFoot3and4log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model42a)
arbre36 <- read.tree("speciespholidota.nwk")
write.nexus(arbre36, file = "arbre36.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,10]), ]
name.check(arbre36,data_clean)
dev.off()
plot(arbre36, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre36,4,"Pholidota")
mes_couleurs <- c(
  "1" = "black",
  "Pholidota" = "#00C19F"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,10)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Pholidota"),  
       fill = c("#00C19F"), bty= "n", text.font=2,cex=0.58)

model43a<-pgls(IPFoot1log10 ~ Bodymasslog10, data=model, lambda="ML") 
summary(model43a)
arbre36 <- read.tree("speciespholidota.nwk")
write.nexus(arbre36, file = "arbre36.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre36,data_clean)
dev.off()
plot(arbre36, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre36,4,"Pholidota")
mes_couleurs <- c(
  "1" = "black",
  "Pholidota" = "#00C19F"
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IDPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
legend("bottomleft", legend=c("Pholidota"),  
       fill = c("#00C19F"), bty= "n", text.font=2,cex=0.58)

extract_pvalue <- function(model) {
  summary_model <- summary(model)
  pval <- summary_model$coefficients[2, "Pr(>|t|)"]
  return(pval)
}
p_values <- c(
  IPHand3and4log10 = extract_pvalue(model4a),
  IPFoot3and4log10 = extract_pvalue(model42a),
  IPFoot1log10 = extract_pvalue(model43a),
  IPHand1log = extract_pvalue(model41a)
)
p_values_table <- data.frame(
  Variable = names(p_values),
  P_value = unname(p_values)
)
print(p_values_table)
p.adjust(p_values_table[,"P_value"],method="holm")

#########PLOTS########################
donnee<-read.csv("statip34.csv",sep=";",dec=",",stringsAsFactors = T)
arbre <- read.tree("species.nwk")
write.nexus(arbre, file = "arbre.nex")
plot(arbre)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre$tip.label)
name.check(arbre,donnee1)

ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept, slope = slope, 
              color = "darkgrey", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept4, slope = slope4, 
              color = "#00B9E3", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept7, slope = slope7, 
              color = "#F8766D", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept11, slope = slope11, 
              color = "#00BA38", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand3and4log10 et TpsArboricolie",
       y = "IPHand3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))

ggplot(donnee1, aes(x = TpsArboricolie, y = IPHand1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept1, slope = slope1, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  geom_abline(intercept = intercept5, slope = slope5, 
              color = "#00B9E3", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept8, slope = slope8, 
              color = "#F8766D", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept12, slope = slope12, 
              color = "#00BA38", linetype = "dashed", size = 1.2) +
  theme_minimal() +
  labs(title = "Relation entre IPHand1log10 et TpsArboricolie",
       y = "IPHand1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))


ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot3and4log10)) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept2, slope = slope2, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  geom_abline(intercept = intercept6, slope = slope6, 
              color = "#00B9E3", linetype = "dashed", size = 1.2) + 
  geom_abline(intercept = intercept9, slope = slope9, 
              color = "#F8766D", linetype = "dashed", size = 1.2) + 
  theme_minimal() +
  labs(y = "IPFoot3and4log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))


ggplot(donnee1, aes(x = TpsArboricolie, y = IPFoot1log10 )) +
  geom_point(aes(color = Group), size = 2, alpha = 0.8) +
  geom_abline(intercept = intercept3, slope = slope3, 
              color = "darkgrey", linetype = "dashed", size = 1.2) +
  geom_abline(intercept = intercept10, slope = slope10, 
              color = "#F8766D", linetype = "dashed", size = 1.2) + 
  theme_minimal() +
  labs(title = "Relation entre IPFoot1log10 et TpsArboricolie",
       y = "IDFoot1log10",
       x = "Temps passé dans les arbres") +
  theme(axis.text.x = element_text(angle = 0))



arbre1 <- read.tree("speciesiph25.nwk")
write.nexus(arbre1, file = "arbre1.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,6]), ]
name.check(arbre1,data_clean)
dev.off()
plot(arbre1)
nodelabels()
plot(arbre1, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre1,183,"Marsupial")
painted3<-paintSubTree(painted3,205,"Carnivora")
painted3<-paintSubTree(painted3,203,"Pholidota")
painted3<-paintSubTree(painted3,251,"Rodentia")
painted3<-paintSubTree(painted3,282,"Dermoptera")
painted3<-paintSubTree(painted3,356,"Scandentia")
painted3<-paintSubTree(painted3,360,"Procavidae")
painted3<-paintSubTree(painted3,361,"Folivora")
painted3<-paintSubTree(painted3,283,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Folivora" = "#93AA00",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Procavidae" = "#619CFF",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3"   
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,6)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand3and4log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model4a, col = "darkgrey", lwd = 3, lty = 2)
abline(model4aP, col = "#00B9E3", lwd = 3, lty = 2)
text(x=2, y= 0.1, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Carnivora", "Dermoptera", "Folivora","Marsupial", "Pholidota","Primate","Procavidae" ,"Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200","#93AA00", "#00BA38", "#00C19F","#00B9E3","#619CFF","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)

arbre2 <- read.tree("speciesiph1.nwk")
write.nexus(arbre2, file = "arbre2.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,8]), ]
name.check(arbre2,data_clean)
dev.off()
plot(arbre2)
nodelabels()
plot(arbre2, cex = 0.6)          
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre2,147,"Marsupial") 
painted3<-paintSubTree(painted3,168,"Carnivora")
painted3<-paintSubTree(painted3,166,"Pholidota")
painted3<-paintSubTree(painted3,214,"Rodentia")
painted3<-paintSubTree(painted3,219,"Dermoptera")
painted3<-paintSubTree(painted3,287,"Scandentia")
painted3<-paintSubTree(painted3,220,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3"   
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,8)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPHand1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model41a, col = "darkgrey", lwd = 3, lty = 2)
abline(model41aP, col = "#00B9E3", lwd = 3, lty = 2)
text(x=2.5, y= -0.1, "PGLS", col="darkgrey") 
legend("bottomleft", legend=c("Carnivora", "Dermoptera", "Marsupial", "Pholidota","Primate","Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200", "#00BA38", "#00C19F","#00B9E3","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)

arbre4 <- read.tree("speciesipf1.nwk")
write.nexus(arbre4, file = "arbre4.nex")
data_clean <- donnee1[is.finite(donnee1[,14]) & is.finite(donnee1[,12]), ]
name.check(arbre4,data_clean)
dev.off()
plot(arbre4, cex = 0.6)         
nodelabels(cex = 0.6, frame = "circle", bg = "lightblue")
painted3<-paintSubTree(arbre4,161,"Marsupial") 
painted3<-paintSubTree(painted3,178,"Carnivora")
painted3<-paintSubTree(painted3,176,"Pholidota")
painted3<-paintSubTree(painted3,211,"Rodentia")
painted3<-paintSubTree(painted3,242,"Dermoptera")
painted3<-paintSubTree(painted3,315,"Scandentia")
painted3<-paintSubTree(painted3,243,"Primate")
mes_couleurs <- c(
  "1" = "black",
  "Carnivora" = "#F8766D",
  "Dermoptera" = "#D39200",
  "Marsupial" = "#00BA38",
  "Pholidota" = "#00C19F",
  "Primate" = "#00B9E3",
  "Rodentia" = "#DB72FB",    
  "Scandentia" = "#FF61C3"   
)
plot(painted3, ftype="off", lwd=4, colors=mes_couleurs)
par(mar = c(5, 5, 1, 1))
phyloplot<-phylomorphospace(painted3,data_clean[,c(14,12)],bty="l",ftype="off",node.by.map=TRUE,
                            node.size=c(0,1.2),xlab="Body Mass",ylab="IPFoot1log10",node.by.map=TRUE,asp=1,colors=mes_couleurs)
abline(model43aP, col = "#00B9E3", lwd = 3, lty = 2)
text(x=2, y= -0.4, "PGLS", col="#00B9E3") 
legend("topright", legend=c("Carnivora", "Dermoptera", "Marsupial", "Pholidota","Primate","Rodentia","Scandentia"),  
       fill = c("#F8766D", "#D39200", "#00BA38", "#00C19F","#00B9E3","#DB72FB","#FF61C3"), bty= "n", text.font=2,cex=0.58)


##########################Fossils################
fossiles<-read.csv("statfossiles.csv",sep=";",dec=",",stringsAsFactors = T)
donnee<-read.csv("statip34.csv",sep=";",dec=",",stringsAsFactors = T)
donnee$TpsArboricolie_logit = logit(p=donnee$TpsArboricolie)
arbre <- read.tree("species.nwk")
write.nexus(arbre, file = "arbre.nex")
plot(arbre)
donnee$Species <- gsub(" ", "_",donnee$Species)

rownames(donnee)<-donnee$Species 
donnee1<-donnee[match(arbre$tip.label,rownames(donnee)),]
all(rownames(donnee1) == arbre$tip.label)
name.check(arbre,donnee1)
rownames(donnee1) <- donnee1$Species
rownames(donnee1)
 
fit_sma <- function(compdata, 
                    response_var, 
                    predictor_var, 
                    newdata, 
                    use_logit = TRUE,
                    response_var_natural = NULL,
                    newdata_annotation_col = NULL,
                    plot_transposed = TRUE) {
  
  form    <- as.formula(glue("{response_var} ~ {predictor_var}"))
  mod_sma <- sma(form, data = compdata)
  b       <- coef(mod_sma)
  
  res_y    <- residuals(mod_sma)
  sd_res_y <- sd(res_y, na.rm = TRUE)
  
  valid      <- !is.na(newdata[[predictor_var]])
  X          <- as.matrix(newdata[valid, predictor_var])
  fit_logit  <- b[1] + b[2] * X

  if (use_logit) {
    fit_y <- plogis(fit_logit) * 100
    lwr_y <- plogis(fit_logit - sd_res_y) * 100
    upr_y <- plogis(fit_logit + sd_res_y) * 100
  } else {
    fit_y <- fit_logit
    lwr_y <- fit_logit - sd_res_y
    upr_y <- fit_logit + sd_res_y
  }
  
  pred_vals                    <- newdata
  pred_vals$fit                <- NA
  pred_vals$lwr_y              <- NA
  pred_vals$upr_y              <- NA
  pred_vals[valid, "fit"]      <- fit_y
  pred_vals[valid, "lwr_y"]    <- lwr_y
  pred_vals[valid, "upr_y"]    <- upr_y
  

  response_plot <- if (use_logit) {
    response_var_natural
  } else {
    response_var
  }
  if (plot_transposed) {
    fig <- ggplot(compdata, aes(y = .data[[predictor_var]], x= .data[[response_plot]])) +
      geom_point(alpha=0.3, shape = 16) +
      
      geom_point(data = pred_vals,
                 aes(y = .data[[predictor_var]], x = fit),
                 colour = "blue", 
                 inherit.aes = FALSE) +
      geom_ribbon(data = pred_vals,
                  aes(y = .data[[predictor_var]], x=fit, xmin = lwr_y, xmax = upr_y),
                  alpha = 0.2, fill="blue", inherit.aes = FALSE) +
      scale_x_continuous() +
      labs(y=predictor_var, x = response_plot,
           title = glue("SMA: {response_var} ~ {predictor_var}"))
    
    if (!is.null(newdata_annotation_col)) {
      fig <- fig +
        geom_text_repel(data = pred_vals,
                        aes(y = .data[[predictor_var]],
                            x = fit,
                            label = .data[[newdata_annotation_col]]),
                        size = 2.5, max.overlaps = Inf,
                        inherit.aes = FALSE)
    }
    
    
  }
  else {
    fig <- ggplot(compdata, aes(.data[[predictor_var]], .data[[response_plot]])) +
      geom_point(alpha=0.3, shape = 16) +
      
      geom_point(data = pred_vals,
                 aes(.data[[predictor_var]], y = fit),
                 colour = "blue", 
                 inherit.aes = FALSE) +
      geom_ribbon(data = pred_vals,
                  aes(y = .data[[predictor_var]], x=fit, xmin = lwr_y, xmax = upr_y),
                  alpha = 0.2, fill="blue", inherit.aes = FALSE) +
      scale_y_continuous() +
      labs(x=predictor_var, y = response_plot,
           title = glue("SMA: {response_var} ~ {predictor_var}"))
    
    if (!is.null(newdata_annotation_col)) {
      fig <- fig +
        geom_text_repel(data = pred_vals,
                        aes(x = .data[[predictor_var]],
                            y = fit,
                            label = .data[[newdata_annotation_col]]),
                        size = 2.5, max.overlaps = Inf,
                        inherit.aes = FALSE)
    }
  }
  
  list(
    model     = mod_sma,
    pred_vals = pred_vals,
    fig       = fig,
    formula   = form
  )
}

all_vars <- c("IPHand3and4log10", "IPFoot3and4log10", "IPFoot1log10","IPHand1log10")
plot_list <- list()
pred_vals_list <- list()
mod_list <- list()
formula_list <- list()
i=1
for (var in all_vars){
  sma_vals <- fit_sma(compdata = donnee1, 
                      response_var = "TpsArboricolie_logit", 
                      predictor_var = var, 
                      newdata = fossiles, 
                      use_logit = TRUE,
                      response_var_natural = "TpsArboricolie",
                      newdata_annotation_col = "Species",
                      plot_transposed = TRUE)
  plot_list[[i]] = sma_vals$fig
  pred_vals_list[[i]] = sma_vals$pred_vals
  mod_list[[i]] = sma_vals$model
  formula_list[[i]] = sma_vals$formula
  i=i+1
  write.csv(sma_vals$pred_vals, glue("pred_vals_SMA_{var}.csv"), row.names = FALSE)
}

fig <- wrap_plots(plot_list, ncol = 2)
show(fig)

for (i in c(1,2,3,4)){
  print(formula_list[[i]])
  print(summary(mod_list[[i]]))
  print("====================")
  print(" ")
}
p_values <- c(
  IPHand3and4log10 = mod_list[[1]][["pval"]],
  IPFoot3and4log10 = mod_list[[2]][["pval"]],
  IPFoot1log10 = mod_list[[3]][["pval"]],
  IPHand1log = mod_list[[4]][["pval"]]
)
p.adjust(p_values,method="holm")

