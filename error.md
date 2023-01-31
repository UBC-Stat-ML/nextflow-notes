```bash
N E X T F L O W  ~  version 18.10.1
Launching `minimal.nf` [curious_boyd] - revision: 248b7b09fe
[warm up] executor > local
[a1/1ccda3] Submitted process > myPreprocessor
ERROR ~ Error executing process > 'myPreprocessor'

Caused by:
  Process `myPreprocessor` terminated with an error exit status (127)

Command executed:

  #!/usr/bin/env Rscript
  
  data("iris")
  # [ some computationally expensive preprocessing can be added here ]
  write.csv(iris, "output.csv")

Command exit status:
  127

Command output:
  (empty)

Command error:
  /usr/bin/env: Rscript: No such file or directory

Work dir:
  /scratch/st-singha53-1/tliang19/work_dir/tmp/nextflow-notes-1/work/a1/1ccda30f9d7e89a39a2536558544f2

Tip: view the complete command output by changing to the process work dir and entering the command `cat .command.out`

 -- Check '.nextflow.log' file for details
```
