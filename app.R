# Load packages used by the app. Install missing packages, if needed.
library(shiny)
library(devtools)
library(readxl)
library(shinyjs)
library(SMRD)
library(DT)
library(gt)
library(gtExtras)
library(tidyverse)
library(scales)
library(glue)
library(dplyr)
library(plyr)
library(magrittr)
library(rintrojs)

# Define the Shiny UI layout
ui <- fixedPage(
  introjsUI(),
  
  tags$style("body {
              -moz-transform: scale(0.9, 0.9); /* Moz-browsers */
              zoom: 1; /* Other non-webkit browsers */
              zoom: 100%; /* Webkit browsers */
              }
              .tabset-panel-container::before {
                content: '';
                position: absolute;
                top: 40px; /* Ajusta esta propiedad para alinear con las pestañas */
                left: 0;
                right: 0;
                height: 2px;
                background-color: black;
                z-index: 1;
                margin-right: 0; /* Ajustar el margen derecho según sea necesario */
              }"),
  
  fluidRow(
    tags$head(
      tags$style(HTML("
      body {
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed; /* Fija el fondo para que no se desplace */
      }
      .fixed-container {
        width: 100%; /* Ajusta al ancho completo */
        height: 100vh; /* Ajusta al alto completo de la ventana del navegador */
        overflow-x: hidden; /* Oculta el desplazamiento horizontal si es necesario */
      }
      .title-logo-container {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 20px; /* Ajusta esta propiedad para mover el logo más abajo */
      }
      .title-logo-container img {
        margin-right: 20px; /* Espacio entre el logo y el título */
      }
      .tabset-panel-container {
        border: 2px solid black;
        padding: 10px;
        position: relative;
      }
      .tabset-panel-container .nav-tabs {
        border-bottom: none; /* Elimina la segunda línea horizontal */
        position: relative;
        height: 60px;
        margin-bottom: 0;
      }
      .tabset-panel-container .nav-tabs > li {
        border-right: 2px solid black;
        margin-right: -3px; /* Para eliminar el espacio entre los bordes */
        position: relative;
        top: -10px;
        bottom: 15px;
      }
      .vertical-divider {
        border-left: 2px solid black;
        position: absolute;
        top: 0; /* Ajuste para hacer la línea más larga */
        bottom: 0;
        left: 0;
        margin-right: 20px;
        
      }
      .tabset-panel-container .nav-tabs > li:last-child {
        border-right: none;
      }
      .tabset-panel-container::before {
        content: '';
        position: absolute;
        top: 40px; /* Ajusta esta propiedad para alinear con las pestañas */
        left: 0;
        right: 0;
        height: 2px;
        background-color: black;
        z-index: 1;
        margin-right: 20px;
      }
      .center-text {
        text-align: center;
      }
      .watermark-container {
        text-align: center;
        margin-top: 20px;
      }
      .nav-tabs > li > a {
        color: black !important; /* Cambiar el color del texto */
      }
      .flex-container {
        display: flex;
        align-items: stretch;
      }
      .flex-item {
        flex: 1;
      }
    "))
    ),
    
    # Contenedor para el título y el logo
    div(class = "title-logo-container",
        img(src = "logo3.png", height = "100px"),  # Ajusta el tamaño según sea necesario
        h1("Gráfico de Eventos", align = "center",
           style = "Andale Mono;
                color: #800020;
                ")
    ), 
    
    # Menú ----     
    column(12,
           div(class = "tabset-panel-container",
               tabsetPanel(
                 type = "tabs",
                 tabPanel(
                   title = "Guía", 
                   icon = icon("home", lib = "font-awesome"),
                   div(
                     p("Bienvenido al tutorial interactivo de la aplicación Gráfico de Eventos. A continuación, se te guiará a través de las funcionalidades principales."),
                     actionButton("start_tour", "Iniciar Tutorial", class = "btn btn-primary")
                   )
                 ),
                 
                 tabPanel(
                   title = "Cargar datos", 
                   icon = icon("arrow-up-from-bracket", lib = "font-awesome"),
                   id = "cargar_datos_tab",  # Añade este ID
                   sidebarLayout(
                     sidebarPanel(
                       width = 3,
                       radioButtons("data_input", "Fuente de los datos:",
                                    choices = list(
                                      "Utilizar una base de datos de R" = "predefined",
                                      "Cargar tu propia base de datos" = "upload"
                                    )),
                       uiOutput("data_selection_ui"),
                       uiOutput("col_response_ui"),
                       style = "margin-top: 20px;"
                     ),
                     mainPanel(
                       width = 9,
                       div(class = "flex-container",
                           div(class = "flex-item",
                               textInput("search_input", "Búsqueda:", placeholder = "Ingresa el valor que deseas encontrar..."),
                               gt_output("table_output"),
                               div(class = "center-text", textOutput("num_observaciones")), # Centrar salida para el número de observaciones
                               div(
                                 numericInput("page_number", "Página:", min = 1, max = 1, value = 1, width = 70),
                                 class = "pagination-controls center-text"
                               ),
                               div(class = "pagination-buttons center-text", uiOutput("pagination_ui")) # Centrar los botones
                           ),
                           div(class = "vertical-divider")
                       )
                     )
                   )
                 ),
                 
                 tabPanel(
                   title = "Resumen",
                   icon = icon("chart-bar", lib = "font-awesome"),
                   
                   fluidPage(
                     # Añadir un contenedor con margen para el contenido
                     fluidRow(
                       column(
                         width = 12,
                         uiOutput("summary_output")  # Muestra el resumen organizado
                       )
                     )
                   )
                 ),
                 
                 
                 tabPanel(
                   title = "Gráfico de Eventos", 
                   icon = icon("chart-line", lib = "font-awesome"), 
                   sidebarLayout(
                     sidebarPanel(
                       width = 3,
                       uiOutput("col_respuesta_ui"),
                       uiOutput("col_censura_ui"),
                       uiOutput("col_cantidad_ui"),
                       uiOutput("col_falla_ui"),
                       style = "margin-top: 20px;"
                     ),
                     mainPanel(
                       width = 9,
                       plotOutput("event_plot"),
                       div(class = "vertical-divider")
                     )
                   )
                 )
               )
           )
    )
  ),
  
  # Marca de agua
  div(class = "watermark-container",
      div(class = "watermark",
          "Creado por Grupo de investigación en Estadística, Universidad Nacional de Colombia - Sede Medellín")
  )
)

# Define the Shiny server function
server <- function(input, output, session) {
  
  ensure_data_frame <- function(data) {
    if (is.list(data) && !is.data.frame(data)) {
      data <- as.data.frame(data)
    }
    return(data)
  }
  
  asignar_tipo <- function(valor_evento) {
    tipos <- list(
      Falla = c("exact", "d", "dead", "died", "f", "fail", "failed", "failure", "report", "repair", "repaired", "replaced", "replacement", "1"),
      Censura_a_Izquierda = c("l", "l-censored", "left-censored", "left", "leftcensored", "start", "mstart", "3"),
      Censura_a_Derecha = c("a", "alive", "c", "censor", "censored", "end", "mend", "noreport", "r", "r-censored", "right-censored", "removed", "right", "rightcensored", "s", "survived", "survive", "suspend", "suspended", "2"),
      Censura_Por_Intervalo = c("b", "bin", "i", "interval", "i-censored", "intervalcensored", "interval-censored", "4")
    )
    
    valor_evento <- tolower(trimws(valor_evento))
    
    for (tipo in names(tipos)) {
      if (valor_evento %in% tipos[[tipo]]) {
        tipo <- gsub("_", " ", tipo)
        return(tipo)
      }
    }
    
    return("No Especificado")
  }
  
  bases_de_datos <- sort(c(
    "at7987", "bearinga", "bearingcage", "componentd", "deviceh", "devicen", "fan", "lfp1370", 
    "turbine","locomotivecontrol", "rocketmotor", "titanium2", "vehiclemotor", "heatexchanger", 
    "bulb", "appliancea","atrazinejune","customerlife","bkfatigue10","chemicalprocess",
    "engineemissions","lzbearing","pipelinethickness","repairtimes","tractorbreaks","tree25years",
    "shockabsorber","v7tube"
  ))
  
  datos <- reactive({
    if (input$data_input == "predefined") {
      req(input$base_datos)
      tryCatch({
        data <- get(input$base_datos)
        if(input$base_datos == "vehiclemotor"){
          data$event <- ifelse(data$event == 2, 3, 2)
        }
        data <- ensure_data_frame(data)
        return(data)
      }, error = function(e) {
        return(NULL)
      })
    } else if (input$data_input == "upload") {
      req(input$file1)
      tryCatch({
        if (endsWith(input$file1$name, ".xlsx")) {
          data <- read_excel(input$file1$datapath)
        } else {
          delimiter <- switch(input$delimiter,
                              "," = ",",
                              "\t" = "\t",
                              ";" = ";",
                              " " = " ")
          data <- read.table(input$file1$datapath, header = TRUE, sep = delimiter)
        }
        data <- ensure_data_frame(data)
        return(data)
      }, error = function(e) {
        return(NULL)
      })
    }
  })
  
  datos_filtrados <- reactive({
    req(datos())
    data <- datos()
    data <- ensure_data_frame(data)
    if (input$search_input != "") {
      search_term <- tolower(input$search_input)
      data <- data[apply(data, 1, function(row) any(grepl(search_term, row, ignore.case = TRUE))), , drop = FALSE]
    }
    return(data)
  })
  
  paginated_data <- reactive({
    req(datos_filtrados())
    data <- datos_filtrados()
    data <- ensure_data_frame(data)
    items_per_page <- 10
    page_number <- input$page_number
    start_index <- (page_number - 1) * items_per_page + 1
    end_index <- min(page_number * items_per_page, nrow(data))
    data[start_index:end_index, , drop = FALSE]
  })
  
  total_pages <- reactive({
    req(datos_filtrados())
    data <- datos_filtrados()
    data <- ensure_data_frame(data)
    items_per_page <- 10
    ceiling(nrow(data) / items_per_page)
  })
  
  output$table_output <- render_gt({
    req(paginated_data())
    datos_mostrar <- paginated_data()
    datos_mostrar <- ensure_data_frame(datos_mostrar)
    
    gt(datos_mostrar) %>%
      tab_header(
        title = md(glue("Conjunto de datos: {input$base_datos %||% input$file1$name}")),
        subtitle = ""
      ) %>%
      gt_theme_pff()
  })
  
  output$pagination_ui <- renderUI({
    req(total_pages())
    div(
      actionButton("prev_button", "Anterior"),
      actionButton("next_button", "Siguiente"),
      class = "pagination-buttons center-text" # Asegurar que los botones estén centrados
    )
  })
  
  observeEvent(input$prev_button, {
    new_page <- input$page_number - 1
    if (new_page < 1) {
      new_page <- 1
    }
    updateNumericInput(session, "page_number", value = new_page)
  })
  
  observeEvent(input$next_button, {
    new_page <- input$page_number + 1
    if (new_page > total_pages()) {
      new_page <- total_pages()
    }
    updateNumericInput(session, "page_number", value = new_page)
  })
  
  observe({
    if (input$page_number > total_pages()) {
      updateNumericInput(session, "page_number", value = total_pages())
    }
  })
  
  observeEvent(input$page_number, {
    if (input$page_number > total_pages()) {
      updateNumericInput(session, "page_number", value = total_pages())
    } else if (input$page_number < 1) {
      updateNumericInput(session, "page_number", value = 1)
    }
  })
  
  output$num_observaciones <- renderText({
    req(datos_filtrados())
    n_obs <- nrow(datos_filtrados())
    paste("Número de observaciones:", n_obs)
  })
  
  output$data_selection_ui <- renderUI({
    if (input$data_input == "predefined") {
      fluidRow(
        column(
          width = 12,
          selectInput("base_datos", "Selecciona un conjunto de datos:", choices = bases_de_datos)
        ) 
      )
    } else if (input$data_input == "upload") {
      fluidRow(
        column(
          width = 12,
          fileInput("file1", "Selecciona un archivo"),
          selectInput("delimiter", "Delimitador:",
                      choices = list("Coma" = ",",
                                     "Tabulación" = "\t",
                                     "Punto y Coma" = ";",
                                     "Espacio" = " "))
        )
      )
    }
  })
  
  # output$col_response_ui <- renderUI({
  #   req(datos())
  #   choices <- colnames(datos())
  #   choices <- c("No aplica", choices)
  #   
  #   fluidRow(
  #     column(
  #       width = 12,
  #       selectInput("col_response", "Selecciona la columna que contiene la variable asociada al evento:",
  #                   choices = choices, selected = choices[3])
  #     )
  #   )
  # })
  
  
  output$summary_output <- renderUI({
    req(datos_filtrados())
    df <- datos_filtrados()
    
    # Crea una lista de elementos HTML para cada variable
    summary_list <- lapply(names(df), function(var_name) {
      var_summary <- summary(df[[var_name]])
      html_output <- paste(
        "<div class='summary-container'>",
        "<h4>", var_name, "</h4>",
        "<pre>", paste(capture.output(var_summary), collapse = "\n"), "</pre>",
        "</div>"
      )
      return(html_output)
    })
    
    # Combina todos los elementos HTML en un solo objeto HTML
    HTML(paste(summary_list, collapse = "<br>"))
  })
  
  
  output$col_respuesta_ui <- renderUI({
    req(datos())
    choices <- colnames(datos())
    choices <- c("No aplica", choices)
    
    fluidRow(
      column(
        width = 12,
        selectInput("col_respuesta", "Selecciona la(s) columna(s) de la respuesta:",
                    choices = choices, multiple = T, selected = choices[2])
      )
    )
  })
  
  output$col_censura_ui <- renderUI({
    req(datos())
    choices <- colnames(datos())
    choices <- c("No aplica", choices)
    
    fluidRow(
      column(
        width = 12,
        selectInput("col_censura", "Selecciona la columna de la censura:",
                    choices = choices)
      )
    )
  })
  
  output$col_cantidad_ui <- renderUI({
    req(datos())
    choices <- colnames(datos())
    choices <- c("No aplica", choices)
    
    fluidRow(
      column(
        width = 12,
        selectInput("col_cantidad", "Selecciona la columna de la cantidad:",
                    choices = choices)
      )
    )
  })
  
  output$col_falla_ui <- renderUI({
    req(datos())
    choices <- colnames(datos())
    choices <- c("No aplica", choices)
    
    fluidRow(
      column(
        width = 12,
        selectInput("col_falla", "Selecciona la columna del modo de falla:",
                    choices = choices)
      )
    )
  })
  
  output$event_plot <- renderPlot({
    if (!is.null(datos())) {
      datos.ld <- SMRD::frame.to.ld(
        datos(),
        response.column = if(!("No aplica" %in% input$col_respuesta)) input$col_respuesta else NULL,
        censor.column = if (input$col_censura != "No aplica") input$col_censura else NULL,
        case.weight.column = if (input$col_cantidad != "No aplica") input$col_cantidad else NULL,
        failure.mode.column = if (input$col_falla != "No aplica") input$col_falla else NULL
      )
      SMRD::event.plot(datos.ld)
    }
  })
  
  
  steps <- reactive({
    data.frame(
      element = c("#start_tour", ".nav-tabs", "#start_tour", "#start_tour", "#start_tour", "#start_tour", "#start_tour", "#start_tour", "#start_tour", "#start_tour","#start_tour", "#start_tour", "#start_tour"),
      intro = c(
        "¡Bienvenido al tutorial interactivo de la aplicación Gráfico de Eventos! Vamos a guiarte a través de las principales funcionalidades.",
        "Estas son las pestañas principales de la aplicación. Puedes navegar entre ellas para acceder a diferentes funcionalidades.",
        "En la pestaña Cargar Datos puedes seleccionar el conjunto de datos, el cual se convertirá en un objeto de vida para el análisis posterior.",
        "En la opción Seleccionar Fuente de los Datos podrás elegir la forma en que quieres importar los datos.  <br><img src='tutorial_4.jpeg' style='width:200px; height:-200px;'><br><div style='margin-top:-90px;'></div>",
        "Puedes seleccionar una de las bases de datos del paquete SMRD (Statistical Methods for Reliability Data). <br><img src='tutorial_2.jpeg' style='width:200px; height:-200px;'><br><div style='margin-top:-90px;'></div>",
        "O puedes importar una base de datos. Para hacerlo, el archivo debe ser .csv y debe por lo menos contener una variable asociada a la variable respuesta, ya sea tiempos de falla o unidades experimentales. Adicionalmente, puedes escoger el delimitador que separa los valores en la base.<br><img src='tutorial_8.jpeg' style='width:200px; height:-200px;'><br><div style='margin-top:-90px;'></div>",
        "En ambas opciones, seleccionando una base del paquete SMRD o importándola desde tus archivos, es importante fijar el nombre de la columna que en tu base contiene las fallas y censuras.  <br><img src='tutorial_6.jpeg' style='width:200px; height:-200px;'><br><div style='margin-top:-90px;'></div>",
        "Una vez subida la base de datos, esta aparecerá resumida en un tabla, tal como se muestra a continuación:  <br><img src='tutorial_19.jpeg' style='width:250px; height:200px;'><br><div style='margin-top:-90px;'></div>",
        "En esta tabla existe un motor de búsqueda que te permitirá acceder a valores específicos de cualquier variable que sea de tu interés.  <br><img src='tutorial_20.jpeg' style='width:250px; height:200px;'><br><div style='margin-top:-90px;'></div>",
        "En la pestaña Resumen encontrarás un resumen estadístico de tus datos, incluyendo información sobre las fallas y censuras. <br><img src='tutorial_16.jpeg' style='width:250px; height:150px;'><br><div style='margin-top:-90px;'></div>",
        "En la pestaña Gráfico de Eventos encontrarás un menú con varias opciones. Es importante que selecciones correctamente la columna en cada de ellas, ya que son los parámetros que te permitirán visualizar de manera exitosa el gráfico.  <br><img src='tutorial_14.jpeg' style='width:250px; height:-200px;'><br><div style='margin-top:-90px;'></div>",
        "Una vez hayas seleccionado las columnas de manera apropiada, se te mostrará el gráfico de Eventos.   <br><img src='tutorial_15.jpeg' style='width:250px; height:150px;'><br><div style='margin-top:-90px;'></div>",
        "Esperamos te haya sido útil este tutorial. ¡Muchas Gracias!"
        
        
      )
    )
  })
  
  observeEvent(input$start_tour, {
    introjs(session, options = list(steps = steps(), 
                                    nextLabel = "Siguiente",
                                    prevLabel = "Anterior", 
                                    doneLabel = "Finalizar"))
  })
}

# Create the Shiny app
shinyApp(ui = ui, server = server)