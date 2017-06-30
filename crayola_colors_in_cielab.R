library(rvest)
library(colorspace)
library(dplyr)
library(reshape2)
library(plotly)

crayonURL <- "https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors"

temp <- crayonURL %>% 
  read_html %>%
  html_nodes("table")

all_crayons <- html_table(temp[[1]]) %>% mutate(Color = tolower(gsub("[^a-zA-Z0-9]","",Color)), Hexadecimal = substr(Hexadecimal, 1,7)) ## Just the "legend" table

pack_64 <- read.csv("~/Desktop/crayola_colors.csv",header = F, col.names = "Color") %>% mutate(Color = tolower(gsub("[^a-zA-Z0-9]","",Color))) %>% left_join(all_crayons)

pack_64[pack_64$Color == "violet",2:ncol(pack_64)] <- all_crayons[all_crayons$Color=="violetii",2:ncol(pack_64)]

pack_64[pack_64$Color == "blue",2:ncol(pack_64)] <- all_crayons[all_crayons$Color=="blueiii",2:ncol(pack_64)]

pack_64[pack_64$Color == "chestnut",2:ncol(pack_64)] <- all_crayons[all_crayons$Color=="indianred",2:ncol(pack_64)]

pack_64[pack_64$Color == "gold",2:ncol(pack_64)] <- all_crayons[all_crayons$Color=="goldii",2:ncol(pack_64)]

pack_64[pack_64$Color == "lavender",2:ncol(pack_64)] <- all_crayons[all_crayons$Color=="lavenderii",2:ncol(pack_64)]


pack_64$num_range <- seq(1,nrow(pack_64))

# ggplot(pack_64, aes(xmin = 0, xmax = 1, ymin = num_range, ymax = num_range + 0.7, fill = factor(num_range))) + geom_rect() + scale_fill_manual(values = pack_64$Hexadecimal) + theme(legend.position = "none")

x <- hex2RGB(pack_64$Hexadecimal, gamma = FALSE)
storage.mode(x@coords) <- "numeric" # as(..., "LUV") doesn't like integers for some reason
y <- as(x, "LAB")
DF <- as.data.frame(y@coords)


p <- plot_ly(DF, x = ~B, y = ~A, z = ~L, 
             marker = list(color = ~col, colorscale = col)) %>%
  add_markers() %>%
  layout(scene = list(xaxis = list(title = 'b*'),
                      yaxis = list(title = 'a*'),
                      zaxis = list(title = 'L*')))

chart_link <- plotly_POST(p, filename="crayola_64_pack")
