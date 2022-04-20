// Use this to collect final results, e.g. plots and master csv files
deliverableDir = 'deliverables/' + workflow.scriptName.replace('.nf','')

// Use this for data (or for large dataset, use a process that downloads the data)
data = file("data")

// build java code from a repo
process buildBlangDemoCode {
  executor 'local'
  cache true 
  input:
    val gitRepoName from 'blangDemos'
    val gitUser from 'UBC-Stat-ML'
    val codeRevision from 'c6095fe9545a02b85f3b9d438679d265677037dc'
    val snapshotPath from "${System.getProperty('user.home')}/w/blangDemos"
  output:
    file 'code' into code
  script:
    template 'buildRepo.sh' // for quick prototyping, switch to 'buildSnapshot', and set cache to false above
}

nChains_levels = (2..4).collect{Math.pow(2, it)} // 2^2, 2^3, 2^4
seeds = (1..5)

// parameters can be passed in, e.g. for a "dry run"
params.dryRun = false

// if we do a dry run, set parameters so that everything runs quickly
if (params.dryRun) {
  nChains_levels = nChains_levels.subList(0, 1)
  seeds = seeds.subList(0, 1)
}

// run experiments
process runBlang {
  // will be required for cluster execution:
  time '2m'  
  cpus 1
  // errorStrategy 'ignore'  // by default, pipeline stops

  input:
    each reversible from true, false
    each nChains from nChains_levels
    each seed from seeds
    file code
    file data
    
  output:
    file 'output' into results
    
  """
  java -Xmx5g -cp ${code}/lib/\\* texting.ChangePoint \
    --experimentConfigs.resultsHTMLPage false \
    --model.counts file ${data}/texting-data.csv \
    --engine.reversible $reversible \
    --engine.nChains $nChains \
    --engine.random $seed \
    --engine.nThreads single
  # consolidate all csv files in one place
  mkdir output
  mv results/latest/*.csv output
  mv results/latest/monitoring/*.csv output
  mv results/latest/*.tsv output
  """
}

// Merge many csv files while padding relevant experimental configs as new columns in the merged csv
process aggregate {
  time '1m'
  echo false
  scratch false
  input:
    file 'exec_*' from results.toList()
  output:
    file 'results/aggregated/' into aggregated
  """
  aggregate \
    --experimentConfigs.resultsHTMLPage false \
    --experimentConfigs.tabularWriter.compressed true \
    --dataPathInEachExecFolder actualTemperedRestarts.csv swapSummaries.csv \
    --keys \
      engine.nChains as nChains \
      engine.reversible as reversible \
      engine.random as random \
           from arguments.tsv
  mv results/latest results/aggregated
  """
}

process plot {
  // cluster settings
  scratch false  // we don't want these on the individual nodes' machine storage, i.e. we want it to be available from the login node
  
  // the output of this script is what we are ultimately interested in, so copy into deliverable/[name of script]
  publishDir deliverableDir, mode: 'copy', overwrite: true
   
  input:
    file aggregated
  output:
    file '*.*'
    file 'aggregated'   // include the csv files into deliverableDir
  afterScript 'rm Rplots.pdf; cp .command.sh rerun.sh'  // clean up after R, include script to rerun R code from CSVs
  """
  #!/usr/bin/env Rscript
  require("ggplot2")
  require("dplyr")
  
  restarts <- read.csv("${aggregated}/actualTemperedRestarts.csv.gz")
  restarts %>%
    filter(round == 8) %>%
    group_by(reversible, nChains) %>%
    summarise(mean_count = mean(count)) %>%
    ggplot(aes(x = nChains, y = mean_count, colour = reversible)) +
      scale_x_log10() +
      ylab("Average number of tempered restarts") + 
      geom_line()  + 
      theme_bw()
  ggsave("restarts.pdf", width = 5, height = 5)
  """
  
}