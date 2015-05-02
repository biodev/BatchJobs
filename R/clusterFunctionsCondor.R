makeClusterFunctionsHTCondor <- function()
{
   
    HTCondor.templ <- '
    ###Common parameters across all inputs
    Universe=<%= resources$universe %>
    Executable=<%= resources$R.bin.path %>
    arguments=CMD BATCH --no-save --no-restore <%= rscript %> /dev/stdout
    request_memory=<%= resources$memory %>
    request_cpus=<%= resources$cpus %>
    output=<%= resources$log.dir %>/stdout.<%= basename(rscript) %>
    error=<%= resources$log.dir %>/stderr.<%= basename(rscript) %>
    log=<%= resources$log.dir %>/condor_log.<%= basename(rscript) %>
    queue 1
    '
    
    submitJob <- function(conf, reg, job.name, rscript, log.file, job.dir, resources,...)
    {
        outfile =  cfBrewTemplate(conf, HTCondor.templ, rscript, "job")
        res = .runOSCommandLinux("condor_submit", outfile, stop.on.exit.code = FALSE)
        if (res$exit.code > 0L) {
             cfHandleUnknownSubmitError("condor_submit", res$exit.code, 
                res$output)
        }
        else {
            ##$output
            ##[1] "Submitting job(s)....."           "5 job(s) submitted to cluster 6."
                ##assuming that cluster id is what we want --only one job per cluster
            job.out <- paste(res$output, collapse=" ")
            job.matches <- regmatches(job.out, regexec("cluster\\s+(\\d+)", job.out))[[1]]
            stopifnot(length(job.matches) == 2)
            batch.job.id <- as.character(job.matches[2])
            
            makeSubmitJobResult(status = 0L, batch.job.id = batch.job.id)
        }
    }
    
    killJob <- function(conf, reg, batch.job.id) {
        cfKillBatchJob("condor_rm", batch.job.id)
    }
    
    listJobs <- function(conf, reg){
      
        res <- .runOSCommandLinux("condor_q", c("-submitter", "`whoami`"), stop.on.exit.code = FALSE)
        #deal with the case that no jobs exist for the user as the condor_q command...
        if(res$exit.code > 0L && res$output == "Error: Collector has no record of schedd/submitter"){
            return(integer(0))
        }
        else if (res$exit.code > 0L){
            stopf("condor_q produced exit code %i; output %s", res$exit.code, 
                res$output)
        }else{
            use.ids <- sapply(res$output[(grep("ID", res$output)+1):length(res$output)], function(x)
                        {
                            if (x != "" && grepl("\\d+\\s+jobs;\\s+\\d+\\s+completed,",x)==F)
                            {
                                 
                                 job.pattern <- regexec("[[:digit:]]+\\.[[:digit:]]", x)
                                 job.match <- regmatches(x, job.pattern)[[1]]
                                 
                                 return(job.match)
                            }else{
                                return(NA)
                            }
                        }, USE.NAMES=F)
            #should be in the form cluster.process, truncate to the nearest integer(cluster)
            use.ids <- as.integer(use.ids[!is.na(use.ids)])
            return(use.ids)
        }
       
    }
    
    #will limit to chunk processing for now, don't think it can handle the macro processing as with SGE its an environmental var
    getArrayEnvirName = function() NA
    
    #might implement a pretty-printer class at some point...
    return(makeClusterFunctions(name="HTCondor", submitJob = submitJob, 
        killJob = killJob, listJobs = listJobs, getArrayEnvirName = getArrayEnvirName, class=NULL))
}