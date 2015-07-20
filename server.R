
## constants
m2k <- 1.609

## utility functions
ageCheck <- function(age.txt) {
    default.value <- 18
    min.value <- 1
    max.value <- 150
    age.num <- suppressWarnings(as.numeric(age.txt))
    age.num <- ifelse(is.na(age.num), default.value, age.num)
    age.num <- ifelse(age.num < min.value, min.value, age.num)
    age.num <- ifelse(age.num > max.value, max.value, age.num)
    return(age.num)
}

waterCheck <- function(water.txt, water.units) {
## Expect comma separated list of distances of water stations
## Convert to numeric vector
    water.num <- suppressWarnings(as.numeric(unlist(strsplit(water.txt, ","))))
    if (sum(is.na(water.num)) > 0) {
## Trap for non-numeric or otherwise ill-formed input
        water.num <- 0
    }
    if (water.units == "miles") {
        water.num <- water.num * m2k
    }
    return(water.num)
}

#load model
dummy.predict <- function(data) {
    #loss.rate <- predict(model, data)
    loss.rate <- 50 #ml/km
    return(loss.rate)
}

calculateRehydration <- function(race.dist, water.dists, loss.rate) {
    rehydrate <- rep(0, length(race.dist))
    water.intervals <- diff(c(0, water.dists))
    water.loss.per.interval <- water.intervals * loss.rate
    for (i in 1:length(water.dists)) {
        this.dist <- water.dists[i]
        this.loss <- water.loss.per.interval[i]
        rehydrate[which.min(abs(race.dist-this.dist))] <- this.loss
    }
    return(list(rehydrate=rehydrate, intake=water.loss.per.interval) )
}



server <- function(input, output) {
   age.num <- reactive({ageCheck(input$age)})
   water.num <- reactive({waterCheck(input$water, input$waterUnits)})
   in.df <- reactive({data.frame(age=age.num(), sex=input$sex, race.distance=input$distance)})
   water.loss.rate <- reactive({dummy.predict(in.df())})

   distance <- reactive({seq(0, as.numeric(input$distance), 0.1)})
   dehydration <- reactive({0 - distance() * water.loss.rate()})
   water.intervals <- reactive({diff(c(0, water.num()))})

   rehydration <- reactive({calculateRehydration(distance(), water.num(), water.loss.rate())})
   hydration <- reactive({dehydration() + cumsum(rehydration()$rehydrate)})
   dehydration.max <- reactive({min(hydration())})


   output$hydration.plot <- renderPlot({
       plot(distance(), hydration(), type="l",
            xlab = "Distance (km)", ylab = "Relative hydration (ml)",
            main = "Race hydration level")
       abline(h=0, lty=3, col="green")
       abline(h=dehydration.max(), col="red", lty=1)
       abline(v=water.num(), lty=2)
   })
   output$intake.table <- renderTable({ data.frame(Distance=water.num(), Intake=as.integer(rehydration()$intake)) })

   output$person <- renderText({paste0(age.num(), " year old ", input$sex)})
   output$race <- renderText({
                    paste0("running ", input$distance, " km with ",
                            length(water.num()), " water stations at ", 
                            paste(round(water.num(), 1), collapse=", "), " km") })
}
