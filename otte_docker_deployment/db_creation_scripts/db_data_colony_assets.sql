--Same case as the AssetCollection placeholders
INSERT INTO "GraphicalAsset" ("id", "alias", "type", "useCase", "width", "height") VALUES 
(1021, 'placeholder_minigame_asteroids_icon', 'placeholder', 'placeholder', 50, 50),
(5002, 'placeholder_outer_walls_splash_art_level_one', 'placeholder', 'placeholder', 50, 50),
(5003, 'placeholder_outer_walls_splash_art_level_two', 'placeholder', 'placeholder', 50, 50),
(5004, 'placeholder_outer_walls_splash_art_level_three', 'placeholder', 'placeholder', 50, 50),
(5005, 'placeholder_outer_walls_splash_art_level_four', 'placeholder', 'placeholder', 50, 50),
(5006, 'placeholder_outer_walls_splash_art_level_five', 'placeholder', 'placeholder', 50, 50),
(5007, 'placeholder_space_port_splash_art', 'placeholder', 'placeholder', 50, 50),
(5008, 'placeholder_home_splash_art', 'placeholder', 'placeholder', 50, 50),
(5009, 'placeholder_town_hall_splash_art', 'placeholder', 'placeholder', 50, 50);

INSERT INTO "MiniGame" ("id", "name", "description", "icon", "settings") VALUES 
(1, 'MINIGAME.ASTEROIDS.NAME', 'MINIGAME.ASTEROIDS.DESCRIPTION', 1021, '{}');

INSERT INTO "Location" ("id", "name", "description", "minigame") VALUES
(10, 'LOCATION.OUTER_WALLS.NAME', 'LOCATION.OUTER_WALLS.DESCRIPTION', 1),
(20, 'LOCATION.SPACE_PORT.NAME', 'LOCATION.SPACE_PORT.DESCRIPTION', null),
(30, 'LOCATION.HOME.NAME', 'LOCATION.HOME.DESCRIPTION', null),
(40, 'LOCATION.TOWN_HALL.NAME', 'LOCATION.TOWN_HALL.DESCRIPTION', null),
(50, 'LOCATION.SHIELD_GENERATORS.NAME', 'LOCATION.SHIELD_GENERATORS.DESCRIPTION', null),
(60, 'LOCATION.AQUIFER_PLANT.NAME', 'LOCATION.AQUIFER_PLANT.DESCRIPTION', null),
(70, 'LOCATION.AGRICULTURE_CENTER.NAME', 'LOCATION.AGRICULTURE_CENTER.DESCRIPTION', null),
(80, 'LOCATION.VEHICLE_STORAGE.NAME', 'LOCATION.VEHICLE_STORAGE.DESCRIPTION', null),
(90, 'LOCATION.CANTINA.NAME', 'LOCATION.CANTINA.DESCRIPTION', null),
(100, 'LOCATION.RADAR_DISH.NAME', 'LOCATION.RADAR_DISH.DESCRIPTION', null),
(110, 'LOCATION.MINING_FACILITY.NAME', 'LOCATION.MINING_FACILITY.DESCRIPTION', null);

--Devour manages these, however, on boot (when this file is run) Devour has yet to populate it.
--That would cause foreign key constraint errors, so we'll be using placeholder
INSERT INTO "AssetCollection" ("id", "name", "useCase") VALUES
(10, 'PLACEHOLDER_OUTER_WALLS_LEVEL_1', 'placeholder'),
(11, 'PLACEHOLDER_OUTER_WALLS_LEVEL_2', 'placeholder'),
(12, 'PLACEHOLDER_OUTER_WALLS_LEVEL_3', 'placeholder'),
(13, 'PLACEHOLDER_OUTER_WALLS_LEVEL_4', 'placeholder'),
(14, 'PLACEHOLDER_OUTER_WALLS_LEVEL_5', 'placeholder'),
(20, 'PLACEHOLDER_SPACE_PORT', 'placeholder'),
(30, 'PLACEHOLDER_HOME', 'placeholder'),
(40, 'PLACEHOLDER_TOWN_HALL', 'placeholder'),
(50, 'PLACEHOLDER_SHIELD_GENERATORS', 'placeholder'),
(60, 'PLACEHOLDER_AQUIFER_PLANT', 'placeholder'),
(70, 'PLACEHOLDER_AGRICULTURE_CENTER', 'placeholder'),
(80, 'PLACEHOLDER_VEHICLE_STORAGE', 'placeholder'),
(90, 'PLACEHOLDER_CANTINA', 'placeholder'),
(100, 'PLACEHOLDER_RADAR_DISH', 'placeholder'),
(110, 'PLACEHOLDER_MINING_FACILITY', 'placeholder');

INSERT INTO "LocationAppearance" ("id", "level", "location", "splashArt", "assetCollection") VALUES
(1, 1, 10, 5002, 10),
(2, 2, 10, 5003, 11),
(3, 3, 10, 5004, 12),
(4, 4, 10, 5005, 13),
(5, 5, 10, 5006, 14),
(6, 1, 20, 5007, 20),
(7, 1, 30, 5008, 30),
(8, 1, 40, 5009, 40),
(9, 1, 50, 5010, 50),
(10, 1, 60, 5011, 60),
(11, 1, 70, 5012, 70),
(12, 1, 80, 5013, 80),
(13, 1, 90, 5014, 90),
(14, 1, 100, 5015, 100),
(15, 1, 110, 5016, 110);