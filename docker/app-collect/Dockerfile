FROM oydeu/oyd-shiny:latest
MAINTAINER "Christoph Fabianek" christoph@ownyourdata.eu

RUN cd /srv/shiny-server \
        && rm -rf * \
        && git clone https://github.com/OwnYourData/app-collect.git \ 
        && mv app-collect/* . \
        && rm -r app-collect \
        && R -e "source('init.r')"

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
