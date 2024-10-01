INSERT INTO "Location" ("id", "name", "description", "minigame") VALUES 
(10, 'LOCATION.OUTER_WALLS.NAME', 'LOCATION.OUTER_WALLS.DESCRIPTION', 1),
(20, 'LOCATION.SPACE_PORT.NAME', 'LOCATION.SPACE_PORT.DESCRIPTION', null),
(30, 'LOCATION.HOME.NAME', 'LOCATION.HOME.DESCRIPTION', null); 

--Devour manages these, however, on boot (when this file is run) Devour has yet to populate it.
--That would cause foreign key constraint errors, so we'll be using placeholder
INSERT INTO "AssetCollection" ("id", "name", "useCase") VALUES
(10, 'PLACEHOLDER_OUTER_WALLS_LEVEL_1', 'placeholder'),
(11, 'PLACEHOLDER_OUTER_WALLS_LEVEL_2', 'placeholder'),
(12, 'PLACEHOLDER_OUTER_WALLS_LEVEL_3', 'placeholder'),
(13, 'PLACEHOLDER_OUTER_WALLS_LEVEL_4', 'placeholder'),
(14, 'PLACEHOLDER_OUTER_WALLS_LEVEL_5', 'placeholder'),
(20, 'PLACEHOLDER_SPACE_PORT', 'placeholder'),
(30, 'PLACEHOLDER_HOME', 'placeholder');

--Same case as the AssetCollection placeholders
INSERT INTO "GraphicalAsset" ("id", "alias", "type", "useCase", "width", "height") VALUES 
(5002, "placeholder_outer_walls_splash_art_level_one", "placeholder", "placeholder", 50, 50),
(5003, "placeholder_outer_walls_splash_art_level_two", "placeholder", "placeholder", 50, 50),
(5004, "placeholder_outer_walls_splash_art_level_three", "placeholder", "placeholder", 50, 50),
(5005, "placeholder_outer_walls_splash_art_level_four", "placeholder", "placeholder", 50, 50),
(5006, "placeholder_outer_walls_splash_art_level_five", "placeholder", "placeholder", 50, 50),
(5007, "placeholder_space_port_splash_art", "placeholder", "placeholder", 50, 50),
(5008, "placeholder_home_splash_art", "placeholder", "placeholder", 50, 50);

INSERT INTO "LocationAppearance" ("id", "level", "location", "spashArt", "assetCollection") VALUES
(1, 1, 10, 5002, 10),
(2, 2, 10, 5003, 11),
(3, 3, 10, 5004, 12),
(4, 4, 10, 5005, 13),
(5, 5, 10, 5006, 14),
(6, 1, 20, 5007, 20),
(7, 1, 30, 5008, 30);