# Pražské Isochrony

<p align="center">
  <img src="dojezd.png" alt="Mapa dojezdové vzdálenosti"/>
</p>

Před časem jsem na svém blogu publikoval [napůl vážně míněnou analýzu](http://www.jla-data.net/cze/cesta-z-mesta/) dojezdové vzdálenosti do obchodního centra [Arkády Pankrác](http://www.arkady-pankrac.cz) ze všech obcí České Republiky (kterých je něco málo přes šest tisíc).

K mému překvapení se tento článek sešel s nečekaně pozitivní odezvou, a stal s přehledem nejpopulárnějším příspěvkem z blogu. Z několika stran jsem byl požádán o zdrojový kód. Věřím v sílu Open Source, a rád se proto o zdroják podělím.

Mám k tomu pár komentářů, vesměs technických:  

* kód je napsaný v erku, což nemusí být každého šálek kávy; s tím bohužel nejde nic dělat...
* dvě knihovny - `ggmap`a `gmapsdistance` jsou na CRANu s chybami, je třeba použít GitHubovou verzi (kód pro instalaci je v komentáři ve skriptu)
* do kódu je třeba doplnit vlastní klíč pro [Google Distance Matrix API](https://console.cloud.google.com/apis/library/distance-matrix-backend.googleapis.com), což je služba vyžadující registraci. Za vytočení mapy si vyúčtují přibližně $2 při měsíčním kreditu $200 - cena jako taková tedy není problém, ale API key potřebujete.  
O svůj se nepodělím, protože svobodný software mám za *free* spíše v kontextu *free speech* nežli *free beer* = rád si kecám co chci - a přitom piju za své :)
* v kódu je vhodné změnit lokalitu cíle cesty v proměnné `pupek_sveta` - ta se následně ogeokóduje přes Google, který snese i trošku robustnější zacházení. Možno uvézt adresu, nebo třeba název budovy.  
"Kramářova vila" je platný cíl, stejně jako "Pankrácká věznice" či "Mauzoleum VI Lenina".
* výstupem je soubor `vystup.html` v mapou v [leafletu](https://leafletjs.com/).  
Je opravdu hodně velký (~ 100 MB) ale optimalizace velikosti polygonů obcí byla nad mé možnosti quick and dirty zveřejnění (článek na blogu je prohnaný přes zmenšovátko [Mapshaper](http://mapshaper.org/))
* počítejte s tím, že výpočet má nějaký doběh; když to pouštím v cloudu na AWS, kde odezva sítí zpravidla není téma, tak to běží klidně hodinu. Mějte proto trpělivost...
