cluster.functions = makeClusterFunctionsHTCondor()
mail.start = "none"
mail.done = "none"
mail.error = "none"
db.driver = "SQLite"
default.resources <- list(universe='vanilla', R.bin.path=file.path(dirname(dirname(find.package("BatchJobs"))), "bin", "R"), memory='5 GB', cpus='1')
#as suggested here https://github.com/tudo-r/BatchJobs/wiki/Configuration
db.options = list(pragmas = c("busy_timeout=5000", "journal_mode=WAL"))
debug = FALSE
#this should ensure that there is no issue with NFS locking if run on /mnt/tempwork 
staged.queries = TRUE
