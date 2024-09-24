 -- INSERT DEFAULT VALUES

INSERT INTO "Catalogue" ("key", "en-GB", "da-DK") VALUES 
('DATA.UNNAMED.COLLECTION',     'Unnamed Collection',   'Navneløs Gruppering'), 
('DATA.UNNAMED.COLONY',         'Unnamed Colony',       'Navneløs Koloni'),
('DATA.UNNAMED.MINIGAME',       'Unnamed Minigame',     'Navneløst Miniaturespil'),
('DATA.UNNAMED.LOCATION',       'Unnamed Location',     'Navneløs Lokation'),
('DATA.UNNAMED.ACHIEVEMENT',    'Unnamed Achievement',  'Navneløs Præstation'),
('UI.DESCRIPTION_MISSING',      'Missing Description',  'Manglende Beskrivelse'),
('ACHIEVEMENT.TUTORIAL_COMPLETE.TITLE', 'Tutorial Complete', 'Undervisningstime Fuldført'),
('ACHIEVEMENT.TUTORIAL_COMPLETE.DESCRIPTION', 'You have braved the mighty obstacles of the tutorial - well done!', 'Du har trodset de uoverkommelige forhindringer i undervisningstimen - flot klaret!'),
('TUTORIAL.NAVIGATION_DEMO.DESCRIPTION', 'Write where you want to go, and press Enter', 'Skriv hvor du vil hen, og tryk Enter'),
('TUTORIAL.WELCOME.TITLE', 'Welcome', 'Velkommen'),
('TUTORIAL.TRIAL.DESCRIPTION', 'Your turn', 'Prøv selv')
;

INSERT INTO "AvailableLanguages" ("id", "code", "icon", "commonName") VALUES 
(1, 'en-GB', 14, 'English'),
(2, 'da-DK', 11, 'Dansk'),
(3, 'nb-NO', 12, 'Norsk'),
(4, 'sv-SE', 13, 'Svenska'),
(5, 'de-DE', 15, 'Deutsch'),
(6, 'nl-NL', 16, 'Nederlands');