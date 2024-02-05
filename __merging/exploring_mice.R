

install.packages("mice")
install.packages("naniar")
install.packages("psych")

require(mice)
require(naniar)
require(psych)


best_data_wide$Species[which(is.na(best_data_wide$Cerebellum_N.n))]

multi.hist(best_data_wide[,sapply(best_data_wide, is.numeric)], global = F)
filtered = best_data_wide %>%
  +     select(where(~sum(is.na(.x))/length(.x) < 0.6))

filtered