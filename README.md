# PG5601-Eksamen
iOS Programmering Eksamen 2021

# Teknisk informasjon
Utviklet for iOS 15.
Swift versjon: 5.5.1
Target: x86_64-apple-macosx11.0 (Uvisst om dette er relevant for dere eller ikke)

Swift Package Manager Dependencies:
- AlamoFire (5.4.4)
- Kingfisher (7.1.1)
- swift-log (1.4.2)

## Introduksjon
Jeg har fokusert på å gjøre utviklingsprosessen så reell som mulig, slik at jeg har tatt noen hensyn til brukeropplevelsen i appen. Med dette mener jeg implementering av Activity Indicators og Alert modals for informasjonsflyt til brukeren og jeg har tatt valg i prosessen basert på det jeg mener vil gi best brukervennlighet. For debugging har jeg gjort mitt beste for å kommentere kode, samt å vise informative og konsise logg-meldinger for kritiske hendelser og annen viktig informasjon.

### Tekniske valg - Datahåndtering
Jeg har valgt å persistere data primært ved bruk av Core Data, men også User Defaults for blant annet API-seed. I Core data har jeg valgt å lage 3 forskjellige entiterer, der PersonEntity lagrer brukere når JSON-data hentes og parses til PersonEntity objekter med tilhørende relevant informasjon. Videre har jeg laget en EditedPersonEntity og en DeletedPersonEntity. En person vil bli flyttet mellom disse entitetene basert på om den har blitt endret eller slettet. Grunnen til at jeg ikke ønsket å lagre dette i UserDefaults eller som egne attributter på PersonEntity var at jeg ønsket å ha en oversiktlig håndtering av hvilke handlinger som hadde blitt gjort på brukeren, og at det skal være oversiktlig for andre personer å sette seg inn i dataflyten til applikasjonen. 

Dette har fungert fint, men har gjort at jeg blant annet måtte godta objekter av typen AnyObject på steder der en person kunne være enten PersonEntity eller EditedPersonEntity. Dette har jeg håndtert ved å grundig sjekke hvilken type object det opereres med slik at AnyObject blir mer trygg å jobbe med. Logikken tar også høyde for å passe på at en person slettes fra PersonEntity i samme operasjon som den overføres til EditedPersonEntity, det samme for DeletedPersonEntity.

Jeg har også gjort mitt beste for å følge god kodestandard vet å ekstrahere vitale identifikator-navn til en Constants fil som sørger for å unngå bugs basert på skrivefeil i størst mulig grad. 

### Informasjonsflyt og pattern
Jeg har tilstrebet å følge et MVC pattern, der jeg har trukket noe av funksjonaliteten ut fra ViewControllers for å passe på at de ikke blir for store og uoversiktlige. Dette gjorde jeg primært ved å ha en NetworkManager for håndtering av data-fetching og en PersistenceManager for metoder mot CoreData. Utover dette har jeg brukt delegate pattern der jeg har sett det hensiktsmessig, samt NotificationCenter i bl.a NetworkManager for å kunne kommunisere med flere ViewControllers samtidig. Jeg har også tilstrebet å ekstrahere mest mulig kode i egne selvforklarende funksjoner, med litt hjelp av kommentarer for å forklare implementasjon. For å holde koden ryddig har jeg også implementert Extensions på både egne og interne funksjoner og objekter slik at koden blir lettere å jobbe videre på.



