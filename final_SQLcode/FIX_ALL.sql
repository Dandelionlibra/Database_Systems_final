CREATE TABLE players (
    u_id SERIAL PRIMARY KEY, 
    player_name varchar(25) NOT NULL,
    players_level integer DEFAULT 1 CONSTRAINT player_level_range CHECK (players_level >= 1 AND players_level <= 60)
);
-- 設置序列的起始值為 100000
ALTER SEQUENCE players_u_id_seq RESTART WITH 100000;

CREATE TABLE elements (
    element_type VARCHAR(25) PRIMARY KEY,
    hp_bonus INTEGER NOT NULL DEFAULT 1,
    atk_bonus INTEGER NOT NULL DEFAULT 1,
    def_bonus INTEGER NOT NULL DEFAULT 1
);
INSERT INTO elements (element_type, hp_bonus, atk_bonus, def_bonus) VALUES
('Pyro', 22, 13, 10), -- 火
('Hydro', 25, 11, 11), -- 水
('Anemo', 24, 12, 10), -- 風
('Electro', 22, 13, 12), -- 雷
('Dendro', 22, 12, 12), -- 草
('Cryo', 23, 12, 11), -- 冰
('Geo', 22, 13, 11); -- 岩
UPDATE elements
SET element_type = '火'
WHERE element_type = 'Pyro' ;
UPDATE elements
SET element_type = '水'
WHERE element_type = 'Hydro' ;
UPDATE elements
SET element_type = '風'
WHERE element_type = 'Anemo' ;
UPDATE elements
SET element_type = '雷'
WHERE element_type = 'Electro' ;
UPDATE elements
SET element_type = '草'
WHERE element_type = 'Dendro' ;
UPDATE elements
SET element_type = '冰'
WHERE element_type = 'Cryo' ;
UPDATE elements
SET element_type = '岩'
WHERE element_type = 'Geo' ;


CREATE TABLE weapon_types (
    weapon_type_name VARCHAR(25) PRIMARY KEY,
    atk_bonus INTEGER NOT NULL DEFAULT 1
);
INSERT INTO weapon_types (weapon_type_name, atk_bonus) VALUES 
('單手劍', 6),
('雙手劍', 7),
('弓', 6),
('長柄武器', 7),
('法器', 8);

CREATE TABLE weapons ( -- game weapons
    weapon_name varchar(25) PRIMARY KEY,
    weapon_type varchar(25) NOT NULL,
    base_atk integer NOT NULL DEFAULT 0,

    w_hp FLOAT NOT NULL DEFAULT 0,
    w_atk FLOAT NOT NULL DEFAULT 0,
    w_def FLOAT NOT NULL DEFAULT 0,
    W_crit_damage FLOAT NOT NULL DEFAULT 0,
    W_crit_rate FLOAT NOT NULL DEFAULT 0,

    -- weapon_description varchar(255) NOT NULL,
    -- PRIMARY KEY(w_id, weapon_name),
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name)
);

-- 删除舊的外鍵
ALTER TABLE weapons DROP CONSTRAINT weapons_weapon_type_fkey;
-- 新的外鍵約束，包含 ON UPDATE CASCADE
ALTER TABLE weapons
ADD CONSTRAINT weapons_weapon_type_fkey
FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name) ON UPDATE CASCADE;


CREATE TABLE characters ( -- game characters
    -- c_id SERIAL,
    character_name VARCHAR(25) PRIMARY KEY,
    element VARCHAR(25) NOT NULL,
    weapon_type VARCHAR(25) NOT NULL,
    c_hp integer NOT NULL DEFAULT 0,
    c_atk integer NOT NULL DEFAULT 0,
    c_def integer NOT NULL DEFAULT 0,
    c_crit_damage FLOAT NOT NULL DEFAULT 0,
    c_crit_rate FLOAT NOT NULL DEFAULT 0,

    -- FOREIGN KEY (element) REFERENCES elements(element_type),
	FOREIGN KEY (element) REFERENCES elements(element_type) ON UPDATE CASCADE;
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name)
);

-- 删除舊的外鍵
ALTER TABLE characters DROP CONSTRAINT characters_element_fkey;
-- 新的外鍵約束，包含 ON UPDATE CASCADE
ALTER TABLE characters
ADD CONSTRAINT characters_element_fkey
FOREIGN KEY (element) REFERENCES elements(element_type) ON UPDATE CASCADE;


CREATE TABLE player_characters (
    u_id INTEGER NOT NULL,
    character_name VARCHAR(25) NOT NULL,
    character_level INTEGER DEFAULT 1 CONSTRAINT character_level_range CHECK (character_level >= 1 AND character_level <= 90),
    character_weapon VARCHAR(25) DEFAULT NULL,
    PRIMARY KEY (u_id, character_name),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (character_name) REFERENCES characters(character_name) ON DELETE CASCADE,
    FOREIGN KEY (character_weapon) REFERENCES weapons(weapon_name) ON DELETE SET NULL
);

CREATE TABLE team (
    team_id SERIAL,
    u_id INTEGER NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    team_name VARCHAR(25) DEFAULT 'default teamname',

    member1 VARCHAR(25) DEFAULT NULL,
    member2 VARCHAR(25) DEFAULT NULL,
    member3 VARCHAR(25) DEFAULT NULL,
    member4 VARCHAR(25) DEFAULT NULL,
	PRIMARY KEY(u_id, team_id),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (u_id, member1) REFERENCES player_characters(u_id, character_name),
    FOREIGN KEY (u_id, member2) REFERENCES player_characters(u_id, character_name),
    FOREIGN KEY (u_id, member3) REFERENCES player_characters(u_id, character_name),
    FOREIGN KEY (u_id, member4) REFERENCES player_characters(u_id, character_name)
);

-- ALTER TABLE team ALTER COLUMN member1 DROP NOT NULL;
-- ALTER TABLE team ALTER COLUMN member1 SET DEFAULT NULL;


CREATE TABLE team_backup (
    team_id SERIAL PRIMARY KEY,
    u_id INTEGER NOT NULL,
	
    create_time TIMESTAMP,
    backup_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    team_name VARCHAR(25),

    member1 VARCHAR(25) DEFAULT NULL,
    member2 VARCHAR(25) DEFAULT NULL,
    member3 VARCHAR(25) DEFAULT NULL,
    member4 VARCHAR(25) DEFAULT NULL,
    expected_damage INTEGER,
    highest_damage INTEGER,
    lowest_damage INTEGER
);

ALTER TABLE team_backup ALTER COLUMN u_id DROP UNIQUE;
ALTER TABLE team ALTER COLUMN u_id SET DEFAULT NULL;