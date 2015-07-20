library(shiny)
## constants
m2k <- 1.609
marathon <- 42.195

ui <- fluidPage(
    h1("Race day hydration tool v 0.1", align = "center"),
    column(4, 
        tabsetPanel(
            tabPanel("Race info",
                wellPanel(
                    h3("Enter personal and race details below:"),
                        radioButtons(inputId = "sex", 
                                label = "Select your sex",
                                choices = c("male", "female")),
                        textInput(inputId = "age",
                                label = "Enter your age [1-150]"),
                        selectInput(inputId = "distance",
                                label = "Select race distance",
                                choices = c("5 km" = 5,
                                            "5 mile" = 5 * m2k,
                                            "10 km" = 10,
                                            "10 mile" = 10 * m2k,
                                            "1/2 marathon" = .5 * marathon,
                                            "marathon" = marathon)),
                        textInput(inputId = "water",
                                label = "Enter comma separated distances of water stations (e.g. 4, 8, 12)"),
                        radioButtons(inputId = "waterUnits",
                                label = "Water station distance units",
                                choices = c("miles", "km"))
                )
            ),
            tabPanel("About",
                h3("Introduction"),
                p("Hydration on race day is an often overlooked factor. Getting it wrong could
                mean desperate darts behind bushes or dehydration on a hot day that requires
                medical treatment. This tool uses highly advanced machine learning techniques
                (okay, I assume a steady 50 ml loss per km) based on hundreds (okay, a handful)
                of weight loss measurements from a huge army of volunteer runners (okay, me) 
                to predict your hydration level throughout the duration of your race. But you get
                the idea!"),
                p("This beta version of the tool allows you to visualise the amount of water you
                lose over distance, for the most common race distances, and thus what volume of 
                water you should consider taking in
                at the specified water stations. Improvements planned for future versions include
                individually-tailored predictions, predictions that factor in the race day 
                weather conditions, and a wider range of preset race distances as well as the
                ability to enter an arbitrary distance."),
                h3("Instructions for use"),
                p("Simply enter the requested information about yourself and the race on the
                'Race info' tab. The summary information in the panel on the right will update
                along with the graph of hydration level and table of suggested intake volumes.
                If you experience unexpected/strange results or see no results, pay attention
                that the water station distances are input in the format specified and the 
                selected units are correct."),
                h3("Warranty and disclaimer"),
                p("This tool comes with no warranty whatsoever. If you die through dehydration in
                Death Valley it's your own silly fault. But if you have a nice GPS watch that
                you're obviously no longer needing, then feel free to send it to us. Freepost
                is not an option. What, do you think I'm made of money?")
            )
        )
    ),
    column(8, 
        fluidRow(
            column(8,
                h3("Summary:"),
                p(textOutput("person")),
                p(textOutput("race")),
                br(),
                p("The table to the right summarizes the water intake (ml) recommended
                    at each water stop to maintain your hydration level."
                ),
                p("The plot below represents your estimated hydration level, relative to the
                start of the race (0), if you drink the recommended amount of water at each
                station. The green horizontal line is the reference start level. The red
                horizontal line shows the estimated maximum dehydration level."
                )
            ),
            column(4, 
                tableOutput("intake.table")
            )
        ),
        fluidRow(
            plotOutput("hydration.plot")
        )
    )
)
