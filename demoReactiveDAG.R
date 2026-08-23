devtools::load_all("../SBoo")

# -------------------------
# Example node functions
# -------------------------

sum_xy <- function(x, y) {
  x + y
}

double_sum <- function(sum_xy) {
  2 * sum_xy
}

mix_all <- function(double_sum, z) {
  double_sum + z
}

# -------------------------
# Proof of working
# -------------------------

dag <- ReactiveDAG$new(params = list(y = 10, z = 100))

dag$add_source("x", 1)

dag$add_node_reactive("sum_xy")
dag$add_node_reactive("double_sum")
dag$add_node_reactive("mix_all")

cat("Initial values:\n")
cat("sum_xy    =", dag$trigger("sum_xy"), "\n")     # 1 + 10 = 11
cat("double_sum=", dag$trigger("double_sum"), "\n") # 2 * 11 = 22
cat("mix_all   =", dag$trigger("mix_all"), "\n")    # 22 + 100 = 122

dag$set_source("x", 5)

cat("\nAfter changing source x to 5:\n")
cat("sum_xy    =", dag$trigger("sum_xy"), "\n")     # 5 + 10 = 15
cat("double_sum=", dag$trigger("double_sum"), "\n") # 2 * 15 = 30
cat("mix_all   =", dag$trigger("mix_all"), "\n")    # 30 + 100 = 130

dag$add_param("z", 1000)

cat("\nAfter changing param z to 1000:\n")
cat("mix_all   =", dag$trigger("mix_all"), "\n")    # still 130, it's not a reactive!

# -------------------------
# Debug DAG
# -------------------------

cat("\n====================\n")
cat("DEBUG DAG\n")
cat("====================\n")

dag2 <- ReactiveDAG$new(params = list(y = 10, z = 100))
dag2$add_source("x", 1)

dag2$add_node_reactive("sum_xy")
dag2$add_node_reactive("double_sum", debug = TRUE)
dag2$add_node_reactive("mix_all", debug = TRUE)

cat("mix_all =", dag2$trigger("mix_all"), "\n")

dag2$set_source("x", 5)
cat("mix_all after x = 5:", dag2$trigger("mix_all"), "\n")

debugonce(sum_xy)
dag2$trigger("sum_xy")

