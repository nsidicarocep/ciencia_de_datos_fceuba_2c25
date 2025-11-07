# ============================================================================
# TABLERO ESTADÍSTICO INTERACTIVO CON SHINY
# ============================================================================
# Este es un tablero interactivo que permite realizar diferentes análisis
# estadísticos de forma visual e interactiva
# 
# Análisis incluidos:
# - Exploración de datos
# - Regresión lineal
# - Análisis de Componentes Principales (PCA)
# - Análisis de Varianza (ANOVA)
# - Clustering (K-means)
# ============================================================================

# Cargar librerías necesarias
library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(DT)
library(factoextra)
library(cluster)
library(broom)

# ============================================================================
# INTERFAZ DE USUARIO (UI)
# ============================================================================

ui <- fluidPage(
  
  # Título principal
  titlePanel("Tablero Interactivo de Análisis Estadístico"),
  
  # CSS personalizado
  tags$head(
    tags$style(HTML("
      .main-header {
        background-color: #4CAF50;
        color: white;
        padding: 10px;
        margin-bottom: 20px;
      }
      .info-box {
        background-color: #f0f0f0;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 15px;
      }
    "))
  ),
  
  # Layout con sidebar
  sidebarLayout(
    
    # Panel lateral con controles
    sidebarPanel(
      width = 3,
      
      h4("⚙️ Configuración del Análisis"),
      
      # Selección de dataset
      div(class = "info-box",
        selectInput("dataset", "📊 Dataset:",
                    choices = c("mtcars - Automóviles" = "mtcars", 
                               "iris - Flores" = "iris", 
                               "diamonds - Diamantes (muestra)" = "diamonds"))
      ),
      
      hr(),
      
      # Tabs para diferentes análisis
      tabsetPanel(id = "analisis_tipo",
        
        # Tab 1: Exploración
        tabPanel("🔍 Exploración",
                 value = "exploracion",
                 br(),
                 uiOutput("var_x_ui"),
                 uiOutput("var_y_ui"),
                 uiOutput("var_color_ui"),
                 checkboxInput("add_smooth", "Añadir línea de tendencia", FALSE)
        ),
        
        # Tab 2: Regresión
        tabPanel("📈 Regresión",
                 value = "regresion",
                 br(),
                 uiOutput("var_y_reg_ui"),
                 uiOutput("var_x_reg_ui"),
                 checkboxInput("mostrar_ic", "Mostrar intervalo de confianza", TRUE),
                 checkboxInput("mostrar_ecuacion", "Mostrar ecuación", TRUE),
                 checkboxInput("mostrar_residuos", "Mostrar diagnósticos", FALSE)
        ),
        
        # Tab 3: PCA
        tabPanel("🎯 PCA",
                 value = "pca",
                 br(),
                 p("El PCA se calcula con todas las variables numéricas"),
                 sliderInput("n_pcs", "Componentes a visualizar:",
                            min = 2, max = 4, value = 2, step = 1),
                 uiOutput("var_color_pca_ui"),
                 checkboxInput("mostrar_biplot", "Mostrar biplot", FALSE)
        ),
        
        # Tab 4: ANOVA
        tabPanel("📊 ANOVA",
                 value = "anova",
                 br(),
                 uiOutput("var_y_anova_ui"),
                 uiOutput("var_grupo_anova_ui"),
                 checkboxInput("post_hoc", "Comparaciones post-hoc (Tukey)", FALSE),
                 checkboxInput("mostrar_medias", "Mostrar medias por grupo", TRUE)
        ),
        
        # Tab 5: Clusters
        tabPanel("🎲 Clusters",
                 value = "clusters",
                 br(),
                 sliderInput("n_clusters", "Número de clusters (k):",
                            min = 2, max = 8, value = 3, step = 1),
                 uiOutput("var_x_cluster_ui"),
                 uiOutput("var_y_cluster_ui"),
                 checkboxInput("mostrar_elbow", "Mostrar método del codo", FALSE)
        )
      ),
      
      hr(),
      
      # Información adicional
      div(class = "info-box",
          p(strong("💡 Tip:"), "Explora diferentes combinaciones de variables y parámetros.", 
            style = "font-size: 0.9em;")
      )
    ),
    
    # Panel principal con resultados
    mainPanel(
      width = 9,
      
      # Tabs para diferentes vistas
      tabsetPanel(
        
        # Vista de visualización
        tabPanel("📊 Visualización",
                 br(),
                 plotlyOutput("main_plot", height = "550px")
        ),
        
        # Vista de resultados estadísticos
        tabPanel("📋 Resultados Estadísticos",
                 br(),
                 verbatimTextOutput("stats_output")
        ),
        
        # Vista de datos
        tabPanel("📑 Datos",
                 br(),
                 DTOutput("data_table")
        ),
        
        # Vista de resumen
        tabPanel("📈 Resumen",
                 br(),
                 verbatimTextOutput("summary_output"),
                 hr(),
                 h4("Estructura del dataset:"),
                 verbatimTextOutput("str_output")
        ),
        
        # Ayuda
        tabPanel("❓ Ayuda",
                 br(),
                 h3("Guía de Uso"),
                 
                 h4("🔍 Exploración"),
                 p("Permite crear scatter plots interactivos seleccionando diferentes variables."),
                 
                 h4("📈 Regresión Lineal"),
                 p("Ajusta un modelo de regresión lineal simple (Y ~ X) y muestra la ecuación, 
                   R² e intervalos de confianza."),
                 
                 h4("🎯 PCA"),
                 p("Análisis de Componentes Principales. Reduce la dimensionalidad de los datos 
                   y muestra las dos primeras componentes principales."),
                 
                 h4("📊 ANOVA"),
                 p("Compara las medias de una variable numérica entre diferentes grupos. 
                   Incluye pruebas post-hoc para comparaciones múltiples."),
                 
                 h4("🎲 Clustering"),
                 p("Agrupa observaciones similares usando el algoritmo K-means. 
                   Puedes ajustar el número de clusters (k)."),
                 
                 hr(),
                 
                 h4("Datasets disponibles:"),
                 tags$ul(
                   tags$li(strong("mtcars:"), "32 automóviles con 11 variables (mpg, cilindros, potencia, etc.)"),
                   tags$li(strong("iris:"), "150 flores con 5 variables (medidas de pétalos y sépalos)"),
                   tags$li(strong("diamonds:"), "Muestra de 1000 diamantes con 10 variables (precio, quilates, etc.)")
                 )
        )
      )
    )
  ),
  
  # Footer
  hr(),
  div(style = "text-align: center; color: #666;",
      p("Tablero desarrollado con Shiny | R | ",
        a("Documentación", href = "https://shiny.posit.co", target = "_blank"))
  )
)

# ============================================================================
# SERVIDOR (LÓGICA)
# ============================================================================

server <- function(input, output, session) {
  
  # -------------------------------------------------------------------------
  # DATOS REACTIVOS
  # -------------------------------------------------------------------------
  
  datos <- reactive({
    switch(input$dataset,
           "mtcars" = mtcars,
           "iris" = iris,
           "diamonds" = {
             if (requireNamespace("ggplot2", quietly = TRUE)) {
               ggplot2::diamonds %>% sample_n(1000)
             } else {
               mtcars
             }
           })
  })
  
  # Variables numéricas
  vars_numericas <- reactive({
    datos() %>% select(where(is.numeric)) %>% names()
  })
  
  # Variables categóricas
  vars_categoricas <- reactive({
    datos() %>% select(where(~ is.factor(.) | is.character(.))) %>% names()
  })
  
  # Todas las variables
  todas_vars <- reactive({
    names(datos())
  })
  
  # -------------------------------------------------------------------------
  # UI DINÁMICA PARA INPUTS
  # -------------------------------------------------------------------------
  
  # Exploración
  output$var_x_ui <- renderUI({
    selectInput("var_x", "Variable X:", 
                choices = vars_numericas(),
                selected = vars_numericas()[1])
  })
  
  output$var_y_ui <- renderUI({
    req(length(vars_numericas()) >= 2)
    selectInput("var_y", "Variable Y:", 
                choices = vars_numericas(),
                selected = vars_numericas()[2])
  })
  
  output$var_color_ui <- renderUI({
    choices <- c("Ninguna", todas_vars())
    selectInput("var_color", "Color por:", choices = choices)
  })
  
  # Regresión
  output$var_y_reg_ui <- renderUI({
    selectInput("var_y_reg", "Variable dependiente (Y):", 
                choices = vars_numericas(),
                selected = vars_numericas()[1])
  })
  
  output$var_x_reg_ui <- renderUI({
    req(length(vars_numericas()) >= 2)
    selectInput("var_x_reg", "Variable independiente (X):", 
                choices = vars_numericas(),
                selected = vars_numericas()[2])
  })
  
  # PCA
  output$var_color_pca_ui <- renderUI({
    choices <- c("Ninguna", todas_vars())
    selectInput("var_color_pca", "Color por:", choices = choices)
  })
  
  # ANOVA
  output$var_y_anova_ui <- renderUI({
    selectInput("var_y_anova", "Variable numérica:", 
                choices = vars_numericas(),
                selected = vars_numericas()[1])
  })
  
  output$var_grupo_anova_ui <- renderUI({
    vars_grupo <- vars_categoricas()
    if (length(vars_grupo) == 0) {
      vars_grupo <- "No hay variables categóricas"
    }
    selectInput("var_grupo_anova", "Variable de agrupación:", 
                choices = vars_grupo,
                selected = vars_grupo[1])
  })
  
  # Clusters
  output$var_x_cluster_ui <- renderUI({
    selectInput("var_x_cluster", "Variable X:", 
                choices = vars_numericas(),
                selected = vars_numericas()[1])
  })
  
  output$var_y_cluster_ui <- renderUI({
    req(length(vars_numericas()) >= 2)
    selectInput("var_y_cluster", "Variable Y:", 
                choices = vars_numericas(),
                selected = vars_numericas()[2])
  })
  
  # -------------------------------------------------------------------------
  # GRÁFICO PRINCIPAL
  # -------------------------------------------------------------------------
  
  output$main_plot <- renderPlotly({
    req(input$analisis_tipo)
    
    tipo <- input$analisis_tipo
    
    # EXPLORACIÓN
    if (tipo == "exploracion") {
      req(input$var_x, input$var_y)
      
      p <- ggplot(datos(), aes_string(x = input$var_x, y = input$var_y))
      
      if (input$var_color != "Ninguna") {
        p <- p + aes_string(color = input$var_color)
      }
      
      p <- p + 
        geom_point(alpha = 0.6, size = 3) +
        theme_minimal() +
        labs(title = paste("Exploración:", input$var_y, "vs", input$var_x),
             subtitle = paste("Dataset:", input$dataset))
      
      if (input$add_smooth) {
        p <- p + geom_smooth(method = "loess", se = TRUE, alpha = 0.2)
      }
      
      ggplotly(p)
      
    # REGRESIÓN
    } else if (tipo == "regresion") {
      req(input$var_x_reg, input$var_y_reg)
      
      formula_reg <- as.formula(paste(input$var_y_reg, "~", input$var_x_reg))
      modelo <- lm(formula_reg, data = datos())
      
      datos_pred <- datos()
      datos_pred$pred <- predict(modelo)
      datos_pred$residuals <- residuals(modelo)
      
      p <- ggplot(datos_pred, aes_string(x = input$var_x_reg, y = input$var_y_reg)) +
        geom_point(alpha = 0.6, size = 3, color = "steelblue") +
        geom_line(aes(y = pred), color = "red", size = 1.2) +
        theme_minimal() +
        labs(title = "Regresión Lineal Simple",
             subtitle = if(input$mostrar_ecuacion) {
               paste0("y = ", round(coef(modelo)[1], 3), " + ", 
                     round(coef(modelo)[2], 3), "x  |  R² = ", 
                     round(summary(modelo)$r.squared, 3))
             } else "")
      
      if (input$mostrar_ic) {
        p <- p + geom_smooth(method = "lm", se = TRUE, alpha = 0.15, color = "red")
      }
      
      ggplotly(p)
      
    # PCA
    } else if (tipo == "pca") {
      req(input$n_pcs)
      
      datos_num <- datos() %>% select(where(is.numeric))
      
      if (ncol(datos_num) < 2) {
        plot_ly() %>% 
          add_annotations(text = "Se necesitan al menos 2 variables numéricas para PCA",
                         x = 0.5, y = 0.5,
                         showarrow = FALSE, font = list(size = 16))
      } else {
        pca_result <- prcomp(datos_num, scale. = TRUE, center = TRUE)
        
        pca_df <- as.data.frame(pca_result$x[, 1:min(input$n_pcs, ncol(pca_result$x))])
        pca_df <- cbind(pca_df, datos() %>% select(!where(is.numeric)))
        
        var_exp <- summary(pca_result)$importance[2, 1:2] * 100
        
        p <- ggplot(pca_df, aes(x = PC1, y = PC2))
        
        if (input$var_color_pca != "Ninguna" && input$var_color_pca %in% names(pca_df)) {
          p <- p + aes_string(color = input$var_color_pca)
        }
        
        p <- p +
          geom_point(size = 3, alpha = 0.7) +
          theme_minimal() +
          labs(title = "Análisis de Componentes Principales (PCA)",
               x = paste0("PC1 (", round(var_exp[1], 1), "% de varianza explicada)"),
               y = paste0("PC2 (", round(var_exp[2], 1), "% de varianza explicada)"))
        
        ggplotly(p)
      }
      
    # ANOVA
    } else if (tipo == "anova") {
      req(input$var_y_anova, input$var_grupo_anova)
      
      if (input$var_grupo_anova == "No hay variables categóricas") {
        plot_ly() %>% 
          add_annotations(text = "No hay variables categóricas en este dataset",
                         x = 0.5, y = 0.5,
                         showarrow = FALSE, font = list(size = 16))
      } else {
        p <- ggplot(datos(), aes_string(x = input$var_grupo_anova, 
                                        y = input$var_y_anova,
                                        fill = input$var_grupo_anova)) +
          geom_boxplot(alpha = 0.7, outlier.shape = NA) +
          geom_jitter(width = 0.2, alpha = 0.4, size = 2) +
          theme_minimal() +
          labs(title = "Análisis de Varianza (ANOVA)",
               subtitle = paste(input$var_y_anova, "por", input$var_grupo_anova),
               x = input$var_grupo_anova,
               y = input$var_y_anova) +
          theme(legend.position = "none")
        
        if (input$mostrar_medias) {
          p <- p + stat_summary(fun = mean, geom = "point", 
                               shape = 23, size = 4, fill = "red")
        }
        
        ggplotly(p)
      }
      
    # CLUSTERING
    } else if (tipo == "clusters") {
      req(input$var_x_cluster, input$var_y_cluster, input$n_clusters)
      
      datos_cluster <- datos() %>% 
        select(all_of(c(input$var_x_cluster, input$var_y_cluster))) %>%
        na.omit()
      
      set.seed(123)
      kmeans_result <- kmeans(scale(datos_cluster), centers = input$n_clusters, nstart = 25)
      
      datos_cluster$cluster <- as.factor(kmeans_result$cluster)
      
      # Centros de clusters (desescalar)
      centros <- as.data.frame(kmeans_result$centers)
      centros_orig <- centros * 
        sapply(datos_cluster[, 1:2], sd) + 
        sapply(datos_cluster[, 1:2], mean)
      centros_orig$cluster <- factor(1:input$n_clusters)
      
      p <- ggplot(datos_cluster, aes_string(x = input$var_x_cluster, 
                                            y = input$var_y_cluster,
                                            color = "cluster")) +
        geom_point(size = 3, alpha = 0.7) +
        geom_point(data = centros_orig, 
                  aes_string(x = input$var_x_cluster,
                            y = input$var_y_cluster,
                            color = "cluster"),
                  size = 12, shape = 4, stroke = 2.5) +
        theme_minimal() +
        labs(title = "Análisis de Clusters (K-means)",
             subtitle = paste("k =", input$n_clusters, "clusters"),
             color = "Cluster") +
        scale_color_brewer(palette = "Set1")
      
      ggplotly(p)
    }
  })
  
  # -------------------------------------------------------------------------
  # RESULTADOS ESTADÍSTICOS
  # -------------------------------------------------------------------------
  
  output$stats_output <- renderPrint({
    req(input$analisis_tipo)
    
    tipo <- input$analisis_tipo
    
    if (tipo == "regresion") {
      req(input$var_x_reg, input$var_y_reg)
      
      formula_reg <- as.formula(paste(input$var_y_reg, "~", input$var_x_reg))
      modelo <- lm(formula_reg, data = datos())
      
      cat("═══════════════════════════════════════════════════════\n")
      cat("     RESULTADOS DE REGRESIÓN LINEAL SIMPLE\n")
      cat("═══════════════════════════════════════════════════════\n\n")
      
      cat("Modelo:", input$var_y_reg, "~", input$var_x_reg, "\n\n")
      
      print(summary(modelo))
      
      if (input$mostrar_residuos) {
        cat("\n\n═══════════════════════════════════════════════════════\n")
        cat("     DIAGNÓSTICOS DEL MODELO\n")
        cat("═══════════════════════════════════════════════════════\n\n")
        
        cat("Test de Normalidad de Residuos (Shapiro-Wilk):\n")
        print(shapiro.test(residuals(modelo)))
      }
      
    } else if (tipo == "pca") {
      datos_num <- datos() %>% select(where(is.numeric))
      
      if (ncol(datos_num) >= 2) {
        pca_result <- prcomp(datos_num, scale. = TRUE, center = TRUE)
        
        cat("═══════════════════════════════════════════════════════\n")
        cat("     RESULTADOS DE ANÁLISIS DE COMPONENTES PRINCIPALES\n")
        cat("═══════════════════════════════════════════════════════\n\n")
        
        cat("Varianza explicada por componente:\n\n")
        print(summary(pca_result))
        
        cat("\n\nLoadings (pesos) de las variables en las primeras", input$n_pcs, "componentes:\n\n")
        print(round(pca_result$rotation[, 1:min(input$n_pcs, ncol(pca_result$rotation))], 3))
        
        cat("\n\nInterpretación: Los loadings muestran la contribución de cada variable\n")
        cat("original a cada componente principal.\n")
      } else {
        cat("Se necesitan al menos 2 variables numéricas para realizar PCA.\n")
      }
      
    } else if (tipo == "anova") {
      req(input$var_y_anova, input$var_grupo_anova)
      
      if (input$var_grupo_anova != "No hay variables categóricas") {
        formula_anova <- as.formula(paste(input$var_y_anova, "~", input$var_grupo_anova))
        modelo_anova <- aov(formula_anova, data = datos())
        
        cat("═══════════════════════════════════════════════════════\n")
        cat("     RESULTADOS DE ANÁLISIS DE VARIANZA (ANOVA)\n")
        cat("═══════════════════════════════════════════════════════\n\n")
        
        cat("Modelo:", input$var_y_anova, "~", input$var_grupo_anova, "\n\n")
        
        print(summary(modelo_anova))
        
        if (input$post_hoc) {
          cat("\n\n═══════════════════════════════════════════════════════\n")
          cat("     COMPARACIONES POST-HOC (Tukey HSD)\n")
          cat("═══════════════════════════════════════════════════════\n\n")
          print(TukeyHSD(modelo_anova))
        }
        
        if (input$mostrar_medias) {
          cat("\n\n═══════════════════════════════════════════════════════\n")
          cat("     MEDIAS POR GRUPO\n")
          cat("═══════════════════════════════════════════════════════\n\n")
          medias <- datos() %>%
            group_by(!!sym(input$var_grupo_anova)) %>%
            summarise(
              Media = mean(!!sym(input$var_y_anova), na.rm = TRUE),
              SD = sd(!!sym(input$var_y_anova), na.rm = TRUE),
              N = n()
            )
          print(medias)
        }
      } else {
        cat("No hay variables categóricas disponibles en este dataset.\n")
      }
      
    } else if (tipo == "clusters") {
      req(input$var_x_cluster, input$var_y_cluster, input$n_clusters)
      
      datos_cluster <- datos() %>% 
        select(all_of(c(input$var_x_cluster, input$var_y_cluster))) %>%
        na.omit()
      
      set.seed(123)
      kmeans_result <- kmeans(scale(datos_cluster), centers = input$n_clusters, nstart = 25)
      
      cat("═══════════════════════════════════════════════════════\n")
      cat("     RESULTADOS DE K-MEANS CLUSTERING\n")
      cat("═══════════════════════════════════════════════════════\n\n")
      
      cat("Número de clusters (k):", input$n_clusters, "\n\n")
      
      cat("Tamaño de cada cluster:\n")
      print(table(kmeans_result$cluster))
      cat("\n")
      
      cat("Within-cluster sum of squares (WCSS):", round(kmeans_result$tot.withinss, 2), "\n")
      cat("Between-cluster sum of squares (BCSS):", round(kmeans_result$betweenss, 2), "\n")
      cat("Total sum of squares (TSS):", round(kmeans_result$totss, 2), "\n")
      cat("Ratio BCSS/TSS:", round(kmeans_result$betweenss / kmeans_result$totss * 100, 2), "%\n")
      cat("\n(Mayor ratio BCSS/TSS = Mejor separación entre clusters)\n")
      
      cat("\n\nCentros de los clusters (valores escalados):\n")
      print(round(kmeans_result$centers, 3))
      
    } else {
      cat("═══════════════════════════════════════════════════════\n")
      cat("     INFORMACIÓN\n")
      cat("═══════════════════════════════════════════════════════\n\n")
      cat("Selecciona un tipo de análisis en el panel lateral\n")
      cat("para ver los resultados estadísticos correspondientes.\n")
    }
  })
  
  # -------------------------------------------------------------------------
  # TABLA DE DATOS
  # -------------------------------------------------------------------------
  
  output$data_table <- renderDT({
    datatable(datos(), 
              options = list(
                pageLength = 15, 
                scrollX = TRUE,
                dom = 'Bfrtip'
              ),
              class = 'cell-border stripe hover',
              filter = 'top')
  })
  
  # -------------------------------------------------------------------------
  # RESUMEN DEL DATASET
  # -------------------------------------------------------------------------
  
  output$summary_output <- renderPrint({
    cat("═══════════════════════════════════════════════════════\n")
    cat("     RESUMEN ESTADÍSTICO DEL DATASET\n")
    cat("═══════════════════════════════════════════════════════\n\n")
    
    cat("Dataset seleccionado:", input$dataset, "\n")
    cat("Dimensiones:", nrow(datos()), "observaciones ×", ncol(datos()), "variables\n")
    cat("Variables numéricas:", length(vars_numericas()), "\n")
    cat("Variables categóricas:", length(vars_categoricas()), "\n\n")
    
    print(summary(datos()))
  })
  
  output$str_output <- renderPrint({
    str(datos())
  })
}

# ============================================================================
# EJECUTAR LA APLICACIÓN
# ============================================================================

shinyApp(ui = ui, server = server)
