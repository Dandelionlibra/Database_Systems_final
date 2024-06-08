CREATE TABLE elements (
    element_name VARCHAR(50) PRIMARY KEY
);
INSERT INTO elements (element_name) VALUES 
('Pyro'),
('Hydro'),
('Anemo'),
('Electro'),
('Dendro'),
('Cryo'),
('Geo');
----------------------
SELECT *
FROM elements;
----------------------

CREATE TABLE weapon_types (
    weapon_type_name VARCHAR(50) PRIMARY KEY
);
INSERT INTO weapon_types (weapon_type_name) VALUES 
('單手劍'),
('雙手劍'),
('弓'),
('長柄武器'),
('法器');
---------------------
SELECT *
FROM weapon_types;
---------------------