## There are five parts:
## Part 1:  Load libraries and define some functions.
## Part 2:  Read the input data and classify the matrix into 5 classes.
## Part 3:  Figures about nucleosome occupancy level (NOL).
## Part 4:  Figures about nucleosome turnover rate (NTR).
## Part 5:  Figures about nucleosome contribution value (NCV).   NCV=f(NOL, NTR)



























#### Part 1:  Load libraries and define some functions.
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
library("reshape2")
library("ggplot2") 
library("grid")
library("Cairo")
library("RColorBrewer")
library("gplots")  
library("stats")
library("KernSmooth")
library("psych")
library("minerva")




pTheme <-  theme(  
  line  = element_line(colour="black", size=1.0,  linetype=1,     lineend=NULL),                                                                    ## all line elements.  局部优先总体,下面3个也是,只对非局部设置有效.   所有线属性.
  rect  = element_rect(colour="black", size=1.0,  linetype=1,     fill="transparent" ),                                                             ## all rectangluar elements.    hjust=1: 靠右对齐.   所有矩形区域属性.
  text  = element_text(family="sans",  face=NULL, colour="black", size=10, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),                    ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
  title = element_text(family="sans",  face=NULL, colour="black", size=10, hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),                    ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.

  axis.title        = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
  axis.title.x      = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=-15,  angle=NULL, lineheight=NULL),        ## x axis label (element_text; inherits from axis.title)
  axis.title.y      = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),        ## y axis label (element_text; inherits from axis.title)
  axis.text         = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## tick labels along axes (element_text; inherits from text). 坐标轴刻度的标签的属性.                                                         
  axis.text.x       = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## x axis tick labels (element_text; inherits from axis.text)
  axis.text.y       = element_text(family="sans", face=NULL, colour="black", size=10,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## y axis tick labels (element_text; inherits from axis.text)
  axis.ticks        = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## tick marks along axes (element_line; inherits from line). 坐标轴刻度线.
  axis.ticks.x      = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## x axis tick marks (element_line; inherits from axis.ticks)
  axis.ticks.y      = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## y axis tick marks (element_line; inherits from axis.ticks)
  axis.ticks.length = grid::unit(1.5, "mm", data=NULL),                                                                                             ## length of tick marks (unit), ‘"mm"’ Millimetres.  10 mm = 1 cm.  刻度线长度
  axis.ticks.margin = grid::unit(1.0, "mm", data=NULL),  	                                                                                          ## space between tick mark and tick label (unit),  ‘"mm"’ Millimetres.  10 mm = 1 cm. 刻度线和刻度标签之间的间距.                                                                           
  axis.line         = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL), 	                                                    ## lines along axes (element_line; inherits from line). 坐标轴线
  axis.line.x       = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL), 	                                                    ## line along x axis (element_line; inherits from axis.line)
  axis.line.y       = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL),	                                                      ## line along y axis (element_line; inherits from axis.line)
  
  legend.background    = element_rect(colour="transparent", size=1, linetype=1, fill="transparent" ), 	      ## background of legend (element_rect; inherits from rect)
  legend.margin        = grid::unit(0.5, "mm", data=NULL), 	                                                  ## extra space added around legend (unit). linetype=1指的是矩形边框的类型.
  legend.key           = element_rect(colour="transparent", size=2, linetype=1, fill="transparent" ), 	      ## background underneath legend keys. 图例符号. size=1指的是矩形边框的大小.
  legend.key.size      = grid::unit(5, "mm", data=NULL) , 	                                                  ## size of legend keys (unit; inherits from legend.key.size)
  legend.key.height    = grid::unit(7, "mm", data=NULL) , 	                                                  ## key background height (unit; inherits from legend.key.size)
  legend.key.width     = grid::unit(5, "mm", data=NULL) ,                                                     ## key background width (unit; inherits from legend.key.size)
  legend.text          = element_text(family="sans", face=NULL, colour="black", size=12, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	##legend item labels. 图例文字标签.
  legend.text.align    = 0, 	                ## alignment of legend labels (number from 0 (left) to 1 (right))
  legend.title         = element_blank(),   	## title of legend (element_text; inherits from title)
  legend.title.align   = 0, 	                ## alignment of legend title (number from 0 (left) to 1 (right))
  legend.position      = "right", 	          ## the position of legends. ("left", "right", "bottom", "top", or two-element numeric vector)
  legend.direction     = "vertical",        	## layout of items in legends  ("horizontal" or "vertical")   图例排列方向
  legend.justification = "center",      	    ## anchor point for positioning legend inside plot ("center" or two-element numeric vector)  图例居中方式
  legend.box           = NULL, 	              ## arrangement of multiple legends ("horizontal" or "vertical")  多图例的排列方式
  legend.box.just      = NULL, 	              ## justification of each legend within the overall bounding box, when there are multiple legends ("top", "bottom", "left", or "right")  多图例的居中方式
  
  panel.background   = element_rect(colour="transparent", size=0.1, linetype=1, fill="transparent" ),   	## background of plotting area, drawn underneath plot (element_rect; inherits from rect)
  panel.border       = element_rect(colour="black", size=0.4, linetype=NULL, fill=NA ), 	                ## border around plotting area, drawn on top of plot so that it covers tick marks and grid lines. This should be used with fill=NA (element_rect; inherits from rect)
  panel.margin       = grid::unit(2, "mm", data=NULL) , 	                                                ## margin around facet panels (unit)  分面绘图区之间的边距
  panel.grid         = element_blank(), 	                                                                ## grid lines (element_line; inherits from line)  绘图区网格线
  panel.grid.major   = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) , 	    ## major grid lines (element_line; inherits from panel.grid)  主网格线
  panel.grid.minor   = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## minor grid lines (element_line; inherits from panel.grid)  次网格线
  panel.grid.major.x = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) , 	    ## vertical major grid lines (element_line; inherits from panel.grid.major)
  panel.grid.major.y = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## horizontal major grid lines (element_line; inherits from panel.grid.major)
  panel.grid.minor.x = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## vertical minor grid lines (element_line; inherits from panel.grid.minor)
  panel.grid.minor.y = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## horizontal minor grid lines (element_line; inherits from panel.grid.minor)
  
  plot.background	= element_rect(colour="transparent", size=NULL, linetype=NULL, fill="transparent" ),                                              ## background of the entire plot (element_rect; inherits from rect)  整个图形的背景
  plot.title      = element_text(family="sans", face=NULL, colour="black", size=10, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## plot title (text appearance) (element_text; inherits from title)  图形标题
  plot.margin     = grid::unit(c(8, 8, 8, 8), "mm", data=NULL), 	                                                                                  ## margin around entire plot (unit with the sizes of the top, right, bottom, and left margins)
  
  strip.background = element_rect(colour=NULL, size=NULL, linetype=NULL, fill=NULL ), 	                                                            ## background of facet labels (element_rect; inherits from rect)  分面标签背景
  strip.text       = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## facet labels (element_text; inherits from text)
  strip.text.x     = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## facet labels along horizontal direction (element_text; inherits from strip.text)
  strip.text.y     = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL)   	        ## facet labels along vertical direction (element_text; inherits from strip.text) 
) 









pTheme2 <-  theme(  
  line  = element_line(colour="black", size=1.0,  linetype=1,     lineend=NULL),                                                                    ## all line elements.  局部优先总体,下面3个也是,只对非局部设置有效.   所有线属性.
  rect  = element_rect(colour="black", size=1.0,  linetype=1,     fill="transparent" ),                                                             ## all rectangluar elements.    hjust=1: 靠右对齐.   所有矩形区域属性.
  text  = element_text(family="sans",  face=NULL, colour="black", size=15, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),                    ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
  title = element_text(family="sans",  face=NULL, colour="black", size=15, hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),                    ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.
  
  axis.title        = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
  axis.title.x      = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=-15,  angle=NULL, lineheight=NULL),        ## x axis label (element_text; inherits from axis.title)
  axis.title.y      = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),        ## y axis label (element_text; inherits from axis.title)
  axis.text         = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## tick labels along axes (element_text; inherits from text). 坐标轴刻度的标签的属性.                                                         
  axis.text.x       = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## x axis tick labels (element_text; inherits from axis.text)
  axis.text.y       = element_text(family="sans", face=NULL, colour="black", size=15,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),        ## y axis tick labels (element_text; inherits from axis.text)
  axis.ticks        = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## tick marks along axes (element_line; inherits from line). 坐标轴刻度线.
  axis.ticks.x      = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## x axis tick marks (element_line; inherits from axis.ticks)
  axis.ticks.y      = element_line(colour="black", size=0.3, linetype=1, lineend=NULL),                                                             ## y axis tick marks (element_line; inherits from axis.ticks)
  axis.ticks.length = grid::unit(1.5, "mm", data=NULL),                                                                                             ## length of tick marks (unit), ‘"mm"’ Millimetres.  10 mm = 1 cm.  刻度线长度
  axis.ticks.margin = grid::unit(1.0, "mm", data=NULL),                                                                                              ## space between tick mark and tick label (unit),  ‘"mm"’ Millimetres.  10 mm = 1 cm. 刻度线和刻度标签之间的间距.                                                                           
  axis.line         = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL), 	                                                    ## lines along axes (element_line; inherits from line). 坐标轴线
  axis.line.x       = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL), 	                                                    ## line along x axis (element_line; inherits from axis.line)
  axis.line.y       = element_line(colour="transparent", size=0.3, linetype=1, lineend=NULL),	                                                      ## line along y axis (element_line; inherits from axis.line)
  
  legend.background    = element_rect(colour="transparent", size=1, linetype=1, fill="transparent" ), 	      ## background of legend (element_rect; inherits from rect)
  legend.margin        = grid::unit(0.5, "mm", data=NULL), 	                                                  ## extra space added around legend (unit). linetype=1指的是矩形边框的类型.
  legend.key           = element_rect(colour="transparent", size=2, linetype=1, fill="transparent" ), 	      ## background underneath legend keys. 图例符号. size=1指的是矩形边框的大小.
  legend.key.size      = grid::unit(5, "mm", data=NULL) , 	                                                  ## size of legend keys (unit; inherits from legend.key.size)
  legend.key.height    = grid::unit(7, "mm", data=NULL) , 	                                                  ## key background height (unit; inherits from legend.key.size)
  legend.key.width     = grid::unit(5, "mm", data=NULL) ,                                                     ## key background width (unit; inherits from legend.key.size)
  legend.text          = element_text(family="sans", face=NULL, colour="black", size=12, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	##legend item labels. 图例文字标签.
  legend.text.align    = 0, 	                ## alignment of legend labels (number from 0 (left) to 1 (right))
  legend.title         = element_blank(),   	## title of legend (element_text; inherits from title)
  legend.title.align   = 0, 	                ## alignment of legend title (number from 0 (left) to 1 (right))
  legend.position      = "right", 	          ## the position of legends. ("left", "right", "bottom", "top", or two-element numeric vector)
  legend.direction     = "vertical",        	## layout of items in legends  ("horizontal" or "vertical")   图例排列方向
  legend.justification = "center",      	    ## anchor point for positioning legend inside plot ("center" or two-element numeric vector)  图例居中方式
  legend.box           = NULL, 	              ## arrangement of multiple legends ("horizontal" or "vertical")  多图例的排列方式
  legend.box.just      = NULL, 	              ## justification of each legend within the overall bounding box, when there are multiple legends ("top", "bottom", "left", or "right")  多图例的居中方式
  
  panel.background   = element_rect(colour="transparent", size=0.1, linetype=1, fill="transparent" ),   	## background of plotting area, drawn underneath plot (element_rect; inherits from rect)
  panel.border       = element_rect(colour="black", size=0.4, linetype=NULL, fill=NA ), 	                ## border around plotting area, drawn on top of plot so that it covers tick marks and grid lines. This should be used with fill=NA (element_rect; inherits from rect)
  panel.margin       = grid::unit(2, "mm", data=NULL) , 	                                                ## margin around facet panels (unit)  分面绘图区之间的边距
  panel.grid         = element_blank(), 	                                                                ## grid lines (element_line; inherits from line)  绘图区网格线
  panel.grid.major   = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) , 	    ## major grid lines (element_line; inherits from panel.grid)  主网格线
  panel.grid.minor   = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## minor grid lines (element_line; inherits from panel.grid)  次网格线
  panel.grid.major.x = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) , 	    ## vertical major grid lines (element_line; inherits from panel.grid.major)
  panel.grid.major.y = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## horizontal major grid lines (element_line; inherits from panel.grid.major)
  panel.grid.minor.x = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## vertical minor grid lines (element_line; inherits from panel.grid.minor)
  panel.grid.minor.y = element_line(colour="transparent", size=NULL, linetype=NULL, lineend=NULL) ,     	## horizontal minor grid lines (element_line; inherits from panel.grid.minor)
  
  plot.background	= element_rect(colour="transparent", size=NULL, linetype=NULL, fill="transparent" ),                                              ## background of the entire plot (element_rect; inherits from rect)  整个图形的背景
  plot.title      = element_text(family="sans", face=NULL, colour="black", size=15, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## plot title (text appearance) (element_text; inherits from title)  图形标题
  plot.margin     = grid::unit(c(8, 8, 8, 8), "mm", data=NULL), 	                                                                                  ## margin around entire plot (unit with the sizes of the top, right, bottom, and left margins)
  
  strip.background = element_rect(colour=NULL, size=NULL, linetype=NULL, fill=NULL ), 	                                                            ## background of facet labels (element_rect; inherits from rect)  分面标签背景
  strip.text       = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## facet labels (element_text; inherits from text)
  strip.text.x     = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	        ## facet labels along horizontal direction (element_text; inherits from strip.text)
  strip.text.y     = element_text(family="sans", face=NULL, colour=NULL, size=NULL, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL)   	        ## facet labels along vertical direction (element_text; inherits from strip.text) 
) 






## df contains two columns, the first column (cond_col=1) is sample type, the second column (val_col=2) is value. (must be).
whisk <- function(df, cond_col=1, val_col=2) {  
    require(reshape2)
    condname <- names(df)[cond_col]  ## save the name of the first column.
    names(df)[cond_col] <- "cond" 
    names(df)[val_col]  <- "value"
    b   <- boxplot(value~cond, data=df, plot=FALSE)   
    df2 <- cbind(as.data.frame(b$stats), c("min","lq","m","uq","max"))
    names(df2) <- c(levels(df$cond), "pos")
    df2 <- melt(df2, id="pos", variable.name="cond")
    df2 <- dcast(df2,cond~pos)   
    names(df2)[1] <- condname 
    print(df2)
    df2
}

  


lmEquation <- function(m) { ## m is the output of lm function.
  l <- list( a = format(coef(m)[1], digits = 3, nsmall=3),   b = format(abs(coef(m)[2]), digits = 3, nsmall=4),   r2 = format(summary(m)$r.squared, digits = 3, nsmall=3), pv = format(as.numeric(unlist(summary(m)$coefficients[,4][2] )), digits = 3, nsmall=5) )
  if (coef(m)[2] >= 0)  {
    eq <- substitute(y == a~+~b* "x," ~~r^2~"="~r2* ","  ~~p~"="~pv, l)  ## substitute函数中需要替换的变量用列表参数方式给出。~ is space.
  } else {
    eq <- substitute(y == a~-~b* "x," ~~r^2~"="~r2* ","  ~~p~"="~pv, l)    
  }
  as.character(as.expression(eq));                 
}



turnoverRate <- function(week1, week2, week4, week6, week8) {
    yAxis <- log( c(week1, week2, week4, week6, week8) )
    xAxis <- c(1, 2, 4, 6, 8)
    regression_A <- lm(yAxis ~ xAxis)
    print("####################################################################")
    print(regression_A)
    print(summary(regression_A))
    print("####################################################################")
    b = -(coef(regression_A)[2])
    return(b)
}





normalize_YP1 <- function(vector1) {
  max1 = max(vector1)  
  min1 = min(vector1)  
  lower1 = -1    
  upper1 = 1
  vector2 = lower1 + (upper1-lower1)*(vector1-min1)/(max1-min1)
  return(vector2)
}




computeNCV <- function(NOL1, NTR1) {
  NOL2 <-  1/( 1 + ( exp(-1.85*NOL1) ) ) 
  NCV1 <- NOL2^(-31.62*NTR1)
  return(NCV1)
}
#################################################################### End ##########################################################################################################################################
#################################################################### End ##########################################################################################################################################
#################################################################### End ##########################################################################################################################################
#################################################################### End ##########################################################################################################################################
#################################################################### End ##########################################################################################################################################












































## Part 2: Read the input files, so we get a n*m matrix that means it contains n rows (n DNA fragment) and m columns (m bin, 1 bin=10bp).
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################

week1 <- read.table("danpos-profile/week1/week1_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.week1.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week2 <- read.table("danpos-profile/week2/week2_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.week2.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week4 <- read.table("danpos-profile/week4/week4_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.week4.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week6 <- read.table("danpos-profile/week6/week6_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.week6.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week8 <- read.table("danpos-profile/week8/week8_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.week8.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
H3    <- read.table("danpos-profile/H3/H3_region_heatmap/Adult_Gata4_Ab_peaks.xls.gene.H3.wig.heatmap.xls",             header=TRUE,   sep="",   quote = "",   comment.char = "")
dim(week1)
dim(week2)
dim(week4)
dim(week6)
dim(week8)
dim(H3)


week1 <- as.matrix(week1[,-(1:4)])   
week2 <- as.matrix(week2[,-(1:4)])
week4 <- as.matrix(week4[,-(1:4)])
week6 <- as.matrix(week6[,-(1:4)])
week8 <- as.matrix(week8[,-(1:4)])
H3    <- as.matrix(H3[,-(1:4)])
dim(week1)
dim(week2)
dim(week4)
dim(week6)
dim(week8)
dim(H3)
numOfColumns <- ncol(H3)
numOfRows    <- nrow(H3)  
numOfColumns
numOfRows



peakSize   <- 35     ##peak 
upStream   <- 200    ##peak  up 
downStream <- 200    ##peak  down
binNum <- peakSize+upStream+downStream

midPoint   <- (numOfColumns - peakSize)/2
needIndex <- c( (midPoint-upStream+1):(midPoint+peakSize+downStream) )      
week1 <- week1[, needIndex]
week2 <- week2[, needIndex]
week4 <- week4[, needIndex]
week6 <- week6[, needIndex]
week8 <- week8[, needIndex]
H3    <- H3[, needIndex]
dim(week1)
dim(week2)
dim(week4)
dim(week6)
dim(week8)
dim(H3)
numOfColumns <- ncol(H3)
numOfRows    <- nrow(H3)  
numOfColumns
numOfRows





###  classify the matrix into 5 categaries based on rows: Lowest, Low, Intermediate, High, Highest.
oneClass <- numOfRows/5
index1 <- c( (oneClass*0):(oneClass*1) )
index2 <- c( (oneClass*1):(oneClass*2) )
index3 <- c( (oneClass*2):(oneClass*3) )
index4 <- c( (oneClass*3):(oneClass*4) )
index5 <- c( (oneClass*4):(oneClass*5) )

H3_All     <- H3
week1_All  <- week1 
week2_All  <- week2 
week4_All  <- week4
week6_All  <- week6 
week8_All  <- week8 

H3_Highest     <- H3[index1, ]
week1_Highest  <- week1[index1, ] 
week2_Highest  <- week2[index1, ] 
week4_Highest  <- week4[index1, ]
week6_Highest  <- week6[index1, ] 
week8_Highest  <- week8[index1, ] 

H3_High     <- H3[index2, ]
week1_High  <- week1[index2, ] 
week2_High  <- week2[index2, ] 
week4_High  <- week4[index2, ]
week6_High  <- week6[index2, ] 
week8_High  <- week8[index2, ] 

H3_Intermediate     <- H3[index3, ]
week1_Intermediate  <- week1[index3, ] 
week2_Intermediate  <- week2[index3, ] 
week4_Intermediate  <- week4[index3, ]
week6_Intermediate  <- week6[index3, ] 
week8_Intermediate  <- week8[index3, ] 

H3_Low     <- H3[index4, ]
week1_Low  <- week1[index4, ] 
week2_Low  <- week2[index4, ] 
week4_Low  <- week4[index4, ]
week6_Low  <- week6[index4, ] 
week8_Low  <- week8[index4, ] 

H3_Lowest     <- H3[index5, ]
week1_Lowest  <- week1[index5, ] 
week2_Lowest  <- week2[index5, ] 
week4_Lowest  <- week4[index5, ]
week6_Lowest  <- week6[index5, ] 
week8_Lowest  <- week8[index5, ] 

####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################


















































#### Part 3:  Figures about nucleosome occupancy level (NOL).
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################

NOLfigures_sumRow <- function(H3_local, week1_local, week2_local, week4_local, week6_local, week8_local, Path_local) {
  OccuT <- 2.0  
  ############################################################## all columns
  Path_temp1 = paste(Path_local, "/1-allColumns", sep="")
  system( paste("mkdir",  Path_temp1) )
  H3_local_All     <- rowMeans(H3_local)  
  week1_local_All  <- rowMeans(week1_local)
  week2_local_All  <- rowMeans(week2_local) 
  week4_local_All  <- rowMeans(week4_local)
  week6_local_All  <- rowMeans(week6_local)
  week8_local_All  <- rowMeans(week8_local) 
  H3_local_All[H3_local_All       > OccuT] <- OccuT
  week1_local_All[week1_local_All > OccuT] <- OccuT
  week2_local_All[week2_local_All > OccuT] <- OccuT
  week4_local_All[week4_local_All > OccuT] <- OccuT
  week6_local_All[week6_local_All > OccuT] <- OccuT
  week8_local_All[week8_local_All > OccuT] <- OccuT
  
  ## scatter Diagram
  H3_local_All_dataframeA     <- data.frame( xAxis = c(1:length(H3_local_All))*0.001,  yAxis = H3_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-H3.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = H3_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL (H3)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week1_local_All_dataframeA     <- data.frame( xAxis = c(1:length(week1_local_All))*0.001, yAxis = week1_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-week1.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week1_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week1)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week2_local_All_dataframeA     <- data.frame( xAxis = c(1:length(week2_local_All))*0.001, yAxis = week2_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-week2.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week2_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week2)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week4_local_All_dataframeA     <- data.frame( xAxis = c(1:length(week4_local_All))*0.001, yAxis = week4_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-week4.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week4_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week4)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week6_local_All_dataframeA     <- data.frame( xAxis = c(1:length(week6_local_All))*0.001, yAxis = week6_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-week6.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week6_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week6)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week8_local_All_dataframeA     <- data.frame( xAxis = c(1:length(week8_local_All))*0.001, yAxis = week8_local_All ) 
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-A-scatterDiagram-week8.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week8_local_All_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week8)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  # relative frequency histogram
  H3_local_All_dataframeB  <- data.frame( xAxis = H3_local_All ) 
  H3_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-H3.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=H3_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (H3)")  +  
      ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
      scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week1_local_All_dataframeB  <- data.frame( xAxis = week1_local_All ) 
  week1_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week1.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week1_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week1)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week2_local_All_dataframeB  <- data.frame( xAxis = week2_local_All ) 
  week2_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week2.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week2_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week2)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week4_local_All_dataframeB  <- data.frame( xAxis = week4_local_All ) 
  week4_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week4.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week4_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week4)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week6_local_All_dataframeB  <- data.frame( xAxis = week6_local_All ) 
  week6_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week6.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  week6_local_All_dataframeB  <- data.frame( xAxis = week6_local_All ) 
  week6_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week6-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week8_local_All_dataframeB  <- data.frame( xAxis = week8_local_All ) 
  week8_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week8.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  week8_local_All_dataframeB  <- data.frame( xAxis = week8_local_All ) 
  week8_local_All_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-B-relativeFrequencyHistogram-week8-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_All_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  
  # Box-plot and Violin plot
  sink( paste(Path_local, "/1-allColumns/1-allColumns-C-wilcoxon-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(wilcox.test(x= week2_local_All,  y = week1_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week4_local_All,  y = week2_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week6_local_All,  y = week4_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week8_local_All,  y = week6_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  sink( paste(Path_local, "/1-allColumns/1-allColumns-C-Ttest-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(t.test(x= week2_local_All,  y = week1_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week4_local_All,  y = week2_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week6_local_All,  y = week4_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week8_local_All,  y = week6_local_All,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  
  y_Axis_local_AllC  <- c( week1_local_All, week2_local_All, week4_local_All, week6_local_All, week8_local_All) 
  sampleType_local_AllC <-  c( rep("1", length(week1_local_All)), rep("2", length(week2_local_All)), rep("4", length(week4_local_All)), rep("6", length(week6_local_All)), rep("8", length(week8_local_All)) ) 
  dataframe_local_AllC <- data.frame(sampleType = sampleType_local_AllC, yAxis = y_Axis_local_AllC  )  ## the order is very important.
  dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath3 <- data.frame( x=c(3.05, 3.05, 3.95, 3.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(2.2, 2.3, 2.3, 2.2) )  
  
  sink( paste(Path_local, "/1-allColumns/1-allColumns-C-Box-plot-violinPlot.txt", sep="") )
  CairoSVG( file = paste(Path_local, "/1-allColumns/1-allColumns-C-boxplot.svg", sep=""),   width = 3, height =3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot( dataframe_local_AllC, aes(x=sampleType) ) + geom_errorbar( aes(ymin=min, ymax=max),  data=whisk(dataframe_local_AllC),   width = 0.3, size=0.2 ) +
    geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.001, size=0.2, fill="gray" ) +  
    xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "GATA4 Peaks" )  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  CairoSVG(file = paste(Path_local, "/1-allColumns/1-allColumns-C-violinPlot.svg", sep=""),  width = 3, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(dataframe_local_AllC, aes(x=sampleType) ) + geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4.0) +
    geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_local_AllC),   width = 0.0, size=0.0, colour = "black") +
    geom_boxplot( aes(y=yAxis),  width=0.2, size=0.3, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.1) + 
    stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=0.5, show_guide = FALSE) + 
    xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("GATA4 Peaks")  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  sink()





  ####################################################### up streams
  Path_temp1 = paste(Path_local, "/2-upStreams", sep="")
  system( paste("mkdir",  Path_temp1) )
  H3_local_upStreams     <- rowMeans(H3_local[, 1:upStream])  
  week1_local_upStreams  <- rowMeans(week1_local[, 1:upStream])
  week2_local_upStreams  <- rowMeans(week2_local[, 1:upStream]) 
  week4_local_upStreams  <- rowMeans(week4_local[, 1:upStream])
  week6_local_upStreams  <- rowMeans(week6_local[, 1:upStream])
  week8_local_upStreams  <- rowMeans(week8_local[, 1:upStream]) 
  H3_local_upStreams[H3_local_upStreams       > OccuT] <- OccuT
  week1_local_upStreams[week1_local_upStreams > OccuT] <- OccuT
  week2_local_upStreams[week2_local_upStreams > OccuT] <- OccuT
  week4_local_upStreams[week4_local_upStreams > OccuT] <- OccuT
  week6_local_upStreams[week6_local_upStreams > OccuT] <- OccuT
  week8_local_upStreams[week8_local_upStreams > OccuT] <- OccuT
  
  ## scatter Diagram
  H3_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(H3_local_upStreams))*0.001,  yAxis = H3_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-H3.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = H3_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL (H3)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week1_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(week1_local_upStreams))*0.001, yAxis = week1_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-week1.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week1_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week1)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week2_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(week2_local_upStreams))*0.001, yAxis = week2_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-week2.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week2_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week2)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week4_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(week4_local_upStreams))*0.001, yAxis = week4_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-week4.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week4_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week4)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week6_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(week6_local_upStreams))*0.001, yAxis = week6_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-week6.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week6_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week6)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week8_local_upStreams_dataframeA     <- data.frame( xAxis = c(1:length(week8_local_upStreams))*0.001, yAxis = week8_local_upStreams ) 
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-A-scatterDiagram-week8.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week8_local_upStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week8)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  # relative frequency histogram
  H3_local_upStreams_dataframeB  <- data.frame( xAxis = H3_local_upStreams ) 
  H3_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-H3.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=H3_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (H3)")  +  
      ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
      scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week1_local_upStreams_dataframeB  <- data.frame( xAxis = week1_local_upStreams ) 
  week1_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week1.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week1_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week1)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week2_local_upStreams_dataframeB  <- data.frame( xAxis = week2_local_upStreams ) 
  week2_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week2.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week2_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week2)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week4_local_upStreams_dataframeB  <- data.frame( xAxis = week4_local_upStreams ) 
  week4_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week4.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week4_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week4)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week6_local_upStreams_dataframeB  <- data.frame( xAxis = week6_local_upStreams ) 
  week6_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week6.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  week6_local_upStreams_dataframeB  <- data.frame( xAxis = week6_local_upStreams ) 
  week6_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week6-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week8_local_upStreams_dataframeB  <- data.frame( xAxis = week8_local_upStreams ) 
  week8_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week8.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  week8_local_upStreams_dataframeB  <- data.frame( xAxis = week8_local_upStreams ) 
  week8_local_upStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-B-relativeFrequencyHistogram-week8-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_upStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  
  # Box-plot and Violin plot
  sink( paste(Path_local, "/2-upStreams/2-upStreams-C-wilcoxon-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(wilcox.test(x= week2_local_upStreams,  y = week1_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week4_local_upStreams,  y = week2_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week6_local_upStreams,  y = week4_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week8_local_upStreams,  y = week6_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  sink( paste(Path_local, "/2-upStreams/2-upStreams-C-Ttest-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(t.test(x= week2_local_upStreams,  y = week1_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week4_local_upStreams,  y = week2_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week6_local_upStreams,  y = week4_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week8_local_upStreams,  y = week6_local_upStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  
  y_Axis_local_upStreamsC  <- c( week1_local_upStreams, week2_local_upStreams, week4_local_upStreams, week6_local_upStreams, week8_local_upStreams) 
  sampleType_local_upStreamsC <-  c( rep("1", length(week1_local_upStreams)), rep("2", length(week2_local_upStreams)), rep("4", length(week4_local_upStreams)), rep("6", length(week6_local_upStreams)), rep("8", length(week8_local_upStreams)) ) 
  dataframe_local_upStreamsC <- data.frame(sampleType = sampleType_local_upStreamsC, yAxis = y_Axis_local_upStreamsC  )  ## the order is very important.
  dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath3 <- data.frame( x=c(3.05, 3.05, 3.95, 3.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(2.2, 2.3, 2.3, 2.2) )  
  
  sink( paste(Path_local, "/2-upStreams/2-upStreams-C-Box-plot-violinPlot.txt", sep="") )
  CairoSVG( file = paste(Path_local, "/2-upStreams/2-upStreams-C-boxplot.svg", sep=""),   width = 3, height =3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot( dataframe_local_upStreamsC, aes(x=sampleType) ) + geom_errorbar( aes(ymin=min, ymax=max),  data=whisk(dataframe_local_upStreamsC),   width = 0.3, size=0.2 ) +
    geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.001, size=0.2, fill="gray" ) +  
    xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "GATA4 Peaks" )  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  CairoSVG(file = paste(Path_local, "/2-upStreams/2-upStreams-C-violinPlot.svg", sep=""),  width = 3, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(dataframe_local_upStreamsC, aes(x=sampleType) ) + geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4.0) +
    geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_local_upStreamsC),   width = 0.0, size=0.0, colour = "black") +
    geom_boxplot( aes(y=yAxis),  width=0.2, size=0.3, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.1) + 
    stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=0.5, show_guide = FALSE) + 
    xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("GATA4 Peaks")  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  sink()
 



  ####################################################### peaks
  Path_temp1 = paste(Path_local, "/3-peaks", sep="")
  system( paste("mkdir",  Path_temp1) )
  H3_local_peaks     <- rowMeans(H3_local[, (upStream+1):(upStream+peakSize)])  
  week1_local_peaks  <- rowMeans(week1_local[, (upStream+1):(upStream+peakSize)])
  week2_local_peaks  <- rowMeans(week2_local[, (upStream+1):(upStream+peakSize)]) 
  week4_local_peaks  <- rowMeans(week4_local[, (upStream+1):(upStream+peakSize)])
  week6_local_peaks  <- rowMeans(week6_local[, (upStream+1):(upStream+peakSize)])
  week8_local_peaks  <- rowMeans(week8_local[, (upStream+1):(upStream+peakSize)]) 
  H3_local_peaks[H3_local_peaks       > OccuT] <- OccuT
  week1_local_peaks[week1_local_peaks > OccuT] <- OccuT
  week2_local_peaks[week2_local_peaks > OccuT] <- OccuT
  week4_local_peaks[week4_local_peaks > OccuT] <- OccuT
  week6_local_peaks[week6_local_peaks > OccuT] <- OccuT
  week8_local_peaks[week8_local_peaks > OccuT] <- OccuT
  
  ## scatter Diagram
  H3_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(H3_local_peaks))*0.001,  yAxis = H3_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-H3.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = H3_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL (H3)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week1_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(week1_local_peaks))*0.001, yAxis = week1_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-week1.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week1_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week1)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week2_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(week2_local_peaks))*0.001, yAxis = week2_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-week2.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week2_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week2)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week4_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(week4_local_peaks))*0.001, yAxis = week4_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-week4.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week4_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week4)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week6_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(week6_local_peaks))*0.001, yAxis = week6_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-week6.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week6_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week6)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week8_local_peaks_dataframeA     <- data.frame( xAxis = c(1:length(week8_local_peaks))*0.001, yAxis = week8_local_peaks ) 
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-A-scatterDiagram-week8.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week8_local_peaks_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week8)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  # relative frequency histogram
  H3_local_peaks_dataframeB  <- data.frame( xAxis = H3_local_peaks ) 
  H3_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-H3.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=H3_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (H3)")  +  
      ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
      scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week1_local_peaks_dataframeB  <- data.frame( xAxis = week1_local_peaks ) 
  week1_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week1.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week1_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week1)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week2_local_peaks_dataframeB  <- data.frame( xAxis = week2_local_peaks ) 
  week2_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week2.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week2_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week2)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week4_local_peaks_dataframeB  <- data.frame( xAxis = week4_local_peaks ) 
  week4_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week4.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week4_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week4)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week6_local_peaks_dataframeB  <- data.frame( xAxis = week6_local_peaks ) 
  week6_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week6.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  week6_local_peaks_dataframeB  <- data.frame( xAxis = week6_local_peaks ) 
  week6_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week6-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week8_local_peaks_dataframeB  <- data.frame( xAxis = week8_local_peaks ) 
  week8_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week8.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  week8_local_peaks_dataframeB  <- data.frame( xAxis = week8_local_peaks ) 
  week8_local_peaks_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-B-relativeFrequencyHistogram-week8-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_peaks_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  
  # Box-plot and Violin plot
  sink( paste(Path_local, "/3-peaks/3-peaks-C-wilcoxon-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(wilcox.test(x= week2_local_peaks,  y = week1_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week4_local_peaks,  y = week2_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week6_local_peaks,  y = week4_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week8_local_peaks,  y = week6_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  sink( paste(Path_local, "/3-peaks/3-peaks-C-Ttest-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(t.test(x= week2_local_peaks,  y = week1_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week4_local_peaks,  y = week2_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week6_local_peaks,  y = week4_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week8_local_peaks,  y = week6_local_peaks,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  
  y_Axis_local_peaksC  <- c( week1_local_peaks, week2_local_peaks, week4_local_peaks, week6_local_peaks, week8_local_peaks) 
  sampleType_local_peaksC <-  c( rep("1", length(week1_local_peaks)), rep("2", length(week2_local_peaks)), rep("4", length(week4_local_peaks)), rep("6", length(week6_local_peaks)), rep("8", length(week8_local_peaks)) ) 
  dataframe_local_peaksC <- data.frame(sampleType = sampleType_local_peaksC, yAxis = y_Axis_local_peaksC  )  ## the order is very important.
  dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath3 <- data.frame( x=c(3.05, 3.05, 3.95, 3.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(2.2, 2.3, 2.3, 2.2) )  
  
  sink( paste(Path_local, "/3-peaks/3-peaks-C-Box-plot-violinPlot.txt", sep="") )
  CairoSVG( file = paste(Path_local, "/3-peaks/3-peaks-C-boxplot.svg", sep=""),   width = 3, height =3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot( dataframe_local_peaksC, aes(x=sampleType) ) + geom_errorbar( aes(ymin=min, ymax=max),  data=whisk(dataframe_local_peaksC),   width = 0.3, size=0.2 ) +
    geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.001, size=0.2, fill="gray" ) +  
    xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "GATA4 Peaks" )  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  CairoSVG(file = paste(Path_local, "/3-peaks/3-peaks-C-violinPlot.svg", sep=""),  width = 3, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(dataframe_local_peaksC, aes(x=sampleType) ) + geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4.0) +
    geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_local_peaksC),   width = 0.0, size=0.0, colour = "black") +
    geom_boxplot( aes(y=yAxis),  width=0.2, size=0.3, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.1) + 
    stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=0.5, show_guide = FALSE) + 
    xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("GATA4 Peaks")  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  sink()




  ####################################################### downStreams
  Path_temp1 = paste(Path_local, "/4-downStreams", sep="")
  system( paste("mkdir",  Path_temp1) )
  H3_local_downStreams     <- rowMeans(H3_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)])  
  week1_local_downStreams  <- rowMeans(week1_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)])
  week2_local_downStreams  <- rowMeans(week2_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)]) 
  week4_local_downStreams  <- rowMeans(week4_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)])
  week6_local_downStreams  <- rowMeans(week6_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)])
  week8_local_downStreams  <- rowMeans(week8_local[, (upStream+peakSize+1):(upStream+peakSize+downStream)]) 
  H3_local_downStreams[H3_local_downStreams       > OccuT] <- OccuT
  week1_local_downStreams[week1_local_downStreams > OccuT] <- OccuT
  week2_local_downStreams[week2_local_downStreams > OccuT] <- OccuT
  week4_local_downStreams[week4_local_downStreams > OccuT] <- OccuT
  week6_local_downStreams[week6_local_downStreams > OccuT] <- OccuT
  week8_local_downStreams[week8_local_downStreams > OccuT] <- OccuT
  
  ## scatter Diagram
  H3_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(H3_local_downStreams))*0.001,  yAxis = H3_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-H3.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = H3_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL (H3)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week1_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(week1_local_downStreams))*0.001, yAxis = week1_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-week1.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week1_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week1)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week2_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(week2_local_downStreams))*0.001, yAxis = week2_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-week2.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week2_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week2)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week4_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(week4_local_downStreams))*0.001, yAxis = week4_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-week4.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week4_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week4)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week6_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(week6_local_downStreams))*0.001, yAxis = week6_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-week6.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week6_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week6)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  week8_local_downStreams_dataframeA     <- data.frame( xAxis = c(1:length(week8_local_downStreams))*0.001, yAxis = week8_local_downStreams ) 
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-A-scatterDiagram-week8.svg", sep=""),   width = 2.5,   height = 3,  onefile = TRUE,   bg = "white",   pointsize = 1 )
  FigureTemp <- ggplot( data = week8_local_downStreams_dataframeA, aes(x = xAxis, y = yAxis) ) + geom_point(size=0.1) +  ylim(0, OccuT) +
    xlab("Peaks (1000 peaks)") +   ylab("NOL") +   ggtitle("Distribution of NOL  (week8)") + pTheme 
  print(FigureTemp)
  dev.off() 
  
  # relative frequency histogram
  H3_local_downStreams_dataframeB  <- data.frame( xAxis = H3_local_downStreams ) 
  H3_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-H3.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=H3_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (H3)")  +  
      ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
      scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week1_local_downStreams_dataframeB  <- data.frame( xAxis = week1_local_downStreams ) 
  week1_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week1.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week1_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week1)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week2_local_downStreams_dataframeB  <- data.frame( xAxis = week2_local_downStreams ) 
  week2_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week2.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week2_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week2)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week4_local_downStreams_dataframeB  <- data.frame( xAxis = week4_local_downStreams ) 
  week4_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week4.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week4_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week4)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week6_local_downStreams_dataframeB  <- data.frame( xAxis = week6_local_downStreams ) 
  week6_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week6.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  week6_local_downStreams_dataframeB  <- data.frame( xAxis = week6_local_downStreams ) 
  week6_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week6-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week6_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week6)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp)
  dev.off() 
  
  week8_local_downStreams_dataframeB  <- data.frame( xAxis = week8_local_downStreams ) 
  week8_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week8.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    ylim(0, 0.5) +  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  week8_local_downStreams_dataframeB  <- data.frame( xAxis = week8_local_downStreams ) 
  week8_local_downStreams_dataframeB$xAxis[1] <- OccuT
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-B-relativeFrequencyHistogram-week8-ynolimit.svg", sep=""),   width = 2.5, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(data=week8_local_downStreams_dataframeB, aes(x=xAxis) )  +  xlab("NOL") + ylab("Relative Frequency") +  ggtitle("Distribution of NOL (week8)")  +  
    geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
    scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, OccuT), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + pTheme  
  print(FigureTemp) 
  dev.off() 
  
  # Box-plot and Violin plot
  sink( paste(Path_local, "/4-downStreams/4-downStreams-C-wilcoxon-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(wilcox.test(x= week2_local_downStreams,  y = week1_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week4_local_downStreams,  y = week2_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week6_local_downStreams,  y = week4_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(wilcox.test(x= week8_local_downStreams,  y = week6_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  sink( paste(Path_local, "/4-downStreams/4-downStreams-C-Ttest-paired.txt", sep="") )
  print("##################################################################################################################################")
  print(t.test(x= week2_local_downStreams,  y = week1_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week4_local_downStreams,  y = week2_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week6_local_downStreams,  y = week4_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  print("##################################################################################################################################")
  print(t.test(x= week8_local_downStreams,  y = week6_local_downStreams,    alternative = "two.sided",    mu = 0,    paired = TRUE,    var.equal = FALSE,   conf.level = 0.95))
  sink()
  
  y_Axis_local_downStreamsC  <- c( week1_local_downStreams, week2_local_downStreams, week4_local_downStreams, week6_local_downStreams, week8_local_downStreams) 
  sampleType_local_downStreamsC <-  c( rep("1", length(week1_local_downStreams)), rep("2", length(week2_local_downStreams)), rep("4", length(week4_local_downStreams)), rep("6", length(week6_local_downStreams)), rep("8", length(week8_local_downStreams)) ) 
  dataframe_local_downStreamsC <- data.frame(sampleType = sampleType_local_downStreamsC, yAxis = y_Axis_local_downStreamsC  )  ## the order is very important.
  dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath3 <- data.frame( x=c(3.05, 3.05, 3.95, 3.95),  y=c(2.2, 2.3, 2.3, 2.2) )  
  dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(2.2, 2.3, 2.3, 2.2) )  
  
  sink( paste(Path_local, "/4-downStreams/4-downStreams-C-Box-plot-violinPlot.txt", sep="") )
  CairoSVG( file = paste(Path_local, "/4-downStreams/4-downStreams-C-boxplot.svg", sep=""),   width = 3, height =3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot( dataframe_local_downStreamsC, aes(x=sampleType) ) + geom_errorbar( aes(ymin=min, ymax=max),  data=whisk(dataframe_local_downStreamsC),   width = 0.3, size=0.2 ) +
    geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.001, size=0.2, fill="gray" ) +  
    xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "GATA4 Peaks" )  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  CairoSVG(file = paste(Path_local, "/4-downStreams/4-downStreams-C-violinPlot.svg", sep=""),  width = 3, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
  FigureTemp <- ggplot(dataframe_local_downStreamsC, aes(x=sampleType) ) + geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4.0) +
    geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_local_downStreamsC),   width = 0.0, size=0.0, colour = "black") +
    geom_boxplot( aes(y=yAxis),  width=0.2, size=0.3, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.1) + 
    stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=0.5, show_guide = FALSE) + 
    xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("GATA4 Peaks")  + pTheme + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=2.4, label="p<3e-16", size=2.2) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=2.4, label="p<3e-16", size=2.2) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=2.4, label="p<3e-16", size=2.2)
  print(FigureTemp) 
  dev.off() 
  sink()
     
}


system("mkdir  Figures")
system("mkdir  Figures/1-NOL")

system("mkdir  Figures/1-NOL/1-sumRows-allRows")
NOLfigures_sumRow(H3_All, week1_All, week2_All, week4_All, week6_All, week8_All, "Figures/1-NOL/1-sumRows-allRows")


system("mkdir  Figures/1-NOL/2-sumRows-Highest")
NOLfigures_sumRow(H3_Highest, week1_Highest, week2_Highest, week4_Highest, week6_Highest, week8_Highest, "Figures/1-NOL/2-sumRows-Highest")
 

system("mkdir  Figures/1-NOL/3-sumRows-High")
NOLfigures_sumRow(H3_High, week1_High, week2_High, week4_High, week6_High, week8_High, "Figures/1-NOL/3-sumRows-High")


system("mkdir  Figures/1-NOL/4-sumRows-Intermediate")
NOLfigures_sumRow(H3_Intermediate, week1_Intermediate, week2_Intermediate, week4_Intermediate, week6_Intermediate, week8_Intermediate, "Figures/1-NOL/4-sumRows-Intermediate")
 

system("mkdir  Figures/1-NOL/5-sumRows-Low")
NOLfigures_sumRow(H3_Low, week1_Low, week2_Low, week4_Low, week6_Low, week8_Low, "Figures/1-NOL/5-sumRows-Low")
 

system("mkdir  Figures/1-NOL/6-sumRows-Lowest")
NOLfigures_sumRow(H3_Lowest, week1_Lowest, week2_Lowest, week4_Lowest, week6_Lowest, week8_Lowest, "Figures/1-NOL/6-sumRows-Lowest")
 










NOLfigures_sumColumn <- function(H3_local, week1_local, week2_local, week4_local, week6_local, week8_local, Path_local) {  
    H3_local_All     <- colMeans(H3_local)  
    week1_local_All  <- colMeans(week1_local)
    week2_local_All  <- colMeans(week2_local) 
    week4_local_All  <- colMeans(week4_local)
    week6_local_All  <- colMeans(week6_local)
    week8_local_All  <- colMeans(week8_local) 
 
    sink( paste(Path_local, "/1-A-wilcoxon-test-paired.txt", sep="") )
        print("##################################################################################################################################")
        print( wilcox.test( x= week2_local_All,  y = week1_local_All,  alternative = "two.sided",   mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95 ) )
        print("##################################################################################################################################")
        print( wilcox.test( x= week4_local_All,  y = week2_local_All,  alternative = "two.sided",   mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95 ) )
        print("##################################################################################################################################")
        print( wilcox.test( x= week6_local_All,  y = week4_local_All,  alternative = "two.sided",   mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95 ) )
        print("##################################################################################################################################")
        print( wilcox.test( x= week8_local_All,  y = week6_local_All,  alternative = "two.sided",   mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95 ) )
    sink()
    sink( paste(Path_local, "/1-A-wilcoxon-test-unpaired.txt", sep="") )
        print("##################################################################################################################################")
        print( wilcox.test(x= week2_local_All, y = week1_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( wilcox.test(x= week4_local_All, y = week2_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( wilcox.test(x= week6_local_All, y = week4_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( wilcox.test(x= week8_local_All, y = week6_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
    sink()
    sink( paste(Path_local, "/1-A-student-Ttest-paired.txt", sep="")  )
        print("##################################################################################################################################")
        print( t.test(x= week2_local_All, y = week1_local_All, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week4_local_All, y = week2_local_All, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week6_local_All, y = week4_local_All, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week8_local_All, y = week6_local_All, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95) )
    sink()
    sink( paste(Path_local, "/1-A-student-Ttest-unpaired.txt", sep="")  )
        print("##################################################################################################################################")
        print( t.test(x= week2_local_All, y = week1_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week4_local_All, y = week2_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week6_local_All, y = week4_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("##################################################################################################################################")
        print( t.test(x= week8_local_All, y = week6_local_All, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
    sink()
  
    Position_local_All <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
    week1_local_All_frame <-  ksmooth(x=Position_local_All,   y=week1_local_All,     kernel = "normal",   bandwidth = 0.1)
    week2_local_All_frame <-  ksmooth(x=Position_local_All,   y=week2_local_All,     kernel = "normal",   bandwidth = 0.1)
    week4_local_All_frame <-  ksmooth(x=Position_local_All,   y=week4_local_All,     kernel = "normal",   bandwidth = 0.1)
    week6_local_All_frame <-  ksmooth(x=Position_local_All,   y=week6_local_All,     kernel = "normal",   bandwidth = 0.1)
    week8_local_All_frame <-  ksmooth(x=Position_local_All,   y=week8_local_All,     kernel = "normal",   bandwidth = 0.1)
    
    week1_local_All_a <- week1_local_All_frame$y
    week2_local_All_a <- week2_local_All_frame$y
    week4_local_All_a <- week4_local_All_frame$y
    week6_local_All_a <- week6_local_All_frame$y
    week8_local_All_a <- week8_local_All_frame$y
    x_Axis_local_All   <- c( Position_local_All, Position_local_All,   Position_local_All,    Position_local_All,  Position_local_All)                       
    y_Axis_local_All   <- c( week1_local_All_a, week2_local_All_a, week4_local_All_a,  week6_local_All_a, week8_local_All_a )  
    sampleType_local_All <- c( rep("week 1", binNum), rep("week 2", binNum),  rep("week 4", binNum),   rep("week 6", binNum), rep("week 8", binNum)  )     
    dataframe_local_All  <- data.frame(xAxis = x_Axis_local_All,  yAxis = y_Axis_local_All,  sampleType = sampleType_local_All) 
    #####################################
    CairoSVG(file = paste(Path_local, "/2-B-occupancy.svg", sep=""),   width = 4,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
    FigureTemp <- ggplot( dataframe_local_All,  aes(x=xAxis, y=yAxis,  color=sampleType) )  +   
        xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("GATA4 Peaks") + 
        scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
        geom_line(size=0.5) + 
        geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
        scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
        pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
    print( FigureTemp ) 
    dev.off() 
    #######################################
  
    #####################################
    CairoSVG(file = paste(Path_local, "/2-B-occupancy-scaled.svg", sep=""),   width = 4,  height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
    FigureTemp <- ggplot( dataframe_local_All,  aes(x=xAxis, y=yAxis,  color=sampleType) )  +   
        xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("GATA4 Peaks") + 
        scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
        geom_line(size=0.5) + ylim(0.0, 1.0) +
        geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
        scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
        pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
    print( FigureTemp ) 
    dev.off() 
    #######################################
  
  
    ##Error bar一般是standard error，即标准误，反映的是抽样引起的误差；
    ##有些时候有些人也用standard deviation，即标准差，反映的是样本数据之间的离散程度（或整齐程度）。
    ##所以看你实际需要选择。S.E.=S.D./sqrt(N-1)，这就是两者的联系。
    ##S.E.受样本数量影响很大，而S.D.则受样本数据齐性影响更大。
    week1_local_All_SEM <- apply(week1, 2, sd)/sqrt(nrow(week1)-1)   ## The standard error of the mean (SEM) 
    week2_local_All_SEM <- apply(week2, 2, sd)/sqrt(nrow(week2)-1)   ## The standard error of the mean (SEM) 
    week4_local_All_SEM <- apply(week4, 2, sd)/sqrt(nrow(week4)-1)   ## The standard error of the mean (SEM) 
    week6_local_All_SEM <- apply(week6, 2, sd)/sqrt(nrow(week6)-1)   ## The standard error of the mean (SEM) 
    week8_local_All_SEM <- apply(week8, 2, sd)/sqrt(nrow(week8)-1)   ## The standard error of the mean (SEM) 
    nonzero_local_All <- seq(from = 1,  by=10,  length.out=binNum/10)
    week1_local_All_SEM[-nonzero_local_All] <- NA
    week2_local_All_SEM[-nonzero_local_All] <- NA
    week4_local_All_SEM[-nonzero_local_All] <- NA
    week6_local_All_SEM[-nonzero_local_All] <- NA
    week8_local_All_SEM[-nonzero_local_All] <- NA
    SEM_local_All <- c( week1_local_All_SEM, week2_local_All_SEM, week4_local_All_SEM,  week6_local_All_SEM, week8_local_All_SEM ) 
    #week1_local_All_SD <- apply(week1, 2, sd)   ## standard deviation 
    #week2_local_All_SD <- apply(week2, 2, sd)   ## standard deviation 
    #week4_local_All_SD <- apply(week4, 2, sd)   ## standard deviation 
    #week6_local_All_SD <- apply(week6, 2, sd)   ## standard deviation 
    #week8_local_All_SD <- apply(week8, 2, sd)   ## standard deviation
    #nonzero_local_All <- seq(from = 1,  by=10,  length.out=60)
    #week1_local_All_SD[-nonzero_local_All] <- NA
    #week2_local_All_SD[-nonzero_local_All] <- NA
    #week4_local_All_SD[-nonzero_local_All] <- NA
    #week6_local_All_SD[-nonzero_local_All] <- NA
    #week8_local_All_SD[-nonzero_local_All] <- NA
    #SD_local_All <- c( week1_local_All_SD, week2_local_All_SD, week4_local_All_SD,  week6_local_All_SD, week8_local_All_SD ) 
    dataframe_local_All    <- data.frame(xAxis = x_Axis_local_All,  yAxis = y_Axis_local_All,  sampleType = sampleType_local_All,  Error = SEM_local_All) 
    limits_local_All <- aes( ymax = yAxis+Error,  ymin = yAxis-Error )
    #############
    CairoSVG(file = paste(Path_local, "/3-C-occupancy-errorBar.svg", sep=""),   width = 4,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
    FigureTemp <- ggplot(dataframe_local_All, aes(x=xAxis, y=yAxis,  color=sampleType) )  +   
        xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("GATA4 Peaks") + 
        scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) + 
        geom_errorbar(limits_local_All,   width=0.03) +   
        geom_line(size=0.3) + 
        geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
        scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) + 
        pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) )  
    print( FigureTemp ) 
    dev.off() 
    ##########################################
  
    #############
    CairoSVG(file = paste(Path_local, "/3-C-occupancy-errorBar-scaled.svg", sep=""),   width = 4,  height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
    FigureTemp <- ggplot(dataframe_local_All, aes(x=xAxis, y=yAxis,  color=sampleType) )  +   
        xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("GATA4 Peaks") + 
        scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) + 
        geom_errorbar(limits_local_All,   width=0.03) +   
        geom_line(size=0.3) + ylim(0.0, 1.0) +
        geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
        scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) + 
        pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) )  
    print( FigureTemp ) 
    dev.off() 
    ##########################################
  
  

    sink( paste(Path_local, "/4-D-nucleosomeoccupancy-diff-H3.txt", sep="") )
        print( wilcox.test(x= H3_local_All [(1:peakSize)],                                                y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print( wilcox.test(x= H3_local_All[((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( wilcox.test(x= H3_local_All[(1:peakSize)],                                                  y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print( wilcox.test(x= H3_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( t.test(x= H3_local_All[ (1:peakSize)],                                                 y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print( t.test(x= H3_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( t.test(x= H3_local_All[ (1:peakSize)],                                                 y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print( t.test(x= H3_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_local_All[ ((upStream+1):(upStream+peakSize)) ],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print("################################### Up Streams ####################################################")
        print( mean( H3_local_All [(1:peakSize)]) )
        print("################################ Peaks ########################################################")
        print( mean(H3_local_All[ ((upStream+1):(upStream+peakSize))]) )
        print("################################# Down Streams #####################################################")
        print( mean(H3_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))]) )
        print("###############################################################################################")
    sink()
  
    
    sink( paste(Path_local, "/4-D-nucleosomeoccupancy-diff-week1.txt", sep="") )
        print( wilcox.test(x= week1_local_All[(1:peakSize)],                                                  y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print( wilcox.test(x= week1_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( wilcox.test(x= week1_local_All[(1:peakSize)],                                                  y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print( wilcox.test(x= week1_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( t.test(x= week1_local_All[ (1:peakSize)],                                                  y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print( t.test(x= week1_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],      y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print( t.test(x= week1_local_All[ (1:peakSize)],                                                  y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print( t.test(x= week1_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))],      y = week1_local_All[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95) )
        print("###############################################################################################")
        print("################################### Up Streams ####################################################")
        print( mean(week1_local_All [(1:peakSize)]) )
        print("################################ Peaks ########################################################")
        print( mean(week1_local_All[ ((upStream+1):(upStream+peakSize))]) )
        print("################################# Down Streams #####################################################")
        print( mean(week1_local_All[ ((upStream+downStream+1):(upStream+peakSize+downStream))]) )
        print("###############################################################################################")
    sink()
  
} 



#system("mkdir  Figures")
#system("mkdir  Figures/1-NOL")

system("mkdir  Figures/1-NOL/7-sumColumns-allRows")
NOLfigures_sumColumn(H3_All, week1_All, week2_All, week4_All, week6_All, week8_All, "Figures/1-NOL/7-sumColumns-allRows")


system("mkdir  Figures/1-NOL/8-sumColumns-Highest")
NOLfigures_sumColumn(H3_Highest, week1_Highest, week2_Highest, week4_Highest, week6_Highest, week8_Highest, "Figures/1-NOL/8-sumColumns-Highest")


system("mkdir  Figures/1-NOL/9-sumColumns-High")
NOLfigures_sumColumn(H3_High, week1_High, week2_High, week4_High, week6_High, week8_High, "Figures/1-NOL/9-sumColumns-High")


system("mkdir  Figures/1-NOL/10-sumColumns-Intermediate")
NOLfigures_sumColumn(H3_Intermediate, week1_Intermediate, week2_Intermediate, week4_Intermediate, week6_Intermediate, week8_Intermediate, "Figures/1-NOL/10-sumColumns-Intermediate")


system("mkdir  Figures/1-NOL/11-sumColumns-Low")
NOLfigures_sumColumn(H3_Low, week1_Low, week2_Low, week4_Low, week6_Low, week8_Low, "Figures/1-NOL/11-sumColumns-Low")


system("mkdir  Figures/1-NOL/12-sumColumns-Lowest")
NOLfigures_sumColumn(H3_Lowest, week1_Lowest, week2_Lowest, week4_Lowest, week6_Lowest, week8_Lowest, "Figures/1-NOL/12-sumColumns-Lowest")












system("mkdir  Figures/1-NOL/13-sumColumns-FiveCategaries")

Position_1 <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
x_Axis_FiveCategaries_1   <- c( Position_1,     Position_1,     Position_1,    Position_1,  Position_1 )                       
y_Axis_FiveCategaries_1   <- c( colMeans(H3_Highest),  colMeans(H3_High),  colMeans(H3_Intermediate), colMeans(H3_Low), colMeans(H3_Lowest) )  
sampleType_FiveCategaries_1 <- c( rep("Highest", binNum), rep("High", binNum),  rep("Intermediate", binNum),   rep("Low", binNum),   rep("Lowest", binNum)  )                            
dataframe_FiveCategaries_1  <- data.frame(xAxis = x_Axis_FiveCategaries_1,  yAxis = y_Axis_FiveCategaries_1,  sampleType = sampleType_FiveCategaries_1) 
#####################################
CairoSVG(file = "Figures/1-NOL/13-sumColumns-FiveCategaries/1-a-FiveCategaries-NOL-H3.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_FiveCategaries_1,  aes(x=xAxis, y=dataframe_FiveCategaries_1$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NOL") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("Highest"="green4",  "High"="green",  "Intermediate"="yellowgreen",  "Low"="gold", "Lowest"="gold4"),  breaks=c("Highest",  "High",  "Intermediate", "Low", "Lowest") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + 
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################


x_Axis_ThreeCategaries_1   <- c( Position_1,       Position_1,    Position_1)                       
y_Axis_ThreeCategaries_1   <- c( colMeans(H3_Highest),  colMeans(H3_Intermediate),  colMeans(H3_Lowest) )  
sampleType_ThreeCategaries_1 <- c( rep("High", binNum),  rep("Middle", binNum),    rep("Low", binNum)  )                            
dataframe_ThreeCategaries_1  <- data.frame( xAxis = x_Axis_ThreeCategaries_1,  yAxis = y_Axis_ThreeCategaries_1,  sampleType = sampleType_ThreeCategaries_1 ) 
#####################################
CairoSVG(file = "Figures/1-NOL/13-sumColumns-FiveCategaries/2-a-ThreeCategaries-NOL-H3.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_ThreeCategaries_1,  aes(x=xAxis, y=dataframe_ThreeCategaries_1$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NOL") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("High"="green4",  "Middle"="green",  "Low"="yellowgreen"),  breaks=c("High",   "Middle", "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + 
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################



Position_1 <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
x_Axis_FiveCategaries_1   <- c( Position_1,     Position_1,     Position_1,    Position_1,  Position_1 )                       
y_Axis_FiveCategaries_1   <- c( colMeans(week1_Highest),  colMeans(week1_High),  colMeans(week1_Intermediate), colMeans(week1_Low), colMeans(week1_Lowest) )  
sampleType_FiveCategaries_1 <- c( rep("Highest", binNum), rep("High", binNum),  rep("Intermediate", binNum),   rep("Low", binNum),   rep("Lowest", binNum)  )                            
dataframe_FiveCategaries_1  <- data.frame(xAxis = x_Axis_FiveCategaries_1,  yAxis = y_Axis_FiveCategaries_1,  sampleType = sampleType_FiveCategaries_1) 
#####################################
CairoSVG(file = "Figures/1-NOL/13-sumColumns-FiveCategaries/1-a-FiveCategaries-NOL-week1.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_FiveCategaries_1,  aes(x=xAxis, y=dataframe_FiveCategaries_1$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NOL") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("Highest"="green4",  "High"="green",  "Intermediate"="yellowgreen",  "Low"="gold", "Lowest"="gold4"),  breaks=c("Highest",  "High",  "Intermediate", "Low", "Lowest") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + 
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################


x_Axis_ThreeCategaries_1   <- c( Position_1,       Position_1,    Position_1)                       
y_Axis_ThreeCategaries_1   <- c( colMeans(week1_Highest),  colMeans(week1_Intermediate),  colMeans(week1_Lowest) )  
sampleType_ThreeCategaries_1 <- c( rep("High", binNum),  rep("Middle", binNum),    rep("Low", binNum)  )                            
dataframe_ThreeCategaries_1  <- data.frame( xAxis = x_Axis_ThreeCategaries_1,  yAxis = y_Axis_ThreeCategaries_1,  sampleType = sampleType_ThreeCategaries_1 ) 
#####################################
CairoSVG(file = "Figures/1-NOL/13-sumColumns-FiveCategaries/2-a-ThreeCategaries-NOL-week1.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_ThreeCategaries_1,  aes(x=xAxis, y=dataframe_ThreeCategaries_1$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NOL") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("High"="green4",  "Middle"="green",  "Low"="yellowgreen"),  breaks=c("High",   "Middle", "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + 
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################












#######################################################################################################################
system("mkdir  Figures/1-NOL/14-H3NOL-PeaksHeight")
PeaksHeightFile <- "/home/yongp/Desktop/H2BGFPdanpos2/0-allRegions/4-Adult_Gata4/Adult_Gata4_Ab_peaks.xls"
PeaksHeight <- read.table(PeaksHeightFile,    header=FALSE,   sep="",   quote = "",   comment.char = "")
PeaksHeight_1 <- as.vector(PeaksHeight[-1,5])
H3_occpancy_1 <- rowMeans( H3_All[, (upStream+1):(upStream+peakSize)] )
length(PeaksHeight_1)
length(H3_occpancy_1)

length(PeaksHeight_1[PeaksHeight_1>35])
PeaksHeight_1[PeaksHeight_1>35] <- 35
length(H3_occpancy_1[H3_occpancy_1>4])
H3_occpancy_1[H3_occpancy_1>4] <- 4
              
OccPeakFrame <- data.frame(peak <- PeaksHeight_1, H3occ <- H3_occpancy_1)

sink("Figures/1-NOL/14-H3NOL-PeaksHeight/1-A-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
  print("Pearson product-moment correlation coefficient:")
  corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
  print("Spearman's rank correlation coefficient or Spearman's rho:")
  corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
  print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
  corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
  mine(x=H3_occpancy_1, y = PeaksHeight_1,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(H3_occpancy_1) + min(H3_occpancy_1) )/2
y_position <- max(PeaksHeight_1) + 2
regression_A <- lm(PeaksHeight_1 ~ H3_occpancy_1)
dataframe_A <- data.frame( xAxis=H3_occpancy_1, yAxis=PeaksHeight_1 )

CairoSVG(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/1-A-H3occupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/1-A-H3occupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/1-A-H3occupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/1-A-H3occupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 








PeaksHeight_2 <- log(PeaksHeight_1)
H3_occpancy_2 <- H3_occpancy_1
OccPeakFrame2 <- data.frame(peak <- PeaksHeight_2, H3occ <- H3_occpancy_2)

sink("Figures/1-NOL/14-H3NOL-PeaksHeight/2-B-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
print("Pearson product-moment correlation coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
mine(x=H3_occpancy_2, y = PeaksHeight_2,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(H3_occpancy_2) + min(H3_occpancy_2) )/2
y_position <- max(PeaksHeight_2) + 2
regression_A <- lm(PeaksHeight_2 ~ H3_occpancy_2)
dataframe_A <- data.frame( xAxis=H3_occpancy_2, yAxis=PeaksHeight_2 )

CairoSVG(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/2-B-H3occupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/2-B-H3occupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/2-B-H3occupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/1-NOL/14-H3NOL-PeaksHeight/2-B-H3occupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 














#######################################################################################################################
system("mkdir  Figures/1-NOL/15-week1NOL-PeaksHeight")
PeaksHeightFile <- "/home/yongp/Desktop/H2BGFPdanpos2/0-allRegions/4-Adult_Gata4/Adult_Gata4_Ab_peaks.xls"
PeaksHeight <- read.table(PeaksHeightFile,    header=FALSE,   sep="",   quote = "",   comment.char = "")
PeaksHeight_1 <- as.vector(PeaksHeight[-1,5])
week1_occpancy_1 <- rowMeans( week1_All[, (upStream+1):(upStream+peakSize)] )
length(PeaksHeight_1)
length(week1_occpancy_1)

length(PeaksHeight_1[PeaksHeight_1>35])
PeaksHeight_1[PeaksHeight_1>35] <- 35
length(week1_occpancy_1[week1_occpancy_1>4])
week1_occpancy_1[week1_occpancy_1>4] <- 4

OccPeakFrame <- data.frame(peak <- PeaksHeight_1, week1occ <- week1_occpancy_1)

sink("Figures/1-NOL/15-week1NOL-PeaksHeight/1-A-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
print("Pearson product-moment correlation coefficient:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
mine(x=week1_occpancy_1, y = PeaksHeight_1,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(week1_occpancy_1) + min(week1_occpancy_1) )/2
y_position <- max(PeaksHeight_1) + 2
regression_A <- lm(PeaksHeight_1 ~ week1_occpancy_1)
dataframe_A <- data.frame( xAxis=week1_occpancy_1, yAxis=PeaksHeight_1 )

CairoSVG(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/1-A-week1occupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/1-A-week1occupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/1-A-week1occupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/1-A-week1occupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 








PeaksHeight_2 <- log(PeaksHeight_1)
week1_occpancy_2 <- week1_occpancy_1
OccPeakFrame2 <- data.frame(peak <- PeaksHeight_2, week1occ <- week1_occpancy_2)

sink("Figures/1-NOL/15-week1NOL-PeaksHeight/2-B-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
print("Pearson product-moment correlation coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
mine(x=week1_occpancy_2, y = PeaksHeight_2,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(week1_occpancy_2) + min(week1_occpancy_2) )/2
y_position <- max(PeaksHeight_2) + 2
regression_A <- lm(PeaksHeight_2 ~ week1_occpancy_2)
dataframe_A <- data.frame( xAxis=week1_occpancy_2, yAxis=PeaksHeight_2 )

CairoSVG(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/2-B-week1occupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/2-B-week1occupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/2-B-week1occupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/1-NOL/15-week1NOL-PeaksHeight/2-B-week1occupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 




####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################
####################################################################  End    ##########################################################################################################################################

















































## Part 4:  Figures about nucleosome turnover rate (NTR).
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################
#################################################################### Start ##########################################################################################################################################

NTRfigures <- function(H3_local, week1_local, week2_local, week4_local, week6_local, week8_local, Path_local) {  
  H3_local_All     <- H3_local  
  week1_local_All  <- week1_local
  week2_local_All  <- week2_local
  week4_local_All  <- week4_local
  week6_local_All  <- week6_local
  week8_local_All  <- week8_local     
  week1_2  <- colMeans(week1_local_All,  na.rm = TRUE) 
  week2_2  <- colMeans(week2_local_All,  na.rm = TRUE) 
  week4_2  <- colMeans(week4_local_All,  na.rm = TRUE)
  week6_2  <- colMeans(week6_local_All,  na.rm = TRUE) 
  week8_2  <- colMeans(week8_local_All,  na.rm = TRUE) 
  turnoverDis_2 <- c()
  sink(  paste(Path_local, "/1-A-LinearRegressionModel.txt", sep="") )
  for ( i in 1:length(week1_2) ) {
    tur <- turnoverRate(week1_2[i], week2_2[i], week4_2[i], week6_2[i], week8_2[i])
    turnoverDis_2 <- c(turnoverDis_2, tur)
    print("***********************************************")
    print(week1_2[i])
    print(week2_2[i])
    print(week4_2[i])
    print(week6_2[i])
    print(week8_2[i])
    print("***********************************************")
  }
  sink()
  length(turnoverDis_2)
  halfLifeDis_2 <- log(2)/turnoverDis_2
  
  binNum_2 = binNum
  Position_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum_2)
  xVar_2 <- c(1, 2, 4, 6, 8)
  turnoverDis_2_frame2 <- ksmooth(x=Position_2,   y=turnoverDis_2,     kernel = "normal",   bandwidth = 0.1)
  turnoverDis_2_2a     <- turnoverDis_2_frame2$y
  dataframe_2a         <- data.frame(xAxis = Position_2, yAxis = turnoverDis_2_2a) 
  write.table( turnoverDis_2,  file = paste(Path_local, "/2-B-turnoverDis.txt", sep=""),  append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
  write.table( halfLifeDis_2,  file = paste(Path_local, "/2-B-halfLifeDis.txt", sep=""),  append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
  CairoSVG(file = paste(Path_local, "/3-C-turnoverDis.svg", sep=""),    width = 3,  height = 2.5,   onefile = TRUE, bg = "white",  pointsize = 1 )
  figuresTemp <- ggplot(data=dataframe_2a, aes(x=xAxis, y=yAxis) )  +   
    xlab("Relative Distance (kb)") + ylab("NTR") + ggtitle("GATA4 Peaks") + 
    geom_line(size=0.8) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
    scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
    pTheme
  print(figuresTemp)
  dev.off() 
  
  halfLifeDis_frame3 <-  ksmooth(x=Position_2,   y=halfLifeDis_2,     kernel = "normal",   bandwidth = 0.2)
  halfLifeDis_2b     <- halfLifeDis_frame3$y
  dataframe_2b       <- data.frame(xAxis = Position_2, yAxis = halfLifeDis_2b) 
  CairoSVG(file = paste(Path_local, "/3-C-halfLifeDis.svg", sep=""),    width = 3,  height = 2.5,   onefile = TRUE, bg = "white",  pointsize = 1 )
  figuresTemp <- ggplot(data=dataframe_2b, aes(x=xAxis, y=yAxis) )  +   
    xlab("Relative Distance (kb)") + ylab("Half-life (weeks)") + ggtitle("GATA4 Peaks") +
    geom_line(size=0.8) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
    scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
    pTheme
  print(figuresTemp)
  dev.off() 
  
  sink( paste(Path_local, "/4-D-NTRdiff.txt", sep="") )
  print( wilcox.test(x= turnoverDis_2[ (1:peakSize)],                                                           y = turnoverDis_2[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,    var.equal = TRUE,   conf.level = 0.95) )
  print( wilcox.test(x= turnoverDis_2[ (upStream + downStream + 1):(upStream + peakSize + downStream) ],        y = turnoverDis_2[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,   var.equal = FALSE,  conf.level = 0.95) )
  print( t.test(     x= turnoverDis_2[ (1:peakSize)],                                                           y = turnoverDis_2[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = TRUE,    var.equal = TRUE,   conf.level = 0.95) )
  print( t.test(     x= turnoverDis_2[ (upStream + downStream + 1):(upStream + peakSize + downStream) ],        y = turnoverDis_2[ ((upStream+1):(upStream+peakSize))],     alternative = "two.sided",  mu = 0,  paired = FALSE,   var.equal = FALSE,  conf.level = 0.95) )
  print("###############################################################################################")
  print("################################ up streams #################################################")
  print( mean(turnoverDis_2[ (1:peakSize)]) )
  print("################################# peaks   ###################################################")
  print( mean(turnoverDis_2[ ((upStream+1):(upStream+peakSize))]) )
  print("################################## down streams  #####################################################")
  print( mean(turnoverDis_2[ (upStream + downStream + 1):(upStream + peakSize + downStream) ]) )
  print("###############################################################################################")
  sink()
  
  week1_2A <- mean(week1_2[(upStream+1):(upStream+peakSize)])  ##Peaks
  week2_2A <- mean(week2_2[(upStream+1):(upStream+peakSize)])
  week4_2A <- mean(week4_2[(upStream+1):(upStream+peakSize)])
  week6_2A <- mean(week6_2[(upStream+1):(upStream+peakSize)])
  week8_2A <- mean(week8_2[(upStream+1):(upStream+peakSize)])
  vector_occupancy_2A <- c(week1_2A, week2_2A, week4_2A, week6_2A, week8_2A)
  vector_halflife_y_2A <- log(vector_occupancy_2A)
  vector_halflife_x_2A <- c(1, 2, 4, 6, 8)
  dataframe_2A  <- data.frame(xAxis = vector_halflife_x_2A, yAxis = vector_halflife_y_2A) 
  regression_2A <- lm(vector_halflife_y_2A ~ vector_halflife_x_2A)
  sink( paste(Path_local, "/5-1-regression_Peaks.txt", sep="")  )
  print( summary(regression_2A) )
  sink()
  
  week1_2B <- mean(week1_2)  ## Peaks±2000bp
  week2_2B <- mean(week2_2)
  week4_2B <- mean(week4_2)
  week6_2B <- mean(week6_2)
  week8_2B <- mean(week8_2)
  vector_occupancy_2B <- c(week1_2B, week2_2B, week4_2B, week6_2B, week8_2B)
  vector_halflife_y_2B <- log(vector_occupancy_2B)
  vector_halflife_x_2B <- c(1, 2, 4, 6, 8)
  dataframe_2B  <- data.frame(xAxis = vector_halflife_x_2B, yAxis = vector_halflife_y_2B) 
  regression_2B <- lm(vector_halflife_y_2B ~ vector_halflife_x_2B)
  sink( paste(Path_local, "/5-2-regression_Peaks±2000bp.txt", sep="")  )
  print( summary(regression_2B) )
  sink()
  
  week1_2C <- mean(week1_2[1:upStream])  ## upstream
  week2_2C <- mean(week2_2[1:upStream])
  week4_2C <- mean(week4_2[1:upStream])
  week6_2C <- mean(week6_2[1:upStream])
  week8_2C <- mean(week8_2[1:upStream])
  vector_occupancy_2C <- c(week1_2C, week2_2C, week4_2C, week6_2C, week8_2C)
  vector_halflife_y_2C <- log(vector_occupancy_2C)
  vector_halflife_x_2C <- c(1, 2, 4, 6, 8)
  dataframe_2C  <- data.frame(xAxis = vector_halflife_x_2C, yAxis = vector_halflife_y_2C) 
  regression_2C <- lm(vector_halflife_y_2C ~ vector_halflife_x_2C)
  sink( paste(Path_local, "/5-3-regression_Upstream.txt", sep="")  )
  print( summary(regression_2C) )
  sink()
  
  week1_2D <- mean(week1_2[(upStream+peakSize+1):(upStream+peakSize+downStream)])  ## downstream
  week2_2D <- mean(week2_2[(upStream+peakSize+1):(upStream+peakSize+downStream)])
  week4_2D <- mean(week4_2[(upStream+peakSize+1):(upStream+peakSize+downStream)])
  week6_2D <- mean(week6_2[(upStream+peakSize+1):(upStream+peakSize+downStream)])
  week8_2D <- mean(week8_2[(upStream+peakSize+1):(upStream+peakSize+downStream)])
  vector_occupancy_2D <- c(week1_2D, week2_2D, week4_2D, week6_2D, week8_2D)
  vector_halflife_y_2D <- log(vector_occupancy_2D)
  vector_halflife_x_2D <- c(1, 2, 4, 6, 8)
  dataframe_2D  <- data.frame(xAxis = vector_halflife_x_2D, yAxis = vector_halflife_y_2D) 
  regression_2D <- lm(vector_halflife_y_2D ~ vector_halflife_x_2D)
  sink( paste(Path_local, "/5-4-regression_Downstream.txt", sep="")  )
  print( summary(regression_2D) )
  sink()
  
  y_position <- max(vector_halflife_y_2D)
  print(y_position)
  y_position4 <- y_position + 0.3
  y_position3 <- y_position + 0.4
  y_position2 <- y_position + 0.5
  y_position1 <- y_position + 0.6
  x_position <- 4.5
  sampleType4 <- c( rep.int("GATA4 Peaks", 5),  rep.int("Peaks ± 2000bp", 5),  rep.int("Up streams of Peaks", 5),  rep.int("Down streams of Peaks", 5) ) 
  dataframe4 <- data.frame( xAxis=c(dataframe_2A$xAxis, dataframe_2B$xAxis, dataframe_2C$xAxis, dataframe_2D$xAxis),
                            yAxis=c(dataframe_2A$yAxis, dataframe_2B$yAxis, dataframe_2C$yAxis, dataframe_2D$yAxis),  sampleType=sampleType4 )
  
  dataframe4A <- data.frame( x_position=x_position, y_position4=y_position4, y_position3=y_position3,  y_position2=y_position2,  y_position1=y_position1,
                             LABEL_1=lmEquation(regression_2A),     LABEL_2=lmEquation(regression_2B), LABEL_3=lmEquation(regression_2C), LABEL_4=lmEquation(regression_2D) )
  
  CairoSVG(file = paste(Path_local, "/5-5-occupancy-halflife.svg", sep=""),   width = 6.0, height = 4.0, onefile = TRUE, bg = "white",  pointsize = 1 )
  figuresTemp <- ggplot( data = dataframe4, aes(x = xAxis, y = yAxis, color=sampleType ) ) + 
    geom_point(size=2) +  
    scale_colour_manual( values=c("GATA4 Peaks" = "gold4",  "Peaks ± 2000bp" = "green4",   "Up streams of Peaks"="red4", "Down streams of Peaks"="blue4") ,    breaks=c("GATA4 Peaks",  "Peaks ± 2000bp",  "Up streams of Peaks", "Down streams of Peaks") ) +  
    xlab("Time (week)") +   ylab("ln(H2B-GFP Signal)") +   ggtitle("Four Regions around GATA4 Peaks") + 
    geom_text( data = dataframe4A, aes(x = x_position, y = y_position1,   label = LABEL_1 ), parse = TRUE, family="serif", colour="gold4",       fontface=4,  size=3,  lineheight=1, alpha=1 ) +
    geom_text( data = dataframe4A, aes(x = x_position, y = y_position2,   label = LABEL_2 ), parse = TRUE, family="serif", colour="green4",      fontface=4,  size=3,  lineheight=1, alpha=1 ) +
    geom_text( data = dataframe4A, aes(x = x_position, y = y_position3,   label = LABEL_3 ), parse = TRUE, family="serif", colour="red4",        fontface=4,  size=3,  lineheight=1, alpha=1 ) +
    geom_text( data = dataframe4A, aes(x = x_position, y = y_position4,   label = LABEL_4 ), parse = TRUE, family="serif", colour="blue4",       fontface=4,  size=3,  lineheight=1, alpha=1 ) +  
    geom_smooth(data=dataframe_2A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="gold4" ) + 
    geom_smooth(data=dataframe_2B, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="green4") + 
    geom_smooth(data=dataframe_2C, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4"  ) + 
    geom_smooth(data=dataframe_2D, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="blue4" ) +
    scale_x_continuous( breaks=c(1, 2, 3, 4, 5, 6, 7, 8) ) + 
    pTheme + guides( colour = guide_legend(override.aes = list(size=5.0))  )
  print( figuresTemp )
  dev.off()
}



system("mkdir  Figures/2-NTR")

system("mkdir  Figures/2-NTR/1-sumColumns-allRows")
NTRfigures(H3_All, week1_All, week2_All, week4_All, week6_All, week8_All, "Figures/2-NTR/1-sumColumns-allRows")


system("mkdir  Figures/2-NTR/2-sumColumns-Highest")
NTRfigures(H3_Highest, week1_Highest, week2_Highest, week4_Highest, week6_Highest, week8_Highest, "Figures/2-NTR/2-sumColumns-Highest")


system("mkdir  Figures/2-NTR/3-sumColumns-High")
NTRfigures(H3_High, week1_High, week2_High, week4_High, week6_High, week8_High, "Figures/2-NTR/3-sumColumns-High")


system("mkdir  Figures/2-NTR/4-sumColumns-Intermediate")
NTRfigures(H3_Intermediate, week1_Intermediate, week2_Intermediate, week4_Intermediate, week6_Intermediate, week8_Intermediate, "Figures/2-NTR/4-sumColumns-Intermediate")


system("mkdir  Figures/2-NTR/5-sumColumns-Low")
NTRfigures(H3_Low, week1_Low, week2_Low, week4_Low, week6_Low, week8_Low, "Figures/2-NTR/5-sumColumns-Low")


system("mkdir  Figures/2-NTR/6-sumColumns-Lowest")
NTRfigures(H3_Lowest, week1_Lowest, week2_Lowest, week4_Lowest, week6_Lowest, week8_Lowest, "Figures/2-NTR/6-sumColumns-Lowest")




















system("mkdir  Figures/2-NTR/7-FiveCategaries")

week1_Highest_2  <- colMeans(week1_Highest,  na.rm = TRUE) 
week2_Highest_2  <- colMeans(week2_Highest,  na.rm = TRUE) 
week4_Highest_2  <- colMeans(week4_Highest,  na.rm = TRUE)
week6_Highest_2  <- colMeans(week6_Highest,  na.rm = TRUE) 
week8_Highest_2  <- colMeans(week8_Highest,  na.rm = TRUE) 
turnoverDis_Highest_2 <- c()
for ( i in 1:length(week1_Highest_2) ) {
  tur <- turnoverRate(week1_Highest_2[i], week2_Highest_2[i], week4_Highest_2[i], week6_Highest_2[i], week8_Highest_2[i])
  turnoverDis_Highest_2 <- c(turnoverDis_Highest_2, tur)
}
sink()
length(turnoverDis_Highest_2)
halfLifeDis_Highest_2 <- log(2)/turnoverDis_Highest_2
Position_Highest_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum)

week1_High_2  <- colMeans(week1_High,  na.rm = TRUE) 
week2_High_2  <- colMeans(week2_High,  na.rm = TRUE) 
week4_High_2  <- colMeans(week4_High,  na.rm = TRUE)
week6_High_2  <- colMeans(week6_High,  na.rm = TRUE) 
week8_High_2  <- colMeans(week8_High,  na.rm = TRUE) 
turnoverDis_High_2 <- c()
for ( i in 1:length(week1_High_2) ) {
  tur <- turnoverRate(week1_High_2[i], week2_High_2[i], week4_High_2[i], week6_High_2[i], week8_High_2[i])
  turnoverDis_High_2 <- c(turnoverDis_High_2, tur)
}
sink()
length(turnoverDis_High_2)
halfLifeDis_High_2 <- log(2)/turnoverDis_High_2
Position_High_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum)

week1_Intermediate_2  <- colMeans(week1_Intermediate,  na.rm = TRUE) 
week2_Intermediate_2  <- colMeans(week2_Intermediate,  na.rm = TRUE) 
week4_Intermediate_2  <- colMeans(week4_Intermediate,  na.rm = TRUE)
week6_Intermediate_2  <- colMeans(week6_Intermediate,  na.rm = TRUE) 
week8_Intermediate_2  <- colMeans(week8_Intermediate,  na.rm = TRUE) 
turnoverDis_Intermediate_2 <- c()
for ( i in 1:length(week1_Intermediate_2) ) {
  tur <- turnoverRate(week1_Intermediate_2[i], week2_Intermediate_2[i], week4_Intermediate_2[i], week6_Intermediate_2[i], week8_Intermediate_2[i])
  turnoverDis_Intermediate_2 <- c(turnoverDis_Intermediate_2, tur)
}
sink()
length(turnoverDis_Intermediate_2)
halfLifeDis_Intermediate_2 <- log(2)/turnoverDis_Intermediate_2
Position_Intermediate_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum)

week1_Low_2  <- colMeans(week1_Low,  na.rm = TRUE) 
week2_Low_2  <- colMeans(week2_Low,  na.rm = TRUE) 
week4_Low_2  <- colMeans(week4_Low,  na.rm = TRUE)
week6_Low_2  <- colMeans(week6_Low,  na.rm = TRUE) 
week8_Low_2  <- colMeans(week8_Low,  na.rm = TRUE) 
turnoverDis_Low_2 <- c()
for ( i in 1:length(week1_Low_2) ) {
  tur <- turnoverRate(week1_Low_2[i], week2_Low_2[i], week4_Low_2[i], week6_Low_2[i], week8_Low_2[i])
  turnoverDis_Low_2 <- c(turnoverDis_Low_2, tur)
}
sink()
length(turnoverDis_Low_2)
halfLifeDis_Low_2 <- log(2)/turnoverDis_Low_2
Position_Low_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum)

week1_Lowest_2  <- colMeans(week1_Lowest,  na.rm = TRUE) 
week2_Lowest_2  <- colMeans(week2_Lowest,  na.rm = TRUE) 
week4_Lowest_2  <- colMeans(week4_Lowest,  na.rm = TRUE)
week6_Lowest_2  <- colMeans(week6_Lowest,  na.rm = TRUE) 
week8_Lowest_2  <- colMeans(week8_Lowest,  na.rm = TRUE) 
turnoverDis_Lowest_2 <- c()
for ( i in 1:length(week1_Lowest_2) ) {
  tur <- turnoverRate(week1_Lowest_2[i], week2_Lowest_2[i], week4_Lowest_2[i], week6_Lowest_2[i], week8_Lowest_2[i])
  turnoverDis_Lowest_2 <- c(turnoverDis_Lowest_2, tur)
}
sink()
length(turnoverDis_Lowest_2)
halfLifeDis_Lowest_2 <- log(2)/turnoverDis_Lowest_2
Position_Lowest_2  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum)

#################################################  Five categaries:

x_Axis_FiveCategaries_2   <- c( Position_Highest_2,     Position_High_2,     Position_Intermediate_2,    Position_Low_2,  Position_Lowest_2)                       
y_Axis_FiveCategaries_2   <- c( turnoverDis_Highest_2,  turnoverDis_High_2,  turnoverDis_Intermediate_2, turnoverDis_Low_2, turnoverDis_Lowest_2 )  
sampleType_FiveCategaries_2 <- c( rep("Highest", binNum), rep("High", binNum),  rep("Intermediate", binNum),   rep("Low", binNum),   rep("Lowest", binNum)  )                            
dataframe_FiveCategaries_2  <- data.frame(xAxis = x_Axis_FiveCategaries_2,  yAxis = y_Axis_FiveCategaries_2,  sampleType = sampleType_FiveCategaries_2) 
#####################################
CairoSVG(file = "Figures/2-NTR/7-FiveCategaries/2-a-FiveCategaries-turnover.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_FiveCategaries_2,  aes(x=xAxis, y=dataframe_FiveCategaries_2$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NTR") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("Highest"="green4",  "High"="green",  "Intermediate"="yellowgreen",  "Low"="gold", "Lowest"="gold4"),  breaks=c("Highest",  "High",  "Intermediate", "Low", "Lowest") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################


x_Axis_ThreeCategaries_2   <- c( Position_Highest_2,       Position_Intermediate_2,    Position_Lowest_2)                       
y_Axis_ThreeCategaries_2   <- c( turnoverDis_Highest_2,   turnoverDis_Intermediate_2,  turnoverDis_Lowest_2 )  
sampleType_ThreeCategaries_2 <- c( rep("High", binNum),  rep("Middle", binNum),    rep("Low", binNum)  )                            
dataframe_ThreeCategaries_2  <- data.frame(xAxis = x_Axis_ThreeCategaries_2,  yAxis = y_Axis_ThreeCategaries_2,  sampleType = sampleType_ThreeCategaries_2) 
#####################################
CairoSVG(file = "Figures/2-NTR/7-FiveCategaries/2-a-ThreeCategaries-turnover.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_ThreeCategaries_2,  aes(x=xAxis, y=dataframe_ThreeCategaries_2$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NTR") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("High"="green4",  "Middle"="green",  "Low"="yellowgreen"),  breaks=c("High",   "Middle", "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################






x_Axis_FiveCategaries_2   <- c( Position_Highest_2,     Position_High_2,     Position_Intermediate_2,    Position_Low_2,  Position_Lowest_2)                       
y_Axis_FiveCategaries_2   <- c( halfLifeDis_Highest_2,  halfLifeDis_High_2,  halfLifeDis_Intermediate_2, halfLifeDis_Low_2, halfLifeDis_Lowest_2 )  
sampleType_FiveCategaries_2 <- c( rep("Highest", binNum), rep("High", binNum),  rep("Intermediate", binNum),   rep("Low", binNum),   rep("Lowest", binNum)  )                            
dataframe_FiveCategaries_2  <- data.frame(xAxis = x_Axis_FiveCategaries_2,  yAxis = y_Axis_FiveCategaries_2,  sampleType = sampleType_FiveCategaries_2) 
#####################################
CairoSVG(file = "Figures/2-NTR/7-FiveCategaries/2-a-FiveCategaries-halfLife.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_FiveCategaries_2,  aes(x=xAxis, y=dataframe_FiveCategaries_2$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("Half-life (week)") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("Highest"="green4",  "High"="green",  "Intermediate"="yellowgreen",  "Low"="gold", "Lowest"="gold4"),  breaks=c("Highest",  "High",  "Intermediate", "Low", "Lowest") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################


x_Axis_ThreeCategaries_2   <- c( Position_Highest_2,       Position_Intermediate_2,    Position_Lowest_2)                       
y_Axis_ThreeCategaries_2   <- c( halfLifeDis_Highest_2,   halfLifeDis_Intermediate_2,  halfLifeDis_Lowest_2 )  
sampleType_ThreeCategaries_2 <- c( rep("High", binNum),  rep("Middle", binNum),    rep("Low", binNum)  )                            
dataframe_ThreeCategaries_2  <- data.frame(xAxis = x_Axis_ThreeCategaries_2,  yAxis = y_Axis_ThreeCategaries_2,  sampleType = sampleType_ThreeCategaries_2) 
#####################################
CairoSVG(file = "Figures/2-NTR/7-FiveCategaries/2-a-ThreeCategaries-halfLife.svg",   width = 5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_ThreeCategaries_2,  aes(x=xAxis, y=dataframe_ThreeCategaries_2$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("Half-life (week)") +  ggtitle("GATA4 Peaks") + 
  scale_colour_manual(values=c("High"="green4",  "Middle"="green",  "Low"="yellowgreen"),  breaks=c("High",   "Middle", "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
  scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################





















smallNum_5 <- 10**(-10)

##  Peaks
week2_5A <- rowSums(week2[, (upStream+1):(upStream+peakSize)])
week6_5A <- rowSums(week6[, (upStream+1):(upStream+peakSize)])
turnoverRate_5A <- -( week6_5A - week2_5A )/(4*week2_5A + smallNum_5)
length(turnoverRate_5A)
turnoverRate_5B <- abs(turnoverRate_5A)
length(turnoverRate_5B[turnoverRate_5B>50])
turnoverRate_5B[turnoverRate_5B>50] <- 50

#######################################################################################################################
system("mkdir  Figures/2-NTR/8-turnoverDisNOL-PeaksHeight")
PeaksHeightFile <- "/home/yongp/Desktop/H2BGFPdanpos2/0-allRegions/4-Adult_Gata4/Adult_Gata4_Ab_peaks.xls"
PeaksHeight <- read.table(PeaksHeightFile,    header=FALSE,   sep="",   quote = "",   comment.char = "")
PeaksHeight_1 <- as.vector(PeaksHeight[-1,5])
turnoverDis_occpancy_1 <- turnoverRate_5B
length(PeaksHeight_1)
length(turnoverDis_occpancy_1)

length(PeaksHeight_1[PeaksHeight_1>35])
PeaksHeight_1[PeaksHeight_1>35] <- 35
length(turnoverDis_occpancy_1[turnoverDis_occpancy_1>4])
turnoverDis_occpancy_1[turnoverDis_occpancy_1>4] <- 4

OccPeakFrame <- data.frame(peak <- PeaksHeight_1, turnoverDisocc <- turnoverDis_occpancy_1)

sink("Figures/2-NTR/8-turnoverDisNOL-PeaksHeight/1-A-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
print("Pearson product-moment correlation coefficient:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=OccPeakFrame, y = OccPeakFrame,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
mine(x=turnoverDis_occpancy_1, y = PeaksHeight_1,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(turnoverDis_occpancy_1) + min(turnoverDis_occpancy_1) )/2
y_position <- max(PeaksHeight_1) + 2
regression_A <- lm(PeaksHeight_1 ~ turnoverDis_occpancy_1)
dataframe_A <- data.frame( xAxis=turnoverDis_occpancy_1, yAxis=PeaksHeight_1 )

CairoSVG(file = "Figures/2-NTR/8-turnoverDisNOL-PeaksHeight/1-A-turnoverDisoccupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/2-NTR/8-turnoverDisNOL-PeaksHeight/1-A-turnoverDisoccupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/2-NTR/8-turnoverDisNOL-PeaksHeight/1-A-turnoverDisoccupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/2-NTR/8-turnoverDisNOL-PeaksHeight/1-A-turnoverDisoccupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("GATA4 Density") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 








PeaksHeight_2 <- log(PeaksHeight_1)
turnoverDis_occpancy_2 <- turnoverDis_occpancy_1
OccPeakFrame2 <- data.frame(peak <- PeaksHeight_2, turnoverDisocc <- turnoverDis_occpancy_2)

sink("Figures/2-NTR/14-turnoverDisNOL-PeaksHeight/2-B-CorrelationCoefficients.txt")
print("########################################")
print("########################################")
print("Pearson product-moment correlation coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=OccPeakFrame2, y = OccPeakFrame2,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
mine(x=turnoverDis_occpancy_2, y = PeaksHeight_2,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()

x_position <- ( max(turnoverDis_occpancy_2) + min(turnoverDis_occpancy_2) )/2
y_position <- max(PeaksHeight_2) + 2
regression_A <- lm(PeaksHeight_2 ~ turnoverDis_occpancy_2)
dataframe_A <- data.frame( xAxis=turnoverDis_occpancy_2, yAxis=PeaksHeight_2 )

CairoSVG(file = "Figures/2-NTR/14-turnoverDisNOL-PeaksHeight/2-B-turnoverDisoccupancy-PeaksHeight-scaterPlot.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

png(file = "Figures/2-NTR/14-turnoverDisNOL-PeaksHeight/2-B-turnoverDisoccupancy-PeaksHeight-scaterPlot.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  pTheme2 
dev.off() 

CairoSVG(file = "Figures/2-NTR/14-turnoverDisNOL-PeaksHeight/2-B-turnoverDisoccupancy-PeaksHeight-line.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 


png(file = "Figures/2-NTR/14-turnoverDisNOL-PeaksHeight/2-B-turnoverDisoccupancy-PeaksHeight-line.png",    pointsize = 1 )
ggplot( data = dataframe_A, aes(x = xAxis, y = yAxis) ) + 
  xlab("NOL") + ylab("ln(GATA4 Density)") + ggtitle("NOL and GATA4 Density") + 
  geom_point(size=0.02, shape=20) + 
  geom_text( aes(x = x_position, y = y_position,   label = lmEquation( regression_A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=6,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  pTheme2 
dev.off() 






























