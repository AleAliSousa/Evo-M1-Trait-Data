#!/usr/bin/env Rscript
# =============================================================================
# build_mammal_tree_augmented.R -- tree C: the DNA-only tree PLUS LOCALLY ADDED
# BRANCHES for living species that have no sequence data.
#
# THIS IS THE ONE BUILD IN THE REPO THAT PLACES SPECIES ITSELF. It exists as a
# deliberately separate, separately named product so that it can be compared
# with the other two and never mistaken for them:
#
#   A  _keys/mammal_tree.nwk               sequenced species only (canonical)
#   B  _keys/mammal_trees_sample100.nwk    Upham et al.'s own completed trees:
#                                          their imputation, 100 placements
#   C  _keys/mammal_tree_augmented.nwk     A + branches added here (this file)
#      _keys/mammal_trees_augmented100.nwk 100 randomised versions of C
#
# WHICH SPECIES ARE ADDED -- only names with positive evidence of being a valid
# living species that the DNA-only tree lacks:
#   upham_completed_no_dna    in Upham et al. 2019's 5,911-species taxonomy but
#                             not in their DNA-only tree
#   mdd_current_not_in_upham  a current, non-extinct Mammal Diversity Database
#                             species absent from Upham's taxonomy altogether
#                             (described or split after 2019)
# Never added: fossils, placeholders, names of unknown status, a second label
# for a species already on the tree, subspecies.
#
# WHERE THEY GO -- a taxonomic constraint, nothing else. No trait, no sequence.
#   genus has >= 2 sequenced species   deterministic tree: at the genus crown node
#                                      (a polytomy); randomised trees: a uniformly
#                                      random point on the branches below that node
#   genus has 1 sequenced species      deterministic: midpoint of that species'
#                                      terminal branch; randomised: uniform along it
#   genus has none                     the same two rules one rank up, on the family
#   family has none                    NOT PLACED; listed in the log
# An added species is never placed INSIDE another genus that is monophyletic on
# the backbone: the random walk over a constraint clade may land on the stem of
# such a genus but does not descend into it, and a family-level addition beside
# a lone sequenced relative goes above that relative's genus, not into it.
# This is the logic of phytools::add.species.to.genus (where = "root" / "random"),
# re-implemented on plain vectors because ~1,900 additions x 100 trees is too slow
# through bind.tip. The genus and family are the BACKBONE's own (Upham tip labels
# "Genus_species_FAMILY_ORDER"); for MDD-only species the first of MDD's current,
# CMW or MSW3 genus that the backbone samples.
#
# Additions are made on the FULL 4,098-species backbone, so every sequenced
# congener constrains the placement, and the tree is pruned to the universe last.
#
# WHAT THIS IS NOT. A grafted tip sits where taxonomy puts it. The single
# deterministic tree hides that uncertainty entirely; the 100 randomised trees
# show part of it (position within the constraint clade) but not the chance that
# the genus itself is wrong or non-monophyletic. Any result that changes when the
# grafted tips are dropped rests on the grafts. tree_tip_provenance_augmented.csv
# exists so every analysis can drop them.
#
#   OUTPUT
#     _keys/mammal_tree_augmented.nwk                 deterministic, tips = accepted names
#     _keys/mammal_trees_augmented100.nwk             100 randomised placements
#     __merging_trees/tree_augmentation_log.csv       one row per candidate species:
#                                                     constraint, age, authority,
#                                                     method, decided_by
#     __merging_trees/tree_tip_provenance_augmented.csv  sequenced / grafted_local
#     __merging_trees/tree_coverage_report_augmented.csv one row per universe name
#
# Run from repo root, AFTER build_mammal_tree.R and build_mammal_trees_sample.R:
#   Rscript __merging_trees/build_mammal_tree_augmented.R
# Paths: reads $EVOM1_REPO (default: this repo), writes $EVOM1_OUT (default: same).
# Requires: ape.  No Python mirror.
# =============================================================================

suppressWarnings(suppressMessages(library(ape)))

.here <- local({
  a <- commandArgs(FALSE); f <- sub("^--file=", "", a[grep("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else "__merging_trees"
})
source(file.path(.here, "resolve_tips.R"))
P <- evom1_paths()
MERGE_OUT <- file.path(P$out, "__merging_trees")

N_RANDOM <- 100L
SEED     <- 20261119L
DIGITS   <- 7L           # branch lengths in Myr; 7 significant digits

# ---- backbone: the full DNA-only tree, outgroup removed ------------------------
src <- list.files(file.path(P$repo, "Upham_etal_2019"),
                  pattern = "\\.(nwk|tre|newick|nex|tree)$", full.names = TRUE,
                  ignore.case = TRUE)[1]
txt <- readLines(src, warn = FALSE)
bb <- if (any(grepl("#NEXUS", txt, ignore.case = TRUE))) read.nexus(src) else read.tree(src)
if (inherits(bb, "multiPhylo")) bb <- bb[[1]]
parts <- strsplit(bb$tip.label, "_+")
is_mammal_tip <- vapply(parts, function(v) sum(nzchar(v)) >= 4, logical(1))
bb <- keep.tip(bb, bb$tip.label[is_mammal_tip])     # drops _Anolis_carolinensis
bb$node.label <- NULL
tipparts <- do.call(rbind, lapply(strsplit(bb$tip.label, "_+"), function(v) {
  v <- v[nzchar(v)]; c(v[1], v[length(v) - 1], v[length(v)]) }))
bb_genus <- tipparts[, 1]; bb_family <- tipparts[, 2]
cat("backbone     :", src, "\n  mammal tips:", Ntip(bb), "\n")

# ---- who is already on the tree, and who is a candidate ------------------------
xw  <- read_chr_csv(evom1_pipeline_file(P, "tree_tip_crosswalk.csv"))
uni <- read_chr_csv(evom1_pipeline_file(P, "species_universe.csv"))
resA <- resolve_tips(xw, bb$tip.label, uni, upham_completed_taxa(P$repo))
repA <- resA$report

covB_file <- evom1_pipeline_file(P, "tree_coverage_report_completed100.csv")
provB_file <- evom1_pipeline_file(P, "tree_tip_provenance_completed100.csv")
if (!file.exists(covB_file) || !file.exists(provB_file))
  stop("Run build_mammal_trees_sample.R first: its coverage report and provenance ",
       "table say which names Upham et al. recognise without sequence data.")
provB <- read_chr_csv(provB_file)
mdd <- read_chr_csv(file.path(.here, "reference_tables", "mdd_names_extract.csv"))
mdd$name <- gsub("_", " ", mdd$sciName)

on_A <- resA$keep_acc
pool1 <- provB[provB$provenance != "sequenced" & !(provB$accepted_name %in% on_A), ]
p1 <- strsplit(pool1$source_tip, "_+")
# Tip labels in the Completed trees are bare "Genus_species" (no FAMILY_ORDER
# suffix), so the family comes from the project taxonomy (the crosswalk's
# family_expected), else from MDD by the Upham name. It is only used when the
# genus has no sequenced species, and only if the backbone has that family.
placed_as1 <- vapply(p1, function(v) paste(v[1], v[2]), character(1))
fam_proj <- repA$family_expected[match(pool1$accepted_name, repA$accepted_name)]
mdd_by <- function(nm) {
  i <- match(nm, mdd$name)
  j <- match(gsub(" ", "_", nm), mdd$CMW_sciName); i[is.na(i)] <- j[is.na(i)]
  j <- match(gsub(" ", "_", nm), mdd$MSW3_sciName); i[is.na(i)] <- j[is.na(i)]
  i
}
fam_mdd <- mdd$family[mdd_by(placed_as1)]
fam1 <- toupper(ifelse(!is.na(fam_proj) & nzchar(fam_proj) & toupper(fam_proj) %in% bb_family,
                       fam_proj, fam_mdd))
cand1 <- data.frame(
  accepted_name = pool1$accepted_name,
  pool = "upham_completed_no_dna",
  placed_as = placed_as1,
  genus_try = vapply(p1, function(v) v[1], character(1)),
  family = fam1,
  authority = paste("genus from the Upham et al. 2019 tip label; family (used only when",
                    "the genus is unsequenced) from species_taxonomy.csv or MDD"),
  stringsAsFactors = FALSE)

absent <- repA$accepted_name[repA$status %in% c("absent_from_tree", "absent_but_review_lead")]
u2 <- uni[uni$accepted_name %in% absent & uni$mdd_current == "TRUE" &
          !(uni$accepted_name %in% provB$accepted_name), ]
m_i <- match(u2$accepted_name, mdd$name)
u2 <- u2[mdd$extinct[m_i] != "1", ]; m_i <- match(u2$accepted_name, mdd$name)
first_sampled_genus <- function(i) {
  g <- unique(c(mdd$genus[i], sub("_.*", "", mdd$CMW_sciName[i]), sub("_.*", "", mdd$MSW3_sciName[i])))
  g <- g[!is.na(g) & nzchar(g) & g != "NA"]
  hit <- g[g %in% bb_genus]
  if (length(hit)) hit[1] else g[1]
}
cand2 <- data.frame(
  accepted_name = u2$accepted_name,
  pool = rep("mdd_current_not_in_upham", nrow(u2)),
  placed_as = u2$accepted_name,
  genus_try = if (nrow(u2)) vapply(m_i, first_sampled_genus, character(1)) else character(0),
  family = toupper(mdd$family[m_i]),
  authority = rep("genus (current, CMW or MSW3) and family from the Mammal Diversity Database", nrow(u2)),
  stringsAsFactors = FALSE)
cand <- rbind(cand1, cand2)
cand <- cand[!duplicated(cand$accepted_name), ]
cat("candidates   :", nrow(cand), " (", sum(cand$pool == "upham_completed_no_dna"),
    "Upham no-DNA,", sum(cand$pool == "mdd_current_not_in_upham"), "MDD-only )\n")

# ---- constraints on the backbone ----------------------------------------------
N <- Ntip(bb); M <- bb$Nnode
depth <- node.depth.edgelength(bb); H <- max(depth)
age0 <- H - depth                                   # tips ~0, root = H
parent0 <- integer(N + M); parent0[bb$edge[, 2]] <- bb$edge[, 1]
ntip_under <- node.depth(bb, method = 1)            # tips below each node

constraint_for <- function(members) {
  if (length(members) >= 2) {
    v <- getMRCA(bb, members)
    list(mode = "crown", node = v, n = length(members),
         mono = ntip_under[v] == length(members), age = age0[v], clade_tips = ntip_under[v])
  } else if (length(members) == 1) {
    list(mode = "stem", node = members, n = 1L, mono = TRUE,
         age = age0[parent0[members]], clade_tips = 1L)
  } else NULL
}
genus_tips  <- split(seq_len(N), bb_genus)
family_tips <- split(seq_len(N), bb_family)
# crown nodes of genera that are monophyletic on the backbone (>= 2 species)
mono_crown <- vapply(genus_tips, function(m) {
  if (length(m) < 2) return(NA_integer_)
  v <- getMRCA(bb, m)
  if (ntip_under[v] == length(m)) as.integer(v) else NA_integer_
}, integer(1))
mono_crown <- mono_crown[!is.na(mono_crown)]
con_cache <- new.env()
get_con <- function(rank, taxon) {
  key <- paste(rank, taxon)
  if (!exists(key, envir = con_cache, inherits = FALSE)) {
    members <- if (rank == "genus") genus_tips[[taxon]] else family_tips[[taxon]]
    assign(key, constraint_for(members), envir = con_cache)
  }
  get(key, envir = con_cache)
}

cand$constraint_rank <- cand$constraint_taxon <- cand$method <- ""
cand$n_sequenced_relatives <- 0L; cand$constraint_monophyletic <- NA
cand$constraint_age_Ma <- NA_real_; cand$constraint_clade_tips <- NA_integer_
cand$placed <- FALSE
for (i in seq_len(nrow(cand))) {
  con <- NULL; rank <- ""
  if (!is.null(genus_tips[[cand$genus_try[i]]])) {
    rank <- "genus"; taxon <- cand$genus_try[i]; con <- get_con(rank, taxon)
  } else if (!is.na(cand$family[i]) && !is.null(family_tips[[cand$family[i]]])) {
    rank <- "family"; taxon <- cand$family[i]; con <- get_con(rank, taxon)
  }
  if (is.null(con)) {
    cand$method[i] <- "not_placed_no_sequenced_relative"
    next
  }
  cand$placed[i] <- TRUE
  cand$constraint_rank[i] <- rank; cand$constraint_taxon[i] <- taxon
  cand$n_sequenced_relatives[i] <- con$n
  cand$constraint_monophyletic[i] <- con$mono
  cand$constraint_age_Ma[i] <- round(con$age, 4)
  cand$constraint_clade_tips[i] <- con$clade_tips
  cand$method[i] <- if (con$mode == "crown") "crown_node_polytomy | random_within_crown"
                    else "terminal_branch_midpoint | random_on_terminal_branch"
}
placed <- cand[cand$placed, ]
placed$key <- paste(placed$constraint_rank, placed$constraint_taxon)
cat("placed       :", nrow(placed), " (genus-level", sum(placed$constraint_rank == "genus"),
    ", family-level", sum(placed$constraint_rank == "family"), ")  not placed:",
    sum(!cand$placed), "\n")

# ---- grafting on plain vectors -------------------------------------------------
# Nodes keep their backbone ids; new tips and new internal nodes get ids above.
graft <- function(random) {
  n_add <- nrow(placed)
  cap <- N + M + 2L * n_add
  parent <- integer(cap); parent[seq_len(N + M)] <- parent0
  age <- numeric(cap); age[seq_len(N + M)] <- age0
  is_tip <- logical(cap); is_tip[seq_len(N)] <- TRUE
  ch <- vector("list", cap)
  kids <- split(bb$edge[, 2], bb$edge[, 1])
  ch[as.integer(names(kids))] <- kids
  nxt <- N + M
  new_tip <- integer(n_add)
  stop_at <- logical(cap); stop_at[mono_crown] <- TRUE
  stem_child <- seq_len(N)                  # top of the lineage leading to each backbone tip

  # child ids of every edge below v, not descending into another monophyletic genus
  subtree_edges <- function(v) {
    out <- integer(0); stack <- v
    while (length(stack)) {
      k <- ch[[stack[length(stack)]]]; stack <- stack[-length(stack)]
      if (length(k)) { out <- c(out, k); stack <- c(stack, k[!is_tip[k] & !stop_at[k]]) }
    }
    out
  }
  split_edge <- function(c, t) {            # new node at age t on edge parent[c] -> c
    p <- parent[c]; nxt <<- nxt + 1L; n <- nxt
    parent[n] <<- p; age[n] <<- t; parent[c] <<- n
    ch[[p]][ch[[p]] == c] <<- n; ch[[n]] <<- c
    n
  }
  add_tip <- function(at) {
    nxt <<- nxt + 1L; x <- nxt
    parent[x] <<- at; age[x] <<- 0; is_tip[x] <<- TRUE
    ch[[at]] <<- c(ch[[at]], x)
    x
  }

  groups <- split(seq_len(n_add), placed$key)
  gmode <- vapply(names(groups), function(k) get(k, envir = con_cache)$mode, character(1))
  # Order: every clade-wide ("crown") placement first, then the single-relative
  # ("stem") ones, so the small exclusive clade a stem placement creates is never
  # entered afterwards; within each, genus before family, then alphabetical.
  gord <- order(gmode != "crown", !grepl("^genus ", names(groups)), names(groups),
                method = "radix")
  for (g in gord) {
    idx <- groups[[g]]
    if (random && length(idx) > 1) idx <- sample(idx)
    con <- get(names(groups)[g], envir = con_cache)
    crown <- if (con$mode == "crown") con$node else NA_integer_
    pool <- if (random && !is.na(crown)) subtree_edges(crown) else integer(0)
    for (j in idx) {
      if (is.na(crown)) {                   # single sequenced relative: its stem
        c0 <- stem_child[con$node]          # the relative, or its genus clade if it has grown
        lo <- age[c0]; hi <- age[parent[c0]]
        t <- if (random) runif(1, lo, hi) else (lo + hi) / 2
        crown <- split_edge(c0, t)
        stem_child[con$node] <- crown
        new_tip[j] <- add_tip(crown)
        if (random) pool <- c(c0, new_tip[j])
      } else if (!random) {
        new_tip[j] <- add_tip(crown)
      } else {
        len <- age[parent[pool]] - age[pool]
        c <- pool[sample.int(length(pool), 1L, prob = pmax(len, 0))]
        t <- runif(1, age[c], age[parent[c]])
        n <- split_edge(c, t)
        new_tip[j] <- add_tip(n)
        pool <- c(pool, n, new_tip[j])
      }
    }
  }

  # ---- back to an ape phylo ---------------------------------------------------
  used <- seq_len(nxt)
  tips_all <- c(seq_len(N), new_tip)
  internals <- setdiff(used, tips_all)
  root <- internals[parent[internals] == 0L]
  stopifnot(length(root) == 1L)
  internals <- c(root, setdiff(internals, root))
  newid <- integer(nxt)
  newid[tips_all] <- seq_along(tips_all)
  newid[internals] <- length(tips_all) + seq_along(internals)
  kid <- setdiff(used, root)
  phy <- list(edge = cbind(newid[parent[kid]], newid[kid]),
              edge.length = age[parent[kid]] - age[kid],
              tip.label = c(bb$tip.label, gsub(" ", "_", paste0("GRAFT_", placed$accepted_name))),
              Nnode = length(internals))
  class(phy) <- "phylo"
  reorder(phy, "cladewise")
}

# ---- final tip set and labels ---------------------------------------------------
keepA <- resA$keep_tip
relab <- c(setNames(gsub(" ", "_", resA$keep_acc), keepA),
           setNames(gsub(" ", "_", placed$accepted_name),
                    gsub(" ", "_", paste0("GRAFT_", placed$accepted_name))))
finish <- function(phy) {
  phy <- keep.tip(phy, names(relab))
  phy$tip.label <- unname(relab[phy$tip.label])
  phy
}

# Self-check on the UNPRUNED tree: every added tip must descend from the crown
# node of its constraint taxon (>= 2 sequenced relatives), or be the sister of
# its single sequenced relative. Stops the build if any placement escaped.
verify_constraints <- function(phy, what) {
  bad <- character(0)
  for (key in unique(placed$key)) {
    con <- get(key, envir = con_cache)
    new <- gsub(" ", "_", paste0("GRAFT_", placed$accepted_name[placed$key == key]))
    rank <- sub(" .*", "", key); taxon <- sub("^[^ ]+ ", "", key)
    mem <- bb$tip.label[if (rank == "genus") genus_tips[[taxon]] else family_tips[[taxon]]]
    if (con$mode == "crown") {
      if (getMRCA(phy, mem) != getMRCA(phy, c(mem, new))) bad <- c(bad, key)
    } else {
      # the relative plus the additions must form a clade holding no OTHER sequenced tip
      inside <- extract.clade(phy, getMRCA(phy, c(mem, new)))$tip.label
      if (any(!grepl("^GRAFT_", inside) & inside != mem)) bad <- c(bad, key)
    }
  }
  # no monophyletic backbone genus may have gained a tip of another taxon
  graft_key <- setNames(placed$key, gsub(" ", "_", paste0("GRAFT_", placed$accepted_name)))
  for (gname in names(mono_crown)) {
    inside <- extract.clade(phy, getMRCA(phy, bb$tip.label[genus_tips[[gname]]]))$tip.label
    g_in <- inside[grepl("^GRAFT_", inside)]
    if (length(g_in) && any(graft_key[g_in] != paste("genus", gname)))
      bad <- c(bad, paste("intruder in genus", gname))
  }
  if (length(bad))
    stop(what, ": ", length(bad), " constraint(s) violated, e.g. ", paste(head(bad, 5), collapse = "; "))
  invisible(TRUE)
}

det_full <- graft(random = FALSE)
verify_constraints(det_full, "deterministic tree")
det <- finish(det_full)
stopifnot(!anyDuplicated(det$tip.label))
write.tree(det, file.path(P$out, "_keys", "mammal_tree_augmented.nwk"), digits = 10)

set.seed(SEED)
rnd <- lapply(seq_len(N_RANDOM), function(k) {
  full <- graft(random = TRUE)
  if (k %in% c(1L, 50L, 100L)) verify_constraints(full, paste("randomised tree", k))
  finish(full)
})
class(rnd) <- "multiPhylo"
cat("self-check passed (unpruned deterministic tree; randomised trees 1, 50, 100): every added\n",
    " tip is inside its constraint clade, and no monophyletic backbone genus gained an outsider\n")
write.tree(rnd, file.path(P$out, "_keys", "mammal_trees_augmented100.nwk"), digits = DIGITS)

# ---- log, provenance, coverage -------------------------------------------------
log <- cand[, c("accepted_name", "pool", "placed_as", "placed", "constraint_rank",
                "constraint_taxon", "n_sequenced_relatives", "constraint_monophyletic",
                "constraint_age_Ma", "constraint_clade_tips", "method", "authority")]
log$decided_by <- "rule in build_mammal_tree_augmented.R (no per-species judgement)"
log$random_seed <- SEED
log <- log[order(enc2utf8(log$accepted_name), method = "radix"), ]
write_csv_utf8(log, file.path(MERGE_OUT, "tree_augmentation_log.csv"))

prov <- data.frame(
  accepted_name = c(resA$keep_acc, placed$accepted_name),
  tip_label = gsub(" ", "_", c(resA$keep_acc, placed$accepted_name)),
  provenance = c(rep("sequenced", length(resA$keep_acc)),
                 paste0("grafted_local_", placed$constraint_rank)),
  stringsAsFactors = FALSE)
prov <- prov[order(enc2utf8(prov$accepted_name), method = "radix"), ]
write_csv_utf8(prov, file.path(MERGE_OUT, "tree_tip_provenance_augmented.csv"))

repC <- repA
gi <- match(repC$accepted_name, placed$accepted_name)
hit <- !is.na(gi)
repC$status[hit] <- "grafted_local"
repC$matched_tip[hit] <- gsub(" ", "_", placed$accepted_name[gi[hit]])
repC$matched_via[hit] <- placed$placed_as[gi[hit]]
repC$candidate_source[hit] <- placed$pool[gi[hit]]
repC$note[hit] <- paste0("added locally under a ", placed$constraint_rank[gi[hit]],
                         " constraint (", placed$constraint_taxon[gi[hit]], ", ",
                         placed$n_sequenced_relatives[gi[hit]], " sequenced relatives)")
write_csv_utf8(repC, file.path(MERGE_OUT, "tree_coverage_report_augmented.csv"))

d <- node.depth.edgelength(det)[seq_len(Ntip(det))]
cat("\ndeterministic tree: tips", Ntip(det), " (sequenced", length(resA$keep_acc),
    ", grafted", nrow(placed), ")  binary:", is.binary(det), "\n")
cat(sprintf("root age: %.3f   root-to-tip spread: %.6g\n", max(d), max(d) - min(d)))
cat("randomised trees  :", length(rnd), " tips each", unique(vapply(rnd, Ntip, 1L)),
    " all binary:", all(vapply(rnd, is.binary, TRUE)), "\n")
tb <- sort(table(repC$status), decreasing = TRUE)
for (i in seq_along(tb)) cat(sprintf("  %5d  %s\n", tb[i], names(tb)[i]))
cat("wrote", file.path(P$out, "_keys", "mammal_tree_augmented.nwk"), "\n")
cat("wrote", file.path(P$out, "_keys", "mammal_trees_augmented100.nwk"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_augmentation_log.csv"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_tip_provenance_augmented.csv"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_coverage_report_augmented.csv"), "\n")
