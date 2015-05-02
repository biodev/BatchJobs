cluster.functions = makeClusterFunctionsHTCondor()
mail.start = "none"
mail.done = "none"
mail.error = "none"
db.driver = "SQLite"
default.resources <- list(universe='vanilla', R.bin.path=file.path(dirname(dirname(find.package("BatchJobs"))), "bin", "R"), memory='5 GB', cpus='1')
db.options = list(db.name=":memory:")
debug = FALSE
