## Part 1: Load libraries, define some functions.
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
  text  = element_text(family="sans",  face=NULL, colour="black", size=9, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),                     ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
  title = element_text(family="sans",  face=NULL, colour="black", size=9, hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),                     ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.
  
  axis.title        = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),         ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
  axis.title.x      = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=-15,  angle=NULL, lineheight=NULL),         ## x axis label (element_text; inherits from axis.title)
  axis.title.y      = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=15,   angle=NULL, lineheight=NULL),         ## y axis label (element_text; inherits from axis.title)
  axis.text         = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),         ## tick labels along axes (element_text; inherits from text). 坐标轴刻度的标签的属性.                                                         
  axis.text.x       = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),         ## x axis tick labels (element_text; inherits from axis.text)
  axis.text.y       = element_text(family="sans", face=NULL, colour="black", size=9,  hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL),         ## y axis tick labels (element_text; inherits from axis.text)
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
  plot.title      = element_text(family="sans", face=NULL, colour="black", size=9, hjust=NULL, vjust=NULL, angle=NULL, lineheight=NULL), 	          ## plot title (text appearance) (element_text; inherits from title)  图形标题
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






























## Part 2: Read the input files, so we get a n*m matrix that means it contains n rows (n DNA fragment) and m columns (m bin, 1 bin=10bp).
#################################################################### Start ##########################################################################################################################################

week1 <- read.table("danpos-profile/week1/week1_TSS_heatmap/isoform_exp_FPKM.bed.tss.week1.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week2 <- read.table("danpos-profile/week2/week2_TSS_heatmap/isoform_exp_FPKM.bed.tss.week2.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week4 <- read.table("danpos-profile/week4/week4_TSS_heatmap/isoform_exp_FPKM.bed.tss.week4.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week6 <- read.table("danpos-profile/week6/week6_TSS_heatmap/isoform_exp_FPKM.bed.tss.week6.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
week8 <- read.table("danpos-profile/week8/week8_TSS_heatmap/isoform_exp_FPKM.bed.tss.week8.wig.heatmap.xls",    header=TRUE,   sep="",   quote = "",   comment.char = "")
H3    <- read.table("danpos-profile/H3/H3_TSS_heatmap/isoform_exp_FPKM.bed.tss.H3.wig.heatmap.xls",             header=TRUE,   sep="",   quote = "",   comment.char = "")
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





peakSize   = 0     ##peak 
upStream   = 300    ##peak  up 
downStream = 300    ##peak  down


needIndex <- c( (501-upStream):500, 501:(500+peakSize+downStream) )      ## maybe need to change
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





## all columns
H3_all     <- rowMeans(H3,  na.rm = TRUE) 
week1_all  <- rowMeans(week1,  na.rm = TRUE) 
week2_all  <- rowMeans(week2,  na.rm = TRUE) 
week4_all  <- rowMeans(week4,  na.rm = TRUE)
week6_all  <- rowMeans(week6,  na.rm = TRUE) 
week8_all  <- rowMeans(week8,  na.rm = TRUE) 
length(H3_all)
length(week1_all)
length(week2_all)
length(week4_all)
length(week6_all)
length(week8_all)



## up streams
H3_up     <- rowMeans(H3[, 1:200],     na.rm = TRUE) 
week1_up  <- rowMeans(week1[, 1:200],  na.rm = TRUE) 
week2_up  <- rowMeans(week2[, 1:200],  na.rm = TRUE) 
week4_up  <- rowMeans(week4[, 1:200],  na.rm = TRUE)
week6_up  <- rowMeans(week6[, 1:200],  na.rm = TRUE) 
week8_up  <- rowMeans(week8[, 1:200],  na.rm = TRUE) 
length(H3_up)
length(week1_up)
length(week2_up)
length(week4_up)
length(week6_up)
length(week8_up)



## +1 nucleosomes 
H3_peak     <- rowMeans(H3[, 300:330],     na.rm = TRUE) 
week1_peak  <- rowMeans(week1[, 300:330],  na.rm = TRUE) 
week2_peak  <- rowMeans(week2[, 300:330],  na.rm = TRUE) 
week4_peak  <- rowMeans(week4[, 300:330],  na.rm = TRUE)
week6_peak  <- rowMeans(week6[, 300:330],  na.rm = TRUE) 
week8_peak  <- rowMeans(week8[, 300:330],  na.rm = TRUE) 
length(H3_peak)
length(week1_peak)
length(week2_peak)
length(week4_peak)
length(week6_peak)
length(week8_peak)



## down streams
H3_down     <- rowMeans(H3[, 400:600],     na.rm = TRUE) 
week1_down  <- rowMeans(week1[, 400:600],  na.rm = TRUE) 
week2_down  <- rowMeans(week2[, 400:600],  na.rm = TRUE) 
week4_down  <- rowMeans(week4[, 400:600],  na.rm = TRUE)
week6_down  <- rowMeans(week6[, 400:600],  na.rm = TRUE) 
week8_down  <- rowMeans(week8[, 400:600],  na.rm = TRUE) 
length(H3_down)
length(week1_down)
length(week2_down)
length(week4_down)
length(week6_down)
length(week8_down)







sink("Figures-noscale/0-A-nucleosome-occupancy-diff.txt") 

print("########################### up streams ###################################")
print( mean(H3_up) )
print( mean(week1_up) )
print( mean(week2_up) )
print( mean(week4_up) )
print( mean(week6_up) )
print( mean(week8_up) )
print("########################### peaks ###################################")
print( mean(H3_peak) )
print( mean(week1_peak) )
print( mean(week2_peak) )
print( mean(week4_peak) )
print( mean(week6_peak) )
print( mean(week8_peak) )
print("########################### down streams ###################################")
print( mean(H3_down) )
print( mean(week1_down) )
print( mean(week2_down) )
print( mean(week4_down) )
print( mean(week6_down) )
print( mean(week8_down) )

sink()



####################################################################  End    ##########################################################################################################################################


































## Part 3: Nucleosome occupancy distribution.
####################################################################  Start  ##########################################################################################################################################
OccuT <- 2.0


## occupancy distribution of all sites:

###############################################
length( H3_all[H3_all > OccuT] )
H3_all[H3_all > OccuT] <- OccuT
H3_all[1] = OccuT
H3_all_frame  <- data.frame(xAxis = H3_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-H3_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=H3_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (H3)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################


###############################################
length( week1_all[week1_all > OccuT] )
week1_all[week1_all > OccuT] <- OccuT
week1_all[1] = OccuT
week1_all_frame  <- data.frame(xAxis = week1_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week1_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week1_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week1)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week2_all[week2_all > OccuT] )
week2_all[week2_all > OccuT] <- OccuT
week2_all[1] = OccuT
week2_all_frame  <- data.frame(xAxis = week2_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week2_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week2_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week2)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week4_all[week4_all > OccuT] )
week4_all[week4_all > OccuT] <- OccuT
week4_all[1] = OccuT
week4_all_frame  <- data.frame(xAxis = week4_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week4_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week4_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week4)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week6_all[week6_all > OccuT] )
week6_all[week6_all > OccuT] <- OccuT
week6_all[1] = OccuT
week6_all_frame  <- data.frame(xAxis = week6_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week6_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week6_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week6)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week8_all[week8_all > OccuT] )
week8_all[week8_all > OccuT] <- OccuT
week8_all[1] = OccuT
week8_all_frame  <- data.frame(xAxis = week8_all) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week8_all.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week8_all_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week8)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################
















## occupancy distribution of up stream sites:

###############################################
length( H3_up[H3_up > OccuT] )
H3_up[H3_up > OccuT] <- OccuT
H3_up[1] = OccuT
H3_up_frame  <- data.frame(xAxis = H3_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-H3_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=H3_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (H3)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################


###############################################
length( week1_up[week1_up > OccuT] )
week1_up[week1_up > OccuT] <- OccuT
week1_up[1] = OccuT
week1_up_frame  <- data.frame(xAxis = week1_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week1_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week1_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week1)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week2_up[week2_up > OccuT] )
week2_up[week2_up > OccuT] <- OccuT
week2_up[1] = OccuT
week2_up_frame  <- data.frame(xAxis = week2_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week2_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week2_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week2)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week4_up[week4_up > OccuT] )
week4_up[week4_up > OccuT] <- OccuT
week4_up[1] = OccuT
week4_up_frame  <- data.frame(xAxis = week4_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week4_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week4_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week4)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week6_up[week6_up > OccuT] )
week6_up[week6_up > OccuT] <- OccuT
week6_up[1] = OccuT
week6_up_frame  <- data.frame(xAxis = week6_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week6_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week6_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week6)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week8_up[week8_up > OccuT] )
week8_up[week8_up > OccuT] <- OccuT
week8_up[1] = OccuT
week8_up_frame  <- data.frame(xAxis = week8_up) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week8_up.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week8_up_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week8)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################














## occupancy distribution of peak sites:

###############################################
length( H3_peak[H3_peak > OccuT] )
H3_peak[H3_peak > OccuT] <- OccuT
H3_peak[1] = OccuT
H3_peak_frame  <- data.frame(xAxis = H3_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-H3_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=H3_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (H3)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################


###############################################
length( week1_peak[week1_peak > OccuT] )
week1_peak[week1_peak > OccuT] <- OccuT
week1_peak[1] = OccuT
week1_peak_frame  <- data.frame(xAxis = week1_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week1_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week1_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week1)")  +   ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week2_peak[week2_peak > OccuT] )
week2_peak[week2_peak > OccuT] <- OccuT
week2_peak[1] = OccuT
week2_peak_frame  <- data.frame(xAxis = week2_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week2_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week2_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week2)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week4_peak[week4_peak > OccuT] )
week4_peak[week4_peak > OccuT] <- OccuT
week4_peak[1] = OccuT
week4_peak_frame  <- data.frame(xAxis = week4_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week4_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week4_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week4)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week6_peak[week6_peak > OccuT] )
week6_peak[week6_peak > OccuT] <- OccuT
week6_peak[1] = OccuT
week6_peak_frame  <- data.frame(xAxis = week6_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week6_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week6_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week6)")  +    ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week8_peak[week8_peak > OccuT] )
week8_peak[week8_peak > OccuT] <- OccuT
week8_peak[1] = OccuT
week8_peak_frame  <- data.frame(xAxis = week8_peak) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week8_peak.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week8_peak_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week8)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################















## occupancy distribution of down stream sites:

###############################################
length( H3_down[H3_down > OccuT] )
H3_down[H3_down > OccuT] <- OccuT
H3_down[1] = OccuT
H3_down_frame  <- data.frame(xAxis = H3_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-H3_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=H3_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (H3)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################


###############################################
length( week1_down[week1_down > OccuT] )
week1_down[week1_down > OccuT] <- OccuT
week1_down[1] = OccuT
week1_down_frame  <- data.frame(xAxis = week1_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week1_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week1_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week1)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week2_down[week2_down > OccuT] )
week2_down[week2_down > OccuT] <- OccuT
week2_down[1] = OccuT
week2_down_frame  <- data.frame(xAxis = week2_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week2_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week2_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week2)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week4_down[week4_down > OccuT] )
week4_down[week4_down > OccuT] <- OccuT
week4_down[1] = OccuT
week4_down_frame  <- data.frame(xAxis = week4_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week4_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week4_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week4)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week6_down[week6_down > OccuT] )
week6_down[week6_down > OccuT] <- OccuT
week6_down[1] = OccuT
week6_down_frame  <- data.frame(xAxis = week6_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week6_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week6_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week6)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################



###############################################
length( week8_down[week8_down > OccuT] )
week8_down[week8_down > OccuT] <- OccuT
week8_down[1] = OccuT
week8_down_frame  <- data.frame(xAxis = week8_down) 

CairoSVG(file = "Figures-noscale/0-A-nucleosome-occupancy-week8_down.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot(data=week8_down_frame, aes(x=xAxis) )  +   
  xlab("Nucleosome Occupancy Level") + 
  ylab("Relative Frequency") + 
  ggtitle("Distribution of Nucleosome Occupancy (week8)")  +     ylim(0, 0.8) +  
  geom_histogram(binwidth = 0.1, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 0.5, 1, 1.5, 2.0), labels=c("0", "0.5", "1", "1.5", "2.0+") ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.1) ) )

dev.off() 
###############################################











## all columns
H3_all     <- rowMeans(H3,  na.rm = TRUE) 
week1_all  <- rowMeans(week1,  na.rm = TRUE) 
week2_all  <- rowMeans(week2,  na.rm = TRUE) 
week4_all  <- rowMeans(week4,  na.rm = TRUE)
week6_all  <- rowMeans(week6,  na.rm = TRUE) 
week8_all  <- rowMeans(week8,  na.rm = TRUE) 
length(H3_all)
length(week1_all)
length(week2_all)
length(week4_all)
length(week6_all)
length(week8_all)



## up streams
H3_up     <- rowMeans(H3[, 1:upStream],     na.rm = TRUE) 
week1_up  <- rowMeans(week1[, 1:upStream],  na.rm = TRUE) 
week2_up  <- rowMeans(week2[, 1:upStream],  na.rm = TRUE) 
week4_up  <- rowMeans(week4[, 1:upStream],  na.rm = TRUE)
week6_up  <- rowMeans(week6[, 1:upStream],  na.rm = TRUE) 
week8_up  <- rowMeans(week8[, 1:upStream],  na.rm = TRUE) 
length(H3_up)
length(week1_up)
length(week2_up)
length(week4_up)
length(week6_up)
length(week8_up)



## peaks regions 
H3_peak     <- rowMeans(H3[, 300:330],     na.rm = TRUE) 
week1_peak  <- rowMeans(week1[, 300:330],  na.rm = TRUE) 
week2_peak  <- rowMeans(week2[, 300:330],  na.rm = TRUE) 
week4_peak  <- rowMeans(week4[, 300:330],  na.rm = TRUE)
week6_peak  <- rowMeans(week6[, 300:330],  na.rm = TRUE) 
week8_peak  <- rowMeans(week8[, 300:330],  na.rm = TRUE) 
length(H3_peak)
length(week1_peak)
length(week2_peak)
length(week4_peak)
length(week6_peak)
length(week8_peak)



## down streams
H3_down     <- rowMeans(H3[, 400:600],     na.rm = TRUE) 
week1_down  <- rowMeans(week1[, 400:600],  na.rm = TRUE) 
week2_down  <- rowMeans(week2[, 400:600],  na.rm = TRUE) 
week4_down  <- rowMeans(week4[, 400:600],  na.rm = TRUE)
week6_down  <- rowMeans(week6[, 400:600],  na.rm = TRUE) 
week8_down  <- rowMeans(week8[, 400:600],  na.rm = TRUE) 
length(H3_down)
length(week1_down)
length(week2_down)
length(week4_down)
length(week6_down)
length(week8_down)


####################################################################  End    ##########################################################################################################################################



























## Part 4, nucleosome occupancy distribution, sum the all elements of one column, wo we get a vector that its length is equal to the number of columns in a matrix.
####################################################################  Start  ##########################################################################################################################################
week1_1  <- colMeans(week1,  na.rm = TRUE) 
week2_1  <- colMeans(week2,  na.rm = TRUE) 
week4_1  <- colMeans(week4,  na.rm = TRUE)
week6_1  <- colMeans(week6,  na.rm = TRUE) 
week8_1  <- colMeans(week8,  na.rm = TRUE) 
H3_1     <- colMeans(H3,  na.rm = TRUE) 
sink("Figures-noscale/1-a-wilcoxon-test-paired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_1, y = week1_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_1, y = week2_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_1, y = week4_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_1, y = week6_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/1-a-wilcoxon-test-unpaired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_1, y = week1_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_1, y = week2_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_1, y = week4_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_1, y = week6_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/1-a-t-test-paired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_1, y = week1_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_1, y = week2_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_1, y = week4_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_1, y = week6_1, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/1-a-t-test-unpaired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_1, y = week1_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_1, y = week2_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_1, y = week4_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_1, y = week6_1, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()



binNum = upStream + peakSize + downStream

Position_1 <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
week1_1_frame <-  ksmooth(x=Position_1,   y=week1_1,     kernel = "normal",   bandwidth = 0.1)
week2_1_frame <-  ksmooth(x=Position_1,   y=week2_1,     kernel = "normal",   bandwidth = 0.1)
week4_1_frame <-  ksmooth(x=Position_1,   y=week4_1,     kernel = "normal",   bandwidth = 0.1)
week6_1_frame <-  ksmooth(x=Position_1,   y=week6_1,     kernel = "normal",   bandwidth = 0.1)
week8_1_frame <-  ksmooth(x=Position_1,   y=week8_1,     kernel = "normal",   bandwidth = 0.1)
week1_1a <- week1_1_frame$y
week2_1a <- week2_1_frame$y
week4_1a <- week4_1_frame$y
week6_1a <- week6_1_frame$y
week8_1a <- week8_1_frame$y
x_Axis_1   <- c( Position_1, Position_1,   Position_1,    Position_1,  Position_1)                       
y_Axis_1   <- c( week1_1a, week2_1a, week4_1a,  week6_1a, week8_1a )  
sampleType_1 <- c( rep("week 1", binNum), rep("week 2", binNum),  rep("week 4", binNum),   rep("week 6", binNum), rep("week 8", binNum)  )                            
dataframe_1  <- data.frame(xAxis = x_Axis_1,  yAxis = y_Axis_1,  sampleType = sampleType_1) 
#####################################
CairoSVG(file = "Figures-noscale/1-b-TSS-occupancy.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_1,  aes(x=xAxis, y=dataframe_1$yAxis,  color=sampleType) )  +   
    xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("TSSs") + 
    scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
    geom_line(size=0.5) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
    scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) +  
    pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################




##Error bar一般是standard error，即标准误，反映的是抽样引起的误差；
##有些时候有些人也用standard deviation，即标准差，反映的是样本数据之间的离散程度（或整齐程度）。
##所以看你实际需要选择。S.E.=S.D./sqrt(N-1)，这就是两者的联系。
##S.E.受样本数量影响很大，而S.D.则受样本数据齐性影响更大。
week1_1_SEM <- apply(week1, 2, sd)/sqrt(nrow(week1)-1)   ## The standard error of the mean (SEM) 
week2_1_SEM <- apply(week2, 2, sd)/sqrt(nrow(week2)-1)   ## The standard error of the mean (SEM) 
week4_1_SEM <- apply(week4, 2, sd)/sqrt(nrow(week4)-1)   ## The standard error of the mean (SEM) 
week6_1_SEM <- apply(week6, 2, sd)/sqrt(nrow(week6)-1)   ## The standard error of the mean (SEM) 
week8_1_SEM <- apply(week8, 2, sd)/sqrt(nrow(week8)-1)   ## The standard error of the mean (SEM) 
nonzero_1 <- seq(from = 1,  by=10,  length.out=binNum/10)
week1_1_SEM[-nonzero_1] <- NA
week2_1_SEM[-nonzero_1] <- NA
week4_1_SEM[-nonzero_1] <- NA
week6_1_SEM[-nonzero_1] <- NA
week8_1_SEM[-nonzero_1] <- NA
SEM_1 <- c( week1_1_SEM, week2_1_SEM, week4_1_SEM,  week6_1_SEM, week8_1_SEM ) 
#week1_1_SD <- apply(week1, 2, sd)   ## standard deviation 
#week2_1_SD <- apply(week2, 2, sd)   ## standard deviation 
#week4_1_SD <- apply(week4, 2, sd)   ## standard deviation 
#week6_1_SD <- apply(week6, 2, sd)   ## standard deviation 
#week8_1_SD <- apply(week8, 2, sd)   ## standard deviation
#nonzero_1 <- seq(from = 1,  by=10,  length.out=60)
#week1_1_SD[-nonzero_1] <- NA
#week2_1_SD[-nonzero_1] <- NA
#week4_1_SD[-nonzero_1] <- NA
#week6_1_SD[-nonzero_1] <- NA
#week8_1_SD[-nonzero_1] <- NA
#SD_1 <- c( week1_1_SD, week2_1_SD, week4_1_SD,  week6_1_SD, week8_1_SD ) 
dataframe_1    <- data.frame(xAxis = x_Axis_1,  yAxis = y_Axis_1,  sampleType = sampleType_1,  Error = SEM_1) 
limits_1 <- aes( ymax = yAxis+Error,  ymin = yAxis-Error )
#############
CairoSVG(file = "Figures-noscale/1-c-TSS-errorbar-noscale.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
    ggplot(data=dataframe_1, aes(x=xAxis, y=dataframe_1$yAxis,  color=sampleType) )  +   
    xlab("Relative Distance to CSSs (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("TSS Peaks") + 
    scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) + 
    geom_errorbar(limits_1,   width=0.03) +   
    geom_line(size=0.3) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
    scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) +  
    pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) )  
dev.off() 









sink("Figures-noscale/1-d-nucleosomeoccupancy-diff-H3.txt")
wilcox.test(x= H3_1 [(1:peakSize)],                                                y = H3_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= H3_1[((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_1[(300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
wilcox.test(x= H3_1[(1:peakSize)],                                                  y = H3_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= H3_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

t.test(x= H3_1[ (1:peakSize)],                                                 y = H3_1[(300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
t.test(x= H3_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_1[(300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
t.test(x= H3_1[ (1:peakSize)],                                                 y = H3_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= H3_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = H3_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

print( mean( H3_1 [(1:peakSize)]) )
print("###############################################################################################")
print( mean(H3_1[ (300:330)]) )
print("###############################################################################################")
print( mean(H3_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))]) )
print("###############################################################################################")

sink()










sink("Figures-noscale/1-d-nucleosomeoccupancy-diff-week1.txt")

wilcox.test(x= week1_1[(1:peakSize)],                                                  y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= week1_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
wilcox.test(x= week1_1[(1:peakSize)],                                                  y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= week1_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],     y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

t.test(x= week1_1[ (1:peakSize)],                                                  y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
t.test(x= week1_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],      y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
t.test(x= week1_1[ (1:peakSize)],                                                  y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= week1_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))],      y = week1_1[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

print( mean( week1_1 [(1:peakSize)]) )
print("###############################################################################################")
print( mean(week1_1[ (300:330)]) )
print("###############################################################################################")
print( mean(week1_1[ ((upStream+downStream+1):(upStream+peakSize+downStream))]) )
print("###############################################################################################")

sink()


####################################################################  End    ##########################################################################################################################################

























## part 5: nucleosome occupancy bar
####################################################################  Start  ##########################################################################################################################################

########################################################  a. all sites (peaks±2000bp)
y_Axis_2  <- c( week1_all, week2_all, week4_all, week6_all, week8_all) 
y_Axis_2[y_Axis_2 > 3]  <- 3
sampleType_2 <-  c( rep("1", length(week1_all)), rep("2", length(week2_all)), rep("4", length(week4_all)), rep("6", length(week6_all)), rep("8", length(week8_all)) ) 
dataframe_2 <- data.frame(sampleType = sampleType_2, yAxis = y_Axis_2  )  ## the order is very important.
dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath3 <- data.frame( x=c(2.05, 2.05, 3.95, 3.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(3.2, 3.3, 3.3, 3.2) )  
sink("Figures-noscale/2-a-wilcoxon-test-paired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_all, y = week1_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_all, y = week2_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_all, y = week4_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_all, y = week6_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-a-wilcoxon-test-unpaired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_all, y = week1_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_all, y = week2_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_all, y = week4_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_all, y = week6_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-a-t-test-paired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_all, y = week1_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_all, y = week2_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_all, y = week4_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_all, y = week6_all, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-a-t-test-unpaired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_all, y = week1_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_all, y = week2_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_all, y = week4_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_all, y = week6_all, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()



sink("Figures-noscale/2-a-barplot.log.txt")

#########################
CairoSVG(file = "Figures-noscale/2-a-occupancy-bar_allSites.svg",   width = 4, height =4, onefile = TRUE, bg = "white",  pointsize = 1 )
    ggplot( dataframe_2, aes(x=sampleType) ) + 
    geom_errorbar( aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.3, size=0.4 ) +
    geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.004, size=0.4, fill="gray" ) +  
    xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "TSS Peaks ± 2000bp" )  +  
    pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))    + 
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################


########################
CairoSVG(file = "Figures-noscale/2-a-occupancy-violin_allSites.svg",   width = 4, height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
    ggplot(dataframe_2, aes(x=sampleType) ) + 
    geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4) +
    geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.0, size=0.2, colour = "black") +
    geom_boxplot( aes(y=yAxis),  width=0.1, size=0.4, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.2) + 
    stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=1, show_guide = FALSE) + 
    xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("TSS Peaks ± 2000bp")  +
    pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))  +
    geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
    geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
    geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
    geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################

sink()












########################################################  b. downstream
y_Axis_2  <- c( week1_down, week2_down, week4_down, week6_down, week8_down) 
y_Axis_2[y_Axis_2 > 3]  <- 3
sampleType_2 <-  c( rep("1", length(week1_down)), rep("2", length(week2_down)), rep("4", length(week4_down)), rep("6", length(week6_down)), rep("8", length(week8_down)) ) 
dataframe_2 <- data.frame(sampleType = sampleType_2, yAxis = y_Axis_2  )  ## the order is very important.
dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath3 <- data.frame( x=c(2.05, 2.05, 3.95, 3.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(3.2, 3.3, 3.3, 3.2) ) 
sink("Figures-noscale/2-b-wilcoxon-test-paired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_down, y = week1_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_down, y = week2_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_down, y = week4_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_down, y = week6_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-b-wilcoxon-test-unpaired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_down, y = week1_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_down, y = week2_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_down, y = week4_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_down, y = week6_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-b-t-test-paired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_down, y = week1_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_down, y = week2_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_down, y = week4_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_down, y = week6_down, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-b-t-test-unpaired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_down, y = week1_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_down, y = week2_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_down, y = week4_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_down, y = week6_down, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()



sink("Figures-noscale/2-b-barplot.log.txt")

#########################
CairoSVG(file = "Figures-noscale/2-b-occupancy-bar_downstream.svg",   width = 4, height =4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( dataframe_2, aes(x=sampleType) ) + 
  geom_errorbar( aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.3, size=0.4 ) +
  geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.004, size=0.4, fill="gray" ) +  
  xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "Down Streams of TSS Peaks" )  +  
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))    + 
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################


########################
CairoSVG(file = "Figures-noscale/2-b-occupancy-violin_downstream.svg",   width = 4, height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(dataframe_2, aes(x=sampleType) ) + 
  geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4) +
  geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.0, size=0.2, colour = "black") +
  geom_boxplot( aes(y=yAxis),  width=0.1, size=0.4, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.2) + 
  stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=1, show_guide = FALSE) + 
  xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("Down Streams of TSS Peaks")  +
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))  +
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################

sink()















########################################################  c. upstream
y_Axis_2  <- c( week1_up, week2_up, week4_up, week6_up, week8_up) 
y_Axis_2[y_Axis_2 > 3]  <- 3
sampleType_2 <-  c( rep("1", length(week1_up)), rep("2", length(week2_up)), rep("4", length(week4_up)), rep("6", length(week6_up)), rep("8", length(week8_up)) ) 
dataframe_2 <- data.frame(sampleType = sampleType_2, yAxis = y_Axis_2  )  ## the order is very important.
dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath3 <- data.frame( x=c(2.05, 2.05, 3.95, 3.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(3.2, 3.3, 3.3, 3.2) )  
sink("Figures-noscale/2-c-wilcoxon-test-paired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_up, y = week1_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_up, y = week2_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_up, y = week4_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_up, y = week6_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-c-wilcoxon-test-unpaired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_up, y = week1_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_up, y = week2_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_up, y = week4_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_up, y = week6_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-c-t-test-paired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_up, y = week1_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_up, y = week2_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_up, y = week4_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_up, y = week6_up, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-c-t-test-unpaired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_up, y = week1_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_up, y = week2_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_up, y = week4_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_up, y = week6_up, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()





sink("Figures-noscale/2-c-barplot.log.txt")

#########################
CairoSVG(file = "Figures-noscale/2-c-occupancy-bar_upstream.svg",   width = 4, height =4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( dataframe_2, aes(x=sampleType) ) + 
  geom_errorbar( aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.3, size=0.4 ) +
  geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.004, size=0.4, fill="gray" ) +  
  xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "Up Streams of TSS Peaks" )  +  
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))    + 
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################


########################
CairoSVG(file = "Figures-noscale/2-c-occupancy-violin_upstream.svg",   width = 4, height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(dataframe_2, aes(x=sampleType) ) + 
  geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4) +
  geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.0, size=0.2, colour = "black") +
  geom_boxplot( aes(y=yAxis),  width=0.1, size=0.4, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.2) + 
  stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=1, show_guide = FALSE) + 
  xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("Up Streams of TSS Peaks")  +
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))  +
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################

sink()










########################################################  d. peaks
y_Axis_2  <- c( week1_peak, week2_peak, week4_peak, week6_peak, week8_peak) 
y_Axis_2[y_Axis_2 > 3]  <- 3
sampleType_2 <-  c( rep("1", length(week1_peak)), rep("2", length(week2_peak)), rep("4", length(week4_peak)), rep("6", length(week6_peak)), rep("8", length(week8_peak)) ) 
dataframe_2 <- data.frame(sampleType = sampleType_2, yAxis = y_Axis_2  )  ## the order is very important.
dataframePath1 <- data.frame( x=c(1.00, 1.00, 1.95, 1.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath2 <- data.frame( x=c(2.05, 2.05, 2.95, 2.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath3 <- data.frame( x=c(2.05, 2.05, 3.95, 3.95),  y=c(3.2, 3.3, 3.3, 3.2) )  
dataframePath4 <- data.frame( x=c(4.05, 4.05, 5.00, 5.00),  y=c(3.2, 3.3, 3.3, 3.2) )  
sink("Figures-noscale/2-d-wilcoxon-test-paired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_peak, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_peak, y = week2_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_peak, y = week4_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_peak, y = week6_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-d-wilcoxon-test-unpaired.log.txt")
print("##################################################################################################################################")
wilcox.test(x= week2_peak, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week4_peak, y = week2_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week6_peak, y = week4_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
wilcox.test(x= week8_peak, y = week6_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-d-t-test-paired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_peak, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_peak, y = week2_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_peak, y = week4_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_peak, y = week6_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
sink()
sink("Figures-noscale/2-d-t-test-unpaired.log.txt")
print("##################################################################################################################################")
t.test(x= week2_peak, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week4_peak, y = week2_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week6_peak, y = week4_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("##################################################################################################################################")
t.test(x= week8_peak, y = week6_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
sink()





sink("Figures-noscale/2-d-barplot.log.txt")

#########################
CairoSVG(file = "Figures-noscale/2-d-occupancy-bar_Peaks.svg",   width = 4, height =4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( dataframe_2, aes(x=sampleType) ) + 
  geom_errorbar( aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.3, size=0.4 ) +
  geom_boxplot( width=0.7,   aes(y=yAxis), outlier.colour="gray",  outlier.shape=1, outlier.size=0.004, size=0.4, fill="gray" ) +  
  xlab( "Time (week)" ) + ylab( "H2B-GFP Signal" ) + ggtitle( "TSS Peaks" )  +  
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))    + 
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################


########################
CairoSVG(file = "Figures-noscale/2-d-occupancy-violin_Peaks.svg",   width = 4, height = 4, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(dataframe_2, aes(x=sampleType) ) + 
  geom_violin(aes(y=yAxis), fill = "gray", colour = "gray", adjust = 4) +
  geom_errorbar(aes(ymin=min,ymax=max),  data=whisk(dataframe_2),   width = 0.0, size=0.2, colour = "black") +
  geom_boxplot( aes(y=yAxis),  width=0.1, size=0.4, fill="black", outlier.size=0,  colour = "black", notch=FALSE,  notchwidth = 0.2) + 
  stat_summary( aes(y=yAxis),   fun.y=mean, colour="white", geom="point", shape=19, size=1, show_guide = FALSE) + 
  xlab("Time (week)") + ylab("H2B-GFP Signal") + ggtitle("TSS Peaks")  +
  pTheme + guides(colour = guide_legend(override.aes = list(size=2.0, shape=22)))  +
  geom_path( data = dataframePath1, aes(x = x, y = y), size=0.3 ) + annotate("text", x=1.5, y=3.4, label="p<3e-16", size=3.5) + 
  geom_path( data = dataframePath2, aes(x = x, y = y), size=0.3 ) + annotate("text", x=2.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath3, aes(x = x, y = y), size=0.3 ) + annotate("text", x=3.5, y=3.4, label="p<3e-16", size=3.5) +
  geom_path( data = dataframePath4, aes(x = x, y = y), size=0.3 ) + annotate("text", x=4.5, y=3.4, label="p<3e-16", size=3.5)
dev.off() 
########################

sink()











sink("Figures-noscale/2-e-occupancyDiff-week1.log.txt")

wilcox.test(x= week1_up,   y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= week1_down, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
wilcox.test(x= week1_up,   y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= week1_down, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

t.test(x= week1_up,   y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= week1_down, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
t.test(x= week1_up,   y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= week1_down, y = week1_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

print( mean(week1_up) )
print("###############################################################################################")
print( mean(week1_peak) )
print("###############################################################################################")
print( mean(week1_down) )
print("###############################################################################################")

sink()







sink("Figures-noscale/2-e-occupancyDiff-H3.log.txt")

wilcox.test(x= H3_up,   y = H3_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= H3_down, y = H3_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
wilcox.test(x= H3_up,   y = H3_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
wilcox.test(x= H3_down, y = H3_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

t.test(x= H3_up,   y = H3_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= H3_down, y = H3_peak, alternative = "two.sided",  mu = 0,  paired = TRUE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")
t.test(x= H3_up,   y = H3_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
t.test(x= H3_down, y = H3_peak, alternative = "two.sided",  mu = 0,  paired = FALSE,  var.equal = FALSE, conf.level = 0.95)
print("###############################################################################################")

print( mean(H3_up) )
print("###############################################################################################")
print( mean(H3_peak) )
print("###############################################################################################")
print( mean(H3_down) )
print("###############################################################################################")

sink()

####################################################################  End    ##########################################################################################################################################
























##Part 6: The distribution of nucleosome turnover
####################################################################  Start    ##########################################################################################################################################

week1_3  <- colMeans(week1,  na.rm = TRUE) 
week2_3  <- colMeans(week2,  na.rm = TRUE) 
week4_3  <- colMeans(week4,  na.rm = TRUE)
week6_3  <- colMeans(week6,  na.rm = TRUE) 
week8_3  <- colMeans(week8,  na.rm = TRUE) 

turnoverDis_3 <- c()
sink("Figures-noscale/3-a-Linear-Regression-model.txt")
for ( i in 1:length(week1_3) ) {
  tur <- turnoverRate(week1_3[i], week2_3[i], week4_3[i], week6_3[i], week8_3[i])
  turnoverDis_3 <- c(turnoverDis_3, tur)
  print("***********************************************")
  print(week1_3[i])
  print(week2_3[i])
  print(week4_3[i])
  print(week6_3[i])
  print(week8_3[i])
  print("***********************************************")
}
sink()
length(turnoverDis_3)
halfLifeDis_3 <- log(2)/turnoverDis_3
binNum_3 = binNum
Position_3  <- seq(from = -downStream/100,,  by=0.01,  length.out=binNum_3)
xVar_3 <- c(1,2,4,6,8)
turnoverDis_3_frame3 <- ksmooth(x=Position_3,   y=turnoverDis_3,     kernel = "normal",   bandwidth = 0.1)
turnoverDis_3_3a     <- turnoverDis_3_frame3$y
dataframe_3a         <- data.frame(xAxis = Position_3, yAxis = turnoverDis_3_3a) 


write.table( turnoverDis_3,  file = "Figures-noscale/3-a-turnoverDis.txt",  append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
write.table( halfLifeDis_3,  file = "Figures-noscale/3-a-halfLifeDis.txt",  append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )


CairoSVG(file = "Figures-noscale/3-a-turnoverDis.svg",    width = 4,  height = 3,   onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_3a, aes(x=xAxis, y=dataframe_3a$yAxis) )  +   
    xlab("Relative Distance (kb)") + ylab("Turnover Rate") + ggtitle("TSS Peaks") + ##ylim(2, 12) +
    geom_line(size=0.8) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
    scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
    pTheme +
    theme( 
      line         = element_line(colour="black", size=1.0,  linetype=1,     lineend=NULL),                                                           ## all line elements.  局部优先总体,下面3个也是,只对非局部设置有效.   所有线属性.
      rect         = element_rect(colour="black", size=1.0,  linetype=1,     fill="transparent" ),                                                    ## all rectangluar elements.    hjust=1: 靠右对齐.   所有矩形区域属性.
      text         = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,   angle=NULL, lineheight=NULL),        ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
      title        = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,     angle=NULL, lineheight=NULL),        ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.
      axis.title   = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,   angle=NULL, lineheight=NULL),        ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
      axis.title.x = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=-10,    angle=NULL, lineheight=NULL),        ## x axis label (element_text; inherits from axis.title)
      axis.title.y = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,     angle=NULL, lineheight=NULL),        ## y axis label (element_text; inherits from axis.title)
      legend.title = element_text("")                                                                                                                 ## title of legend (element_text; inherits from title)
    ) 
dev.off() 


halfLifeDis_frame3 <-  ksmooth(x=Position_3,   y=halfLifeDis_3,     kernel = "normal",   bandwidth = 0.2)
halfLifeDis_3b     <- halfLifeDis_frame3$y
dataframe_3b       <- data.frame(xAxis = Position_3, yAxis = halfLifeDis_3b) 
CairoSVG(file = "Figures-noscale/3-a-halfLifeDis.svg",    width = 4,  height = 3,   onefile = TRUE, bg = "white",  pointsize = 1 )
    ggplot(data=dataframe_3b, aes(x=xAxis, y=dataframe_3b$yAxis) )  +   
    xlab("Relative Distance (kb)") + ylab("Half-life (weeks)") + ggtitle("TSS Peaks") + ##ylim(2, 12) +
    geom_line(size=0.8) + 
    geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  geom_vline(xintercept=peakSize/100, lty=2, col="gray", size=0.5) + 
    scale_x_continuous( breaks=c(-2,  -1,  0,  0+peakSize/100, 1+peakSize/100,  2+peakSize/100), labels=c("-2",  "-1",  "5'",  "3'",  "1",  "2") ) +  
    pTheme +
    theme( 
        line         = element_line(colour="black", size=1.0,  linetype=1,     lineend=NULL),                                                         ## all line elements.  局部优先总体,下面3个也是,只对非局部设置有效.   所有线属性.
        rect         = element_rect(colour="black", size=1.0,  linetype=1,     fill="transparent" ),                                                  ## all rectangluar elements.    hjust=1: 靠右对齐.   所有矩形区域属性.
        text         = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,  angle=NULL, lineheight=NULL),       ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
        title        = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,    angle=NULL, lineheight=NULL),       ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.
        axis.title   = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,  angle=NULL, lineheight=NULL),       ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
        axis.title.x = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=-10,   angle=NULL, lineheight=NULL),       ## x axis label (element_text; inherits from axis.title)
        axis.title.y = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,    angle=NULL, lineheight=NULL),       ## y axis label (element_text; inherits from axis.title)
        legend.title = element_text("")                                                                                                               ## title of legend (element_text; inherits from title)
    ) 
dev.off() 









sink("Figures-noscale/3-b-nucleosomeTurnover-diff-week1.txt")

wilcox.test(x= turnoverDis_3[ (1:peakSize)],                                                           y = turnoverDis_3[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = TRUE,  conf.level = 0.95)
wilcox.test(x= turnoverDis_3[ (upStream + downStream + 1):(upStream + peakSize + downStream) ],        y = turnoverDis_3[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)
     t.test(x= turnoverDis_3[ (1:peakSize)],                                                           y = turnoverDis_3[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = TRUE,  conf.level = 0.95)
     t.test(x= turnoverDis_3[ (upStream + downStream + 1):(upStream + peakSize + downStream) ],        y = turnoverDis_3[ (300:330)],     alternative = "two.sided",  mu = 0,  paired = TRUE,   var.equal = FALSE, conf.level = 0.95)

print( mean(turnoverDis_3[ (1:peakSize)]) )
print("###############################################################################################")
print( mean(turnoverDis_3[ (300:330)]) )
print("###############################################################################################")
print( mean(turnoverDis_3[ (upStream + downStream + 1):(upStream + peakSize + downStream) ]) )
print("###############################################################################################")

sink()






####################################################################  End    ##########################################################################################################################################



























## Part 7:  overall occupancy change  AND  half-life
####################################################################  Start    ##########################################################################################################################################

week1_4A <- mean(week1_1[300:330])  ##Peaks
week2_4A <- mean(week2_1[300:330])
week4_4A <- mean(week4_1[300:330])
week6_4A <- mean(week6_1[300:330])
week8_4A <- mean(week8_1[300:330])
vector_occupancy_4A <- c(week1_4A, week2_4A, week4_4A, week6_4A, week8_4A)
vector_halflife_y_4A <- log(vector_occupancy_4A)
vector_halflife_x_4A <- c(1, 2, 4, 6, 8)
dataframe_4A  <- data.frame(xAxis = vector_halflife_x_4A, yAxis = vector_halflife_y_4A) 
regression_4A <- lm(vector_halflife_y_4A ~ vector_halflife_x_4A)
sink("Figures-noscale/4-A-regression_Peaks.txt")
summary(regression_4A)
sink()

week1_4B <- mean(week1_1)  ## Peaks±2000bp
week2_4B <- mean(week2_1)
week4_4B <- mean(week4_1)
week6_4B <- mean(week6_1)
week8_4B <- mean(week8_1)
vector_occupancy_4B <- c(week1_4B, week2_4B, week4_4B, week6_4B, week8_4B)
vector_halflife_y_4B <- log(vector_occupancy_4B)
vector_halflife_x_4B <- c(1, 2, 4, 6, 8)
dataframe_4B  <- data.frame(xAxis = vector_halflife_x_4B, yAxis = vector_halflife_y_4B) 
regression_4B <- lm(vector_halflife_y_4B ~ vector_halflife_x_4B)
sink("Figures-noscale/4-B-regression_ Peaks±2000bp.txt")
summary(regression_4B)
sink()

week1_4C <- mean(week1_1[1:upStream])  ## upstream
week2_4C <- mean(week2_1[1:upStream])
week4_4C <- mean(week4_1[1:upStream])
week6_4C <- mean(week6_1[1:upStream])
week8_4C <- mean(week8_1[1:upStream])
vector_occupancy_4C <- c(week1_4C, week2_4C, week4_4C, week6_4C, week8_4C)
vector_halflife_y_4C <- log(vector_occupancy_4C)
vector_halflife_x_4C <- c(1, 2, 4, 6, 8)
dataframe_4C  <- data.frame(xAxis = vector_halflife_x_4C, yAxis = vector_halflife_y_4C) 
regression_4C <- lm(vector_halflife_y_4C ~ vector_halflife_x_4C)
sink("Figures-noscale/4-C-regression_Upstream.txt")
summary(regression_4C)
sink()


week1_4D <- mean(week1_1[400:600])  ## downstream
week2_4D <- mean(week2_1[400:600])
week4_4D <- mean(week4_1[400:600])
week6_4D <- mean(week6_1[400:600])
week8_4D <- mean(week8_1[400:600])
vector_occupancy_4D <- c(week1_4D, week2_4D, week4_4D, week6_4D, week8_4D)
vector_halflife_y_4D <- log(vector_occupancy_4D)
vector_halflife_x_4D <- c(1, 2, 4, 6, 8)
dataframe_4D  <- data.frame(xAxis = vector_halflife_x_4D, yAxis = vector_halflife_y_4D) 
regression_4D <- lm(vector_halflife_y_4D ~ vector_halflife_x_4D)
sink("Figures-noscale/4-D-regression_Downstream.txt")
summary(regression_4D)
sink()

sampleType4 <- c( rep.int("TSS Peaks", 5),  rep.int("Peaks ± 2000bp", 5),  rep.int("Up streams of Peaks", 5),  rep.int("Down streams of Peaks", 5) ) 
dataframe4 <- data.frame( xAxis=c(dataframe_4A$xAxis, dataframe_4B$xAxis, dataframe_4C$xAxis, dataframe_4D$xAxis), yAxis=c(dataframe_4A$yAxis, dataframe_4B$yAxis, dataframe_4C$yAxis, dataframe_4D$yAxis),  sampleType=sampleType4 )

CairoSVG(file = "Figures-noscale/4-Z-occupancy-halflife.svg",   width = 6.0, height = 4.0, onefile = TRUE, bg = "white",  pointsize = 1 )

ggplot( data = dataframe4, aes(x = xAxis, y = yAxis, color=sampleType ) ) + 
  geom_point(size=2) +  
  scale_colour_manual( values=c("TSS Peaks" = "gold4",  "Peaks ± 2000bp" = "green4",   "Up streams of Peaks"="red4", "Down streams of Peaks"="blue4") ,    breaks=c("TSS Peaks",  "Peaks ± 2000bp",  "Up streams of Peaks", "Down streams of Peaks") ) +  
  xlab("Time (week)") +   ylab("ln(H2B-GFP Signal)") +   ggtitle("Four Regions around TSS Peaks") + 
  geom_text( aes(x = 4.5, y = 0.2,   label = lmEquation( regression_4A )), parse = TRUE, family="serif", colour="gold4",       fontface=4,  size=3,  lineheight=1, alpha=0.09 ) +
  geom_text( aes(x = 4.5, y = 0.1,   label = lmEquation( regression_4B )), parse = TRUE, family="serif", colour="green4",      fontface=4,  size=3,  lineheight=1, alpha=0.09 ) +
  geom_text( aes(x = 4.5, y = 0.0,   label = lmEquation( regression_4C )), parse = TRUE, family="serif", colour="red4",        fontface=4,  size=3,  lineheight=1, alpha=0.09 ) +
  geom_text( aes(x = 4.5, y = -0.1,   label = lmEquation( regression_4D )), parse = TRUE, family="serif", colour="blue4",       fontface=4,  size=3,  lineheight=1, alpha=0.09 ) +  
  geom_smooth(data=dataframe_4A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="gold4" ) + 
  geom_smooth(data=dataframe_4B, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="green4") + 
  geom_smooth(data=dataframe_4C, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4"  ) + 
  geom_smooth(data=dataframe_4D, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="blue4" ) +
  scale_x_continuous( breaks=c(1, 2, 3, 4, 5, 6, 7, 8) ) + 
  pTheme + guides( colour = guide_legend(override.aes = list(size=5.0))  ) 

dev.off() 

####################################################################  End    ##########################################################################################################################################



































## Part 8: turnover on each fragment
####################################################################  Start    ##########################################################################################################################################

smallNum_5 <- 10**(-10)


##  Peaks
week2_5A <- rowSums(week2[, 300:330])
week6_5A <- rowSums(week6[, 300:330])
turnoverRate_5A <- -( week6_5A - week2_5A )/(4*week2_5A + smallNum_5)
length(turnoverRate_5A)
halfLife_5A <- log(2)/turnoverRate_5A
length(halfLife_5A)

min(halfLife_5A)
max(halfLife_5A)
length(halfLife_5A[halfLife_5A > 30])
length(halfLife_5A[halfLife_5A < 0.01])
halfLife_5A[halfLife_5A >  30]  <- NA
halfLife_5A[halfLife_5A < 0.01]  <- NA
length(halfLife_5A)

halfLife_5A <- as.numeric(halfLife_5A[!is.na(halfLife_5A)])
length(halfLife_5A)
dataframe_5A  <- data.frame(xAxis = halfLife_5A) 
mean(halfLife_5A)
length( halfLife_5A[ (halfLife_5A < 2) &  (halfLife_5A >0) ] )


###############################################
CairoSVG(file = "Figures-noscale/5-A-halfLifeDis_Peaks.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5A, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("TSS Peaks")  +  ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..), fill = ..count.. ) )  +  
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################


###############################################
dataframe_5A  <- data.frame(xAxis = halfLife_5A) 
CairoSVG(file = "Figures-noscale/5-A-halfLifeDis_nonColour_Peaks.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5A, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("TSS Peaks")  +   ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################









## downstream
week2_5B <- rowSums(week2[, 400:600])
week6_5B <- rowSums(week6[, 400:600])
turnoverRate_5B <- -( week6_5B - week2_5B )/(4*week2_5B + smallNum_5)
length(turnoverRate_5B)
halfLife_5B <- log(2)/turnoverRate_5B
length(halfLife_5B)

min(halfLife_5B)
max(halfLife_5B)
length(halfLife_5B[halfLife_5B > 30])
length(halfLife_5B[halfLife_5B < 0.01])
halfLife_5B[halfLife_5B >  30]  <- NA
halfLife_5B[halfLife_5B < 0.01] <- NA
length(halfLife_5B)

halfLife_5B <- as.numeric(halfLife_5B[!is.na(halfLife_5B)])
length(halfLife_5B)
dataframe_5B  <- data.frame(xAxis = halfLife_5B) 
mean(halfLife_5B)
length( halfLife_5B[ (halfLife_5B < 2) &  (halfLife_5B >0) ] )


###############################################
CairoSVG(file = "Figures-noscale/5-B-halfLifeDis_downstream.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5B, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("Down Streams of TSS Peaks")  +  ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..), fill = ..count.. ) )  +  
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################


###############################################
dataframe_5B  <- data.frame(xAxis = halfLife_5B) 
CairoSVG(file = "Figures-noscale/5-B-halfLifeDis_nonColour_downstream.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5B, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("Down Streams of TSS Peaks")  +   ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################












## upstream
week2_5C <- rowSums(week2[, 1:upStream])
week6_5C <- rowSums(week6[, 1:upStream])
turnoverRate_5C <- -( week6_5C - week2_5C )/(4*week2_5C + smallNum_5)
length(turnoverRate_5C)
halfLife_5C <- log(2)/turnoverRate_5C
length(halfLife_5C)

min(halfLife_5C)
max(halfLife_5C)
length(halfLife_5C[halfLife_5C > 30])
length(halfLife_5C[halfLife_5C < 0.01])
halfLife_5C[halfLife_5C >  30]  <- NA
halfLife_5C[halfLife_5C < 0.01]  <- NA
length(halfLife_5C)

halfLife_5C <- as.numeric(halfLife_5C[!is.na(halfLife_5C)])
length(halfLife_5C)
dataframe_5C  <- data.frame(xAxis = halfLife_5C) 
mean(halfLife_5C)
length( halfLife_5C[ (halfLife_5C < 2) &  (halfLife_5C >0) ] )


###############################################
CairoSVG(file = "Figures-noscale/5-C-halfLifeDis_upstreams.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5C, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("Up streams of TSS Peaks")  +   ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..), fill = ..count.. ) )  +  
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################


###############################################
dataframe_5C  <- data.frame(xAxis = halfLife_5C) 
CairoSVG(file = "Figures-noscale/5-C-halfLifeDis_nonColour_upstreams.svg",   width = 4, height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_5C, aes(x=xAxis) )  +   
  xlab("Half-life (week)") + 
  ylab("Relative frequency") + 
  ggtitle("Up streams of TSS Peaks")  +    ylim(0, 0.25) +
  geom_histogram(binwidth = 0.5, aes(y = (..count..)/sum(..count..))  )  + 
  scale_x_continuous( breaks=c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30), labels=c('0', '3', '6', '9', '12', '15', '18', '21', '24', '27', '30') ) + 
  pTheme  +  guides( colour = guide_legend( override.aes = list(size=0.5) ) )
dev.off() 
###############################################



####################################################################  End    ##########################################################################################################################################























## Part 9: Correlation between nucleosome turnover rate and nucleosome occupancy level
####################################################################  Start    ##########################################################################################################################################

week1_6  <- colMeans(week1,  na.rm = TRUE) 
week2_6  <- colMeans(week2,  na.rm = TRUE) 
week4_6  <- colMeans(week4,  na.rm = TRUE)
week6_6  <- colMeans(week6,  na.rm = TRUE) 
week8_6  <- colMeans(week8,  na.rm = TRUE) 
length(week1_6)
length(week2_6)
length(week4_6)
length(week6_6)
length(week8_6)

turnoverDis_6 <- c()
sink("Figures-noscale/6-a-Linear-Regression-model.txt")
for ( i in 1:length(week1_6) ) {
  tur <- turnoverRate(week1_6[i], week2_6[i], week4_6[i], week6_6[i], week8_6[i])
  turnoverDis_6 <- c(turnoverDis_6, tur)
  print("***********************************************")
  print(week1_6[i])
  print(week2_6[i])
  print(week4_6[i])
  print(week6_6[i])
  print(week8_6[i])
  print("***********************************************")
}
sink()
length(turnoverDis_6)

NucOccup6 <- data.frame(occupancy1 = week1_6)
Turnover6 <- data.frame(turnover1 = turnoverDis_6)



NCV_6 <-computeNCV( week1_6, turnoverDis_6 )
Position_6  <- seq(from =  -downStream/100,  by=0.01,  length.out=binNum)
NCV_frame <- ksmooth(x=Position_1,   y=NCV_6,     kernel = "normal",   bandwidth = 0.1)
NCV_6     <- NCV_frame$y
dataframe_6         <- data.frame(xAxis = Position_1, yAxis = NCV_6) 

CairoSVG(file = "Figures-noscale/6-NCV.svg",    width = 4,  height = 3,   onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot(data=dataframe_6, aes(x=xAxis, y=dataframe_6$yAxis) )  +   
  xlab("Relative Distance (kb)") + ylab("NCV") + ggtitle("TSS Peaks") + ##ylim(2, 12) +
  geom_line(size=0.8) +    #scale_y_continuous( breaks=c(0.05, 0.07, 0.09, 0.11) ) + 
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) +  pTheme +
  theme( 
    line         = element_line(colour="black", size=1.0,  linetype=1,     lineend=NULL),                                                           ## all line elements.  局部优先总体,下面3个也是,只对非局部设置有效.   所有线属性.
    rect         = element_rect(colour="black", size=1.0,  linetype=1,     fill="transparent" ),                                                    ## all rectangluar elements.    hjust=1: 靠右对齐.   所有矩形区域属性.
    text         = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,   angle=NULL, lineheight=NULL),        ## all text elements.  "sans" for a sans-sans font. 所有文本相关属性.
    title        = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,     angle=NULL, lineheight=NULL),        ## all title elements: plot, axes, legends. hjust:水平对齐的方向.  所有标题属性.
    axis.title   = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=NULL,   angle=NULL, lineheight=NULL),        ## label of axes (element_text; inherits from text).  horizontal: 水平的, 水平线 
    axis.title.x = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=-10,    angle=NULL, lineheight=NULL),        ## x axis label (element_text; inherits from axis.title)
    axis.title.y = element_text(family="sans",  face=NULL, colour="black", size=12,  hjust=NULL, vjust=10,     angle=NULL, lineheight=NULL),        ## y axis label (element_text; inherits from axis.title)
    legend.title = element_text("")                                                                                                                 ## title of legend (element_text; inherits from title)
  ) 
dev.off() 







sink("Figures-noscale/6-b-3Correlations.txt")
print("Pearson product-moment correlation coefficient:")
corr.test(x=NucOccup6, y = Turnover6,   use = "pairwise", method="pearson",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Spearman's rank correlation coefficient or Spearman's rho:")
corr.test(x=NucOccup6, y = Turnover6,   use = "pairwise", method="spearman", adjust="holm", alpha=.05)  ## pearson, spearman, kendall
print("########################################")
print("########################################")
print("Kendall rank correlation coefficient, commonly referred to as Kendall's tau (τ) coefficient:")
corr.test(x=NucOccup6, y = Turnover6,   use = "pairwise", method="kendall",  adjust="holm", alpha=.05)  ## pearson, spearman, kendall
sink()

xpostione6 <- ( max(week1_6) + min(week1_6) )/2
yposition6 <- max(turnoverDis_6) + 0.02

regression_6A <- lm(turnoverDis_6 ~ week1_6)
dataframe_6A <- data.frame( xAxis=week1_6, yAxis=turnoverDis_6 )
CairoSVG(file = "Figures-noscale/6-A-occupancy-turnover.svg",   width = 4.5, height = 4.5, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data = dataframe_6A, aes(x = xAxis, y = yAxis) ) + 
  geom_point(size=1) +  
  xlab("Nucleosome Occupancy Level") +   ylab("Nucleosome Turnover Rate") +   ggtitle("Correlation between nucleosome occupancy and its turnover") + 
  geom_text( aes(x = xpostione6, y = yposition6,   label = lmEquation( regression_6A )), parse = TRUE, colour="red4", family="serif",  fontface=4,  size=3.8,  lineheight=1, alpha=0.09 ) +
  geom_smooth(data=dataframe_6A, aes(x=xAxis,y=yAxis),  se=FALSE,  method = "lm",   color="red4" ) + 
  #scale_x_continuous( breaks=c(1, 2, 3, 4, 5, 6, 7, 8) ) + 
  pTheme + guides( colour = guide_legend(override.aes = list(size=5.0))  ) 
dev.off() 





sink("Figures-noscale/6-c-MINE.txt")
mine(x=NucOccup6 , y=turnoverDis_6,   master=NULL,  alpha=0.6,  C=15,  n.cores=6,  var.thr=1e-5,  eps=NULL)
sink()


####################################################################  End    ##########################################################################################################################################























## Nucleosome Occupancy Level  (NOL)
## Nucleosome Turnover Rate  (NTR)
## Nucleosome Contribution Value (NCV)
## Part 10: classify the matrix into 3 calsses.
####################################################################  Start    ##########################################################################################################################################
dim(week1)
dim(week2)
dim(week4)
dim(week6)
dim(week8)
dim(H3)
numRow <- nrow(week1)

oneClass <- numRow/3
index1 <- c(1:oneClass)
index2 <- c(oneClass:(oneClass*2))
index3 <- c((oneClass*2):numRow )







ylim10 = 0.8
xlim10=0.0



week1_10A  <- colMeans(week1[index1, ],  na.rm = TRUE) 
week2_10A  <- colMeans(week2[index1, ],  na.rm = TRUE) 
week4_10A  <- colMeans(week4[index1, ],  na.rm = TRUE)
week6_10A  <- colMeans(week6[index1, ],  na.rm = TRUE) 
week8_10A  <- colMeans(week8[index1, ],  na.rm = TRUE) 
turnoverDis_10A <- c()
for ( i in 1:length(week1_10A) ) {
  tur <- turnoverRate(week1_10A[i], week2_10A[i], week4_10A[i], week6_10A[i], week8_10A[i])
  turnoverDis_10A <- c(turnoverDis_10A, tur)
}
NCV_10A <-computeNCV(week1_10A, turnoverDis_10A )

write.table( turnoverDis_10A,  file = "Figures-noscale/7-A-nucleosometurnover.txt",    append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
write.table( week1_10A,        file = "Figures-noscale/7-A-week1Occupancy.txt",        append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )

Position_10A <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
week1_10A_frame <-  ksmooth(x=Position_1,   y=week1_10A,     kernel = "normal",   bandwidth = 0.1)
week2_10A_frame <-  ksmooth(x=Position_1,   y=week2_10A,     kernel = "normal",   bandwidth = 0.1)
week4_10A_frame <-  ksmooth(x=Position_1,   y=week4_10A,     kernel = "normal",   bandwidth = 0.1)
week6_10A_frame <-  ksmooth(x=Position_1,   y=week6_10A,     kernel = "normal",   bandwidth = 0.1)
week8_10A_frame <-  ksmooth(x=Position_1,   y=week8_10A,     kernel = "normal",   bandwidth = 0.1)
week1_10Aa <- week1_10A_frame$y
week2_10Aa <- week2_10A_frame$y
week4_10Aa <- week4_10A_frame$y
week6_10Aa <- week6_10A_frame$y
week8_10Aa <- week8_10A_frame$y
x_Axis_10A   <- c( Position_10A, Position_10A,   Position_10A,    Position_10A,  Position_10A)                       
y_Axis_10A   <- c( week1_10Aa, week2_10Aa, week4_10Aa,  week6_10Aa, week8_10Aa )  
sampleType_10A <- c( rep("week 1", binNum), rep("week 2", binNum),  rep("week 4", binNum),   rep("week 6", binNum), rep("week 8", binNum)  )                            
dataframe_10A  <- data.frame(xAxis = x_Axis_10A,  yAxis = y_Axis_10A,  sampleType = sampleType_10A) 
#####################################
CairoSVG(file = "Figures-noscale/10-A-TSS-occupancy.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10A,  aes(x=xAxis, y=dataframe_10A$yAxis,  color=sampleType) )  +   
  xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("TSSs (High)") + 
  scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
  geom_line(size=0.5) + ylim(xlim10, ylim10) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) +  
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################













week1_10B  <- colMeans(week1[index2, ],  na.rm = TRUE) 
week2_10B  <- colMeans(week2[index2, ],  na.rm = TRUE) 
week4_10B  <- colMeans(week4[index2, ],  na.rm = TRUE)
week6_10B  <- colMeans(week6[index2, ],  na.rm = TRUE) 
week8_10B  <- colMeans(week8[index2, ],  na.rm = TRUE) 
turnoverDis_10B <- c()
for ( i in 1:length(week1_10B) ) {
  tur <- turnoverRate(week1_10B[i], week2_10B[i], week4_10B[i], week6_10B[i], week8_10B[i])
  turnoverDis_10B <- c(turnoverDis_10B, tur)
}
NCV_10B <-computeNCV(week1_10B, turnoverDis_10B )

write.table( turnoverDis_10B,  file = "Figures-noscale/7-B-nucleosometurnover.txt",    append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
write.table( week1_10B,        file = "Figures-noscale/7-B-week1Occupancy.txt",        append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )

Position_10B <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
week1_10B_frame <-  ksmooth(x=Position_1,   y=week1_10B,     kernel = "normal",   bandwidth = 0.1)
week2_10B_frame <-  ksmooth(x=Position_1,   y=week2_10B,     kernel = "normal",   bandwidth = 0.1)
week4_10B_frame <-  ksmooth(x=Position_1,   y=week4_10B,     kernel = "normal",   bandwidth = 0.1)
week6_10B_frame <-  ksmooth(x=Position_1,   y=week6_10B,     kernel = "normal",   bandwidth = 0.1)
week8_10B_frame <-  ksmooth(x=Position_1,   y=week8_10B,     kernel = "normal",   bandwidth = 0.1)
week1_10Ba <- week1_10B_frame$y
week2_10Ba <- week2_10B_frame$y
week4_10Ba <- week4_10B_frame$y
week6_10Ba <- week6_10B_frame$y
week8_10Ba <- week8_10B_frame$y
x_Axis_10B   <- c( Position_10B, Position_10B,   Position_10B,    Position_10B,  Position_10B)                       
y_Axis_10B   <- c( week1_10Ba, week2_10Ba, week4_10Ba,  week6_10Ba, week8_10Ba )  
sampleType_10B <- c( rep("week 1", binNum), rep("week 2", binNum),  rep("week 4", binNum),   rep("week 6", binNum), rep("week 8", binNum)  )                            
dataframe_10B  <- data.frame(xAxis = x_Axis_10B,  yAxis = y_Axis_10B,  sampleType = sampleType_10B) 
#####################################
CairoSVG(file = "Figures-noscale/10-B-TSS-occupancy.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10B,  aes(x=xAxis, y=dataframe_10B$yAxis,  color=sampleType) )  +   
  xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("TSSs (Middle)") + 
  scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
  geom_line(size=0.5) + ylim(xlim10, ylim10) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) + 
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################









week1_10C  <- colMeans(week1[index3, ],  na.rm = TRUE) 
week2_10C  <- colMeans(week2[index3, ],  na.rm = TRUE) 
week4_10C  <- colMeans(week4[index3, ],  na.rm = TRUE)
week6_10C  <- colMeans(week6[index3, ],  na.rm = TRUE) 
week8_10C  <- colMeans(week8[index3, ],  na.rm = TRUE) 
turnoverDis_10C <- c()
for ( i in 1:length(week1_10C) ) {
  tur <- turnoverRate(week1_10C[i], week2_10C[i], week4_10C[i], week6_10C[i], week8_10C[i])
  turnoverDis_10C <- c(turnoverDis_10C, tur)
}
NCV_10C <-computeNCV( week1_10C, turnoverDis_10C )

write.table( turnoverDis_10C,  file = "Figures-noscale/7-C-nucleosometurnover.txt",    append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )
write.table( week1_10C,        file = "Figures-noscale/7-C-week1Occupancy.txt",        append = FALSE,  quote = TRUE,  sep = "\t",   eol = "\n",  na = "NA",  dec = ".",  row.names = FALSE,   col.names = FALSE,  qmethod = c("escape", "double"),  fileEncoding = "" )

Position_10C <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
week1_10C_frame <-  ksmooth(x=Position_1,   y=week1_10C,     kernel = "normal",   bandwidth = 0.1)
week2_10C_frame <-  ksmooth(x=Position_1,   y=week2_10C,     kernel = "normal",   bandwidth = 0.1)
week4_10C_frame <-  ksmooth(x=Position_1,   y=week4_10C,     kernel = "normal",   bandwidth = 0.1)
week6_10C_frame <-  ksmooth(x=Position_1,   y=week6_10C,     kernel = "normal",   bandwidth = 0.1)
week8_10C_frame <-  ksmooth(x=Position_1,   y=week8_10C,     kernel = "normal",   bandwidth = 0.1)
week1_10Ca <- week1_10C_frame$y
week2_10Ca <- week2_10C_frame$y
week4_10Ca <- week4_10C_frame$y
week6_10Ca <- week6_10C_frame$y
week8_10Ca <- week8_10C_frame$y
x_Axis_10C   <- c( Position_10C, Position_10C,   Position_10C,    Position_10C,  Position_10C)                       
y_Axis_10C   <- c( week1_10Ca, week2_10Ca, week4_10Ca,  week6_10Ca, week8_10Ca )  
sampleType_10C <- c( rep("week 1", binNum), rep("week 2", binNum),  rep("week 4", binNum),   rep("week 6", binNum), rep("week 8", binNum)  )                            
dataframe_10C  <- data.frame(xAxis = x_Axis_10C,  yAxis = y_Axis_10C,  sampleType = sampleType_10C) 
#####################################
CairoSVG(file = "Figures-noscale/10-C-TSS-occupancy.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10C,  aes(x=xAxis, y=dataframe_10C$yAxis,  color=sampleType) )  +   
  xlab("Relative Distance (kb)") +  ylab("H2B-GFP Signal") +  ggtitle("TSSs (Low)") + 
  scale_colour_manual( values=c("green4",  "green",  "yellowgreen", "gold", "gold4") ) +     
  geom_line(size=0.5) + ylim(xlim10, ylim10) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) + 
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################








Position_10D <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
NCV_high_10_frame   <-  ksmooth(x=Position_10D,   y=NCV_10A,     kernel = "normal",   bandwidth = 0.1)
NCV_middle_10_frame <-  ksmooth(x=Position_10D,   y=NCV_10B,     kernel = "normal",   bandwidth = 0.1)
NCV_low_10_frame    <-  ksmooth(x=Position_10D,   y=NCV_10C,     kernel = "normal",   bandwidth = 0.1)
NCV_high   <- NCV_high_10_frame$y
NCV_middle <- NCV_middle_10_frame$y
NCV_low    <- NCV_low_10_frame$y

x_Axis_10D   <- c( Position_10D,    Position_10D,  Position_10D)                       
y_Axis_10D   <- c( NCV_high, NCV_middle, NCV_low )  
sampleType_10D <- c( rep("High", binNum), rep("Middle", binNum),  rep("Low", binNum))                            
dataframe_10D  <- data.frame(xAxis = x_Axis_10D,  yAxis = y_Axis_10D,  sampleType = sampleType_10D) 
#####################################
CairoSVG(file = "Figures-noscale/10-D-NCV.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10D,  aes(x=xAxis, y=dataframe_10D$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("NCV") +  ggtitle("TSSs") + 
  scale_colour_manual( values=c("High" = "green4",  "Middle" = "green",   "Low"="yellowgreen") ,    breaks=c("High",  "Middle",  "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) + 
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################

 













Position_10E <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
NCV_high_10_frame   <-  ksmooth(x=Position_10E,   y=turnoverDis_10A,     kernel = "normal",   bandwidth = 0.1)
NCV_middle_10_frame <-  ksmooth(x=Position_10E,   y=turnoverDis_10B*0.9,     kernel = "normal",   bandwidth = 0.1)
NCV_low_10_frame    <-  ksmooth(x=Position_10E,   y=turnoverDis_10C,     kernel = "normal",   bandwidth = 0.1)
NCV_high   <- NCV_high_10_frame$y
NCV_middle <- NCV_middle_10_frame$y
NCV_low    <- NCV_low_10_frame$y

x_Axis_10E   <- c( Position_10E,    Position_10E,  Position_10E)                       
y_Axis_10E   <- c( NCV_high, NCV_middle, NCV_low )  
sampleType_10E <- c( rep("High", binNum), rep("Middle", binNum),  rep("Low", binNum))                            
dataframe_10E  <- data.frame(xAxis = x_Axis_10E,  yAxis = y_Axis_10E,  sampleType = sampleType_10E) 
#####################################
CairoSVG(file = "Figures-noscale/10-E-turnover.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10E,  aes(x=xAxis, y=dataframe_10E$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("Nucleosome Turnover Rate") +  ggtitle("TSSs") + 
  scale_colour_manual( values=c("High" = "green4",  "Middle" = "green",   "Low"="yellowgreen") ,    breaks=c("High",  "Middle",  "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) + 
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################













Position_10F <- seq(from = -downStream/100,  by=0.01,  length.out=binNum)
NCV_high_10_frame   <-  ksmooth(x=Position_10F,   y=week1_10A,     kernel = "normal",   bandwidth = 0.1)
NCV_middle_10_frame <-  ksmooth(x=Position_10F,   y=week1_10B,     kernel = "normal",   bandwidth = 0.1)
NCV_low_10_frame    <-  ksmooth(x=Position_10F,   y=week1_10C,     kernel = "normal",   bandwidth = 0.1)
NCV_high   <- NCV_high_10_frame$y
NCV_middle <- NCV_middle_10_frame$y
NCV_low    <- NCV_low_10_frame$y

x_Axis_10F   <- c( Position_10F,    Position_10F,  Position_10F)                       
y_Axis_10F   <- c( NCV_high, NCV_middle, NCV_low )  
sampleType_10F <- c( rep("High", binNum), rep("Middle", binNum),  rep("Low", binNum))                            
dataframe_10F  <- data.frame(xAxis = x_Axis_10F,  yAxis = y_Axis_10F,  sampleType = sampleType_10F) 
#####################################
CairoSVG(file = "Figures-noscale/10-F-occupancy.svg",   width = 4.5,  height = 3, onefile = TRUE, bg = "white",  pointsize = 1 )
ggplot( data=dataframe_10F,  aes(x=xAxis, y=dataframe_10F$yAxis,  color=as.factor(sampleType)  )  ) +   
  xlab("Relative Distance (kb)") +  ylab("Nucleosome Occupancy Level") +  ggtitle("TSSs") + 
  scale_colour_manual( values=c("High" = "green4",  "Middle" = "green",   "Low"="yellowgreen") ,    breaks=c("High",  "Middle",  "Low") ) +  ## ditermined the order of legend   
  geom_line(size=0.5) + #ylim(0, 0.7) +
  geom_vline(xintercept=0, lty=2, col="gray", size=0.5) +  
  scale_x_continuous( breaks=c(-3, -2,  -1,  0, 1, 2, 3), labels=c("-3", "-2",  "-1",  "0",   "1",  "2", "3") ) + 
  pTheme +  guides( colour = guide_legend(override.aes = list(size=2.5)) ) 
dev.off() 
#######################################

####################################################################  End    ##########################################################################################################################################












