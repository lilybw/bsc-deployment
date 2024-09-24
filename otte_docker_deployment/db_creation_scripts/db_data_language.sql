 -- INSERT DEFAULT VALUES

INSERT INTO "Catalogue" ("key", "en-GB", "da-DK") VALUES 
('DATA.UNNAMED.COLLECTION',     'Unnamed Collection',   'Navneløs Gruppering'), 
('DATA.UNNAMED.COLONY',         'Unnamed Colony',       'Navneløs Koloni'),
('DATA.UNNAMED.MINIGAME',       'Unnamed Minigame',     'Navneløst Miniaturespil'),
('DATA.UNNAMED.LOCATION',       'Unnamed Location',     'Navneløs Lokation'),
('DATA.UNNAMED.ACHIEVEMENT',    'Unnamed Achievement',  'Navneløs Præstation'),
('UI.DESCRIPTION_MISSING',      'Missing Description',  'Manglende Beskrivelse'),
('ACHIEVEMENT.TUTORIAL_COMPLETE.TITLE', 'Tutorial Complete', 'Undervisningstime Fuldført'),
('ACHIEVEMENT.TUTORIAL_COMPLETE.DESCRIPTION', 'You have braved the mighty obstacles of the tutorial - well done!', 'Du har trodset de uoverkommelige forhindringer i undervisningstimen - flot klaret!');

INSERT INTO "AvailableLanguages" ("id", "code", "icon") VALUES 
(1, 'en-GB', 14),
(2, 'da-DK', 11),
(3, 'nb-NO', 12),
(4, 'sv-SE', 13),
(5, 'de-DE', 15),
(6, 'nl-NL', 16);