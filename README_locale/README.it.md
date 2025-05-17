# VoxeLibre
Un gioco Minecraft-like non ufficiale per Luanti. Derivato da MineClone di davedevilis.
Sviluppato da molte persone. Non sviluppato o sponsorizzato da Mojang AB.

### Gameplay
Cominci in un mondo generato casualmente, fatto interamente di cubi. Puoi esplorare
il mondo e scavare e costruire quasi ogni blocco nel mondo per creare nuove
strutture. Puoi scegliere di giocare in "modalità sopravvivenza" nella quale dovrai
combattere i mostri e la fame per sopravvivere e progredire lentamente attraverso
vari aspetti del gioco, come le miniere, l'agricoltura, costruire dei meccanismi, e così via 
O puoi giocare in "modalità creativa" nella quale puoi costruire quasi qualunque cosa istantaneamente.

#### Sintesi del Gameplay

* Gameplay sandbox, nessun obiettivo
* Sopravvivenza: Combatti contro i mostri ostili e la fame
* Scava in cerca di materiali e altri tesori
* Magia: Guadagna esperienza e incanta i tuoi attrezzi
* Usa i blocchi che hai collezionato per creare grandiose costruzioni, l'unico limite sarà la tua immaginazione
* Colleziona fiori (e altre risorse per coloranti) e colora il tuo mondo
* Trova dei semi e inizia a coltivare
* Trova o costruisci uno di centinaia di oggetti
* Costruisci complessi macchinari con i circuiti di redstone
* In modalità creativa puoi costruire quasi qualunque cosa gratis e senza limiti

## Come giocare (quick start)
### Per cominciare
* **Colpisci il tronco di un albero** affinchè si rompa e raccogli il legno
* Piazza il **legno nella griglia 2x2** (la tua "griglia da fabbricazione" nel tuo inventario) e costruisci 4 assi di legno
* Piazza le 4 assi di legno in una forma 2x2 nella griglia da fabbricazione per **creare un banco da lavoro**
* **Fai click destro sul banco da lavoro** per sfruttare una griglia 3x3 per costruire cose più complesse
* Usa la **guida da fabbricazione** (icona del libro) per apprendere tuttle le possibili ricette
* **Costruisci una piccozza di legno** per poter scavare la pietra
* Diversi strumenti rompono diversi tipi di blocco. Provali tutti!
* Continua a giocare come preferisci. Divertiti!

### Agricoltura
* Trova dei semi
* Costruisci una zappa
* Fai click destro sulla terra o un blocco simile con la zappa per renderla coltivabile
* Piazza dei semi sulla terra lavorata e guardali crescere
* Raccogli le piante quando maturano completamente
* Se vicino all'acqua, la terra lavorata si bagna e accelera la maturazione

### Fornace
* Costruisci una fornace
* La fornace ti permette di ottenere più oggetti
* Lo slot superiore deve contenere un oggetto fondibile (esempio: minerale di ferro)
* Lo slot inferiore deve contenere un carburante (esempio: carbone)
* Leggi i consigli nella guida di fabbricazione per saperne di più sui carburanti e gli oggetti fondibili

### Aiuti aggiuntivi
More help about the gameplay, blocks items and much more can be found from inside
the game. You can access the help from your inventory menu.
Ulteriore aiuto sul gameplay, i blocchi, gli oggetti e molto altro possono essere
trovati all'interno del gioco. Puoi accedere alla schermata di aiuti dall'inventario.

### Oggetti speciali
The following items are interesting for Creative Mode and for adventure
map builders. They can not be obtained in-game or in the creative inventory.
I seguenti oggetti sono interessanti per la Modalità Creativa e per i costruttori
di mappe da avventura. Non possono essere ottenuti in gioco o dall'inventario
della modalità creativa.

* Barriera: `mcl_core:barrier`

Usa il comando `/giveme` nella per ottenerli. Vedi gli aiuti in gioco per ottenere
una spiegazione

## Installazione
Per eseguire il gioco con le migliori prestazioni e supporto, consigliamo l'ultima
versione stabile di [Luanti](https://www.luanti.org/), ma ci impegniamo sempre a
supportare una versione dietro l'ultima versione stabile.
Quindi come prima cosa installa Luanti. Solo le versioni stable di Luanti
sono ufficialmente supportate.
Non è supportato l'avvio di VoxeLibre su versioni da sviluppatore di Luanti.

Per installare VoxeLibre (se non lo hai già fatto), sposta questa cartella dentro
la cartella "games" nella tua cartella dei dati di Luanti. Consulta la wiki di 
Luanti per saperne di più.

## Link utili
La repo di VoxeLibre è su Mesehub. Per contribuire o comunicare dei problemi, procedi là.

* Mesehub: <https://git.minetest.land/VoxeLibre/VoxeLibre>
* Discord: <https://discord.gg/xE4z8EEpDC>
* YouTube: <https://www.youtube.com/channel/UClI_YcsXMF3KNeJtoBfnk9A>
* ContentDB: <https://content.luanti.org/packages/wuzzy/mineclone2/>
* OpenCollective: <https://opencollective.com/voxelibre>
* Mastodon: <https://fosstodon.org/@VoxeLibre>
* Lemmy: <https://lemm.ee/c/voxelibre>
* Matrix space: <https://app.element.io/#/room/#voxelibre:matrix.org>
* Luanti forums: <https://forum.luanti.org/viewtopic.php?f=50&t=16407>
* Reddit: <https://www.reddit.com/r/VoxeLibre/>
* IRC (barely used): <https://web.libera.chat/#mineclone2>

## Obiettivi
- Creare un gioco basato su Minecraft, sul motore di gioco di Luanti
che sia libero, stabile e moddabile, con funzioni perfezionate, usabile sia in 
giocatore singolo che in multigiocatore. Al momento, molte funzionalità della versione
Java di Minecraft sono state implementate e il perfezionamento di quelle già esistenti
è prioritario rispetto all'aggiungta di nuove funzionalità.
- Implementare funzionalità comprese nella versione corrente di Minecraft + OptiFine
(OptiFine solo come supportato dal motore di gioco di Luanti).
- Creare un'esperienza performante che giri relativamente su computer poco prestanti.

## Stato dello sviluppo
Questo gioco è in fase di **beta** al momento.
È giocabile, ma non ancora completo per quanto riguarda le funzionalità.
Compatibilità con versioni precedenti di Luanti non è garantita, aggiornare il tuo mondo
potrebbe causare dei piccoli bug.
Se desideri usare le versioni da sviluppatore di VoxeLibre in produzione, il branch master è solitamente relativamente stabile.

Le seguenti funzionalità principali sono disponibili:

* Strumenti e armi
* Armature
* Sistema di fabbricazione: griglia 2x2, banco da lavoro (griglia 3x3), fornace e guida di fabbricazione
* Bauli, bauli grandi, bauli di ender, scatole di shulker
* Fornaci, tramoggie
* Fame
* La maggior parte dei mostri e degli animali
* Tutti i minerali di Minecraft
* La maggior parte dei blocchi dell'overworld
* Acqua e lava
* Meteo
* 28 biomi + 5 biomi del Nether
* Il Nether, un ardente sotterraneo in un'altra dimensione
* Circuiti di Redstone (parziale)
* Carrelli da miniera (parziale)
* Effetti di stato (parziale)
* Esperienza
* Incantamento
* Alchimia, pozioni, frecce imbevute (parziale)
* Barche
* Fuoco
* Blocchi da costruzione: Scale, lastre, porte, botole, staccionate, cancelli (staccionate), muri
* Orologio
* Bussola
* Spugna
* Blocco di slime
* Piccole piante e alberelli
* Coloranti
* Stendardi
* Blocchi decorativi: Vetro, vetro colorato, pannelli di vetro, terracotta (e colori), teste e tanto altro
* Cornici
* Jukeboxes
* Letti
* Menu dell'inventario
* Inventario modalità creativa
* Agricoltura
* Libri scrivibili
* Comandi
* Villaggi
* The End
* E tanto altro!

Le seguenti funzionalità sono incomplete:

* Alcuni mostri e animali
* Cose relative all redstone
* Alcuni carrelli da miniera particolari (i carrelli da miniera con tramoggia e con baule funzionano)
* Alcuni blocchi e oggetti non banali

Funzionalità bonus (non incluse in Minecraft):

* Guida da fabbricazione inclusa che mostra ricette di fabbricazione e di forgiatura
* Sistema di aiuti in gioco contenente informazioni estese su basi del gameplay, blocchi, oggetti e altro
* Ricette di fabbricazione temporanee. Esistono solamente per rendere disponibili oggetti altrimenti non ottenibili quando non sei in modalità creativa. Queste ricette verranno rimosse man mano che lo sviluppo avanza e più funzionalità vengono implementate.
* Completamente moddabile (grazie alla potente API Lua di Luanti)
* Nuovi blocchi e oggetti:
    * Strumento informativo, ti mostra l'aiuto per ciò che colpisci
    * Più lastre e scale
    * Cancello di Mattoni del Nether
    * Staccionata di Mattoni Rossi del Nether
    * Cancello di Mattoni Rossi del Nether
* Strutture di rimpiazzo - queste piccole varianti dell strutture di Minecraft servono come rimpiazzo finchè faremo funzionare strutture più grandi:
    * Cabina dei boschi (Ville)
    * Avamposto del Nether (Fortezza)

Technical differences from Minecraft:
Differenze tecniche da Minecraft:
* Limite di altezza di circa 31000 blocchi (molto più alto che in Minecraft)
* Limite orizzontale del mondo di circa 62000x62000 blocchi (molto più piccolo che in Minecraft, ma comunque molto ampio)
* Ancora molto incompleto e buggato
* Blocchi, oggett, nemici e altre funzionalità mancano
* Alcuni oggetti hanno nomi leggermente diversi per renderli più facili da distinguere
* Diverse musiche per il jukebox
* Diverse texture (Pixel Perfection)
* Diversi suoni (varie fonti)
* Diverso motore di gioco (Luanti)
* Diversi easter eggs

… e infine, VoxeLibre è software libero!

## Altri file readme

* `LICENSE.txt`: Il testo della licenza GPLv3
* `CONTRIBUTING.md`: Informazioni per coloro che vogliono contribuire
* `API.md`: Per i modder di Luanti che vogliono moddare questo gioco
* `LEGAL.md`: Informazioni legali
* `CREDITS.md`: List di tutti coloro che hanno contribuito
