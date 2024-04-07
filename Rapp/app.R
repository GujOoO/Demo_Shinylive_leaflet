library(sf)
wbd_reg2 <- st_read("https://raw.githubusercontent.com/khondula/leaflet-in-R-shinydemo2/master/data/wbd_reg2.geojson") 
wbd_reg2 <- wbd_reg2[wbd_reg2$REG == "02",] %>%
   st_transform(4326)

# user interface with map and color scheme widget
ui <- fluidPage(
   leafletOutput("map", height = 800),
   absolutePanel(top = 10, right = 10, draggable = TRUE,
      selectInput(inputId = "colors",
         label = "Color Scheme",
         choices = row.names(brewer.pal.info))
   ))
# server definition
server <- function(input, output) {
   output$map <- renderLeaflet({
      
      # use this line with leafletproxy for default colors
      pal <- colorNumeric("BrBG", wbd_reg2$AREA) 
      
      # map with polygons and legend
      leaflet() %>%
         addTiles() %>%
         setView(lng = -76.505206, lat = 38.9767231, zoom = 7) %>%
         addPolygons(data = wbd_reg2, 
            fill = TRUE,
            color = "black", 
            weight =1,
            fillColor = ~pal(AREA), # color is function of the wbd AREA column
            fillOpacity = 0.8,
            popup = ~HUC_NAME) %>%
         addLegend(position = "bottomright", pal = pal, values = wbd_reg2$AREA)
   })
   
   # update map using leaflet proxy instead of recreating the whole thing
   # use observe to color layer as needed
   observe({
      # color palette is defined according to the user's input
      pal <- colorNumeric(input$colors, wbd_reg2$AREA)
      
      # the map is updated with the new prefered color palette
      # notice we use leafletProxy() instead of leaflet()
      leafletProxy("map") %>%
         clearShapes() %>% clearControls() %>%
         addPolygons(data = wbd_reg2, fill = TRUE,
            color = "black", weight =1,
            fillColor = ~pal(AREA),
            fillOpacity = 0.8,
            popup = ~HUC_NAME) %>%
         addLegend(position = "bottomright", pal = pal, values = wbd_reg2$AREA)
   })
}
shinyApp(ui, server)
