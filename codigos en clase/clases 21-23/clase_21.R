# Cargar librerias
library(tidyverse)
options(scipen=999)
# Cargar datos 
pib_pais <- read_csv('https://raw.githubusercontent.com/argendatafundar/data/refs/heads/main/INDUST/pib_industrial_per_capita.csv')

# Filtrar datos 
pib_pais <- pib_pais %>% 
  filter(anio == 2023) %>% 
  filter(geonombreFundar %in% c('Alemania','Estados Unidos','Francia',
                                'España','Australia','China','México','Argentina',
                                'Tailandia','Chile','Brasil','Colombia'))

# Graficar 
plot2 <- ggplot(pib_pais, aes(x = reorder(geonombreFundar, gdp_indust_pc), 
                     y = gdp_indust_pc,
                     fill = geonombreFundar %in% c("Argentina")
                     )
       ) + 
  geom_col(colour='black') + 
  xlab('') + 
  ylab('PIB industrial per cápita') +
  theme_classic() + 
  scale_fill_manual(values = c("TRUE" = "#71b6c6", "FALSE" = "#dddddd"),
                    guide = "none") +  # guide="none" quita la leyenda
  labs(title = 'Valor Agregado Bruto industrial per cápita en países seleccionados',
       subtitle = 'VAB industrial per cápita, países seleccionados (en dólares corrientes), 2023',
       caption = 'Fuente de datos: National Accounts, Analysis of Main Aggregates, UNSTATS.') +
  theme(plot.title = element_text(face = 'bold', size = 14),
        plot.subtitle = element_text(size = 12),
        plot.caption = element_text(size = 8),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 11)) + 
  coord_flip()

# Grafico 2

comex <- read_csv('https://raw.githubusercontent.com/argendatafundar/data/refs/heads/main/INDUST/proporcion_importaciones_expo.csv')
comex <- comex %>% 
  filter(geonombreFundar %in% c('Alemania','Estados Unidos','Francia',
                                'España','Australia','China','México','Argentina',
                                'Tailandia','Chile','Brasil','Colombia')) %>% 
  filter(flujo == 'Exportaciones industriales')

# Graficar 
comex %>% 
  filter(anio == 2023) %>% 
  ggplot( aes(x = reorder(geonombreFundar, valores_constantes), 
                     y = valores_constantes,
                     fill = geonombreFundar %in% c("Argentina")
)
) + 
  geom_col(colour='black') + 
  xlab('') + 
  ylab('Exportaciones industriales') +
  theme_classic() + 
  scale_fill_manual(values = c("TRUE" = "#71b6c6", "FALSE" = "#dddddd"),
                    guide = "none") +  # guide="none" quita la leyenda
  labs(title = 'Exportaciones industriales en países seleccionados',
       subtitle = 'En dólares corrientes, 2023',
       caption = 'Fuente de datos: Argendata') +
  theme(plot.title = element_text(face = 'bold', size = 14),
        plot.subtitle = element_text(size = 12),
        plot.caption = element_text(size = 8),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 11)) + 
  coord_flip()

# Grafico 3: boxplot

comex %>% 
  filter(geonombreFundar != 'China') %>% 
  ggplot( aes(x = reorder(geonombreFundar, valores_constantes), 
              y = valores_constantes,
              fill = geonombreFundar %in% c("Argentina")
  )
  ) + 
  geom_boxplot(colour='black') + 
  geom_point(alpha=0.1) +
  xlab('') + 
  ylab('Exportaciones industriales') +
  theme_classic() + 
  scale_fill_manual(values = c("TRUE" = "#71b6c6", "FALSE" = "#dddddd"),
                    guide = "none") +  # guide="none" quita la leyenda
  labs(title = 'Exportaciones industriales en países seleccionados',
       subtitle = 'En dólares constantes, 1962-2023',
       caption = 'Fuente de datos: Argendata') +
  theme(plot.title = element_text(face = 'bold', size = 14),
        plot.subtitle = element_text(size = 12),
        plot.caption = element_text(size = 8),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 11)) + 
  coord_flip()

# Grafico 4: lineas

comex %>% 
  filter(geonombreFundar %in% c('Argentina','Chile','Colombia')) %>% 
  ggplot( aes(x = anio, 
              y = valores_constantes,
              fill = geonombreFundar,
              color = geonombreFundar,
              shape = geonombreFundar
  )) + 
  geom_point(alpha=0.7) +
  geom_smooth(method = 'lm') +
  xlab('') + 
  ylab('Exportaciones industriales') +
  theme_classic() + 
  labs(title = 'Exportaciones industriales en China',
       subtitle = 'En dólares constantes, 1962-2023',
       caption = 'Fuente de datos: Argendata') +
  theme(plot.title = element_text(face = 'bold', size = 14),
        plot.subtitle = element_text(size = 12),
        plot.caption = element_text(size = 8),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 11))
