```
Warning: command open returned non-zero code (1). Output so far:
Couldn't get a file descriptor referring to the console

N E X T F L O W  ~  version 18.10.1
Launching `minimal.nf` [boring_wing] - revision: 248b7b09fe
[warm up] executor > local
[81/f6af66] Submitted process > myPreprocessor
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
  /scratch/st-singha53-1/tliang19/work_dir/tmp/nextflow-notes-1/work/81/f6af66d64089d9ae068740166cb5c0

Tip: view the complete command output by changing to the process work dir and entering the command `cat .command.out`

 -- Check '.nextflow.log' file for details
```
