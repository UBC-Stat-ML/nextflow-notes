process myPreprocessor {
    
  output:
    file 'output.csv' into myChannel
    
  """
  #!/usr/bin/env Rscript
  
  data("iris")
  # [ some computationally expensive preprocessing can be added here ]
  write.csv(iris, "output.csv")
  """
}

process myCode {

  input:
    file myChannel
    each kernel from 'gaussian', 'epanechnikov', 'rectangular'
    
  """
  #!/usr/bin/env Rscript
  
  pdf("${kernel}.pdf")
  df <- read.csv("$myChannel")
  plot(density(df\$Sepal.Length, kernel = "$kernel"))
  dev.off() 
  """ 
}
