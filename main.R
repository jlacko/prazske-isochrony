library(tidyverse)
library(gmapsdistance) # pozor! ve CRANové verzi 3.3 je bug, GitHubová 3.1 funguje lépe = devtools::install_github("rodazuero/gmapsdistance")
library(RCzechia)
library(ggmap) # pozor! je vyžadována GitHubová 2.7.900, ne CRANová 2.6.1, verze = devtools::install_github("dkahle/ggmap")
library(tmap)
library(sf)

# pozor! v rámci hesla "piju za svý" je třeba si doplnit vlastní, platný Google API key
secret_key <- "sem-patří-platný-Google-API-key" # jednou pro pro package gmapdistance ...
register_google(key = secret_key) # ... podruhé pro package ggmap 

pupek_sveta <- geocode("poslanecká sněmovna parlamentu čr", output = "latlon") # v lat/lon stavu

obce <- obce_polygony() %>%
  filter(!NAZ_OBEC %in% c("Brno", "Praha")) %>% # bez Brna a Prahy - ty budou zvlášť...
  select(kod = KOD_OBEC,
         nazev = NAZ_OBEC)

casti <- casti() %>% # a tady je to Brno a Praha :)
  filter(NAZ_OBEC %in% c("Brno", "Praha")) %>%
  select(kod = KOD,
         nazev = NAZEV) 

obce <- rbind(obce, casti) # spojení obcí a částí do jednoho data framu

body <- obce %>% # body z polygonů pro výpočet časů
  st_transform(crs = 5514) %>% # šup do křováka ...
  st_centroid() %>% # centroidy vyžadují plošné CRS
  st_transform(crs = 4326) # ... a šup zas zpátky

body$latlon <- paste(st_coordinates(body)[,"Y"], # souřadnice na text ve struktuře napřed lat a potom lon
                              "+",
                              st_coordinates(body)[,"X"],
                              sep = "")

body$net <- NA # inicializace hodnoty pro usnadnění for cyklu
body$gross <- NA # dtto

for (i in seq_along(body$latlon)) # for cyklus - pro všechny obce zjistit a zaznamenat čistý a hrubý dojezdový čas
{
  
  asdf <- gmapsdistance(origin = body$latlon[i],
                        destination = paste(pupek_sveta$lat[1],"+",pupek_sveta$lon[1], sep = ""),
                        key = secret_key,
                        dep_date = "2018-06-29",
                        dep_time = "06:30:00 AM, UTC",
                        mode = "driving")
  
  body$net[i] <- asdf$Time # prostý čas
  body$gross[i] <- asdf$Time_traffic # čas s přihlédnutím k dopravní situaci
}

st_geometry(body) <- NULL # zrušení geometrie - z sf objektu se stane prostý data frame

obce <- obce %>% # zpátky pracuju s polygony
  select(kod) %>% # tedy vlastně kód obce + skrytý sloupec geometrie (kvůli kterému to celé dělám... :)
  inner_join(body, by = "kod") %>%
  mutate(dojezd = gross / 60) # minuty místo sekund

tmap_mode("view")

mapa <- tm_shape(obce) + tm_fill("dojezd", n = 12, title = "Dojezdový čas (min.)", 
                                 palette = "-RdYlBu", alpha = 0.6, id = "nazev",
                                 textNA = "jinak...", legend.format =  list(text.separator =  "-", text.align = "center")) +
  tm_view(basemaps = "Stamen.Toner", alpha = 1) + tm_view(basemaps = "Stamen.Toner", alpha = 1)

save_tmap(mapa, "vystup.html")
