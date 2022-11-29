FROM rocker/tidyverse

#### Install CRAN or Github packages not included in rocker/tidyverse container.
RUN install2.r plumber tidyverse tidymodels # Add more packages separated by spaces.

# RUN installGithub.r # Uncomment to add Github packages.

RUN R -e "install.packages(c('tidyverse','tidymodels','plumber'))"

#### Copies the files in this directory to files in your container.
COPY [".", "./"]

#### This starts your R-powered service.
ENTRYPOINT ["Rscript", "-e", "pr <- plumber::plumb(commandArgs()[9]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')), swagger = F)"]

CMD ["api.R"]
