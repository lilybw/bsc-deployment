 -- INSERT DEFAULT VALUES

INSERT INTO "Achievement" (id, title, description, icon) VALUES 
(1,     'ACHIEVEMENT.TUTORIAL_COMPLETE.TITLE',   'ACHIEVEMENT.TUTORIAL_COMPLETE.DESCRIPTION', 1);

INSERT INTO "AvailablePreference" ("preferenceKey", "availableValues") VALUES 
('language', ARRAY['en-GB', 'da-DK', 'nn-NO', 'nb-NO', 'sv-SE', 'de-DE', 'nl-NL']);