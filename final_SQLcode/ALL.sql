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

    FOREIGN KEY (element) REFERENCES elements(element_type),
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name)
);

/*player_characters最初剛加入資料時，等級一定為1，且默認無裝備武器，
且player_characters 的character_hp為對應的characters 中的c_hp，
character_highest_atk為characters 中的c_atk+character_weapon關連到的weapons中的w_atk*/


-- character_expected_atk = (1-c_crit_rate) * c_atk + c_crit_rate * (c_atk * (c_crit_damage + 1))

CREATE TABLE weapons ( -- game weapons
    -- w_id SERIAL,
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

CREATE TABLE player_characters (
    character_name varchar(25),
	u_id integer NOT NULL,
    character_level integer DEFAULT 1 CONSTRAINT character_level_range CHECK (character_level >= 1 AND character_level <= 90),
    -- character_weapon varchar(25) DEFAULT NULL,
    character_weapon integer DEFAULT NULL,
	

    -- [(character_level-1)*elements.hp_bonus + c_hp]*(1 + w_hp)
    character_hp INTEGER,
    -- [(character_level-1)*(elements.atk_bonus + base_atk) + c_atk]*(1 + w_atk)
    character_atk INTEGER, -- character_lowest_atk
    -- [(character_level-1)*elements.def_bonus + c_def]*(1 + w_def)
    character_def INTEGER,
    -- character_crit_damage FLOAT,
    -- character_crit_rate FLOAT,

    -- character_atk*(1 + c_crit_damage + w_crit_damage)
    character_highest_atk INTEGER,
    -- c_crit_rate * character_highest_atk + (1-c_crit_rate) * character_atk
    character_expected_atk INTEGER,


    PRIMARY KEY(character_name),
    UNIQUE (u_id),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (character_name) REFERENCES characters(character_name) ON DELETE CASCADE,
    FOREIGN KEY (character_weapon) REFERENCES player_weapons(w_id) ON DELETE SET NULL
);


-- player_characters最初剛加入資料時，等級一定為1，且player_characters 的character_hp為對應的characters中的c_hp，
-- character_atk為對應的characters 中的c_atk，character_def為對應的characters 中的c_def，
-- character_highest_atk = c_atk * (c_crit_damage + 1), 
-- character_expected_atk = (1-c_crit_rate) * c_atk + c_crit_rate * (c_atk * (c_crit_damage + 1)), 
-- character_lowest_atk = c_atk

/*
CREATE TABLE player_weapons (
    u_id integer,
	w_id SERIAL,
    weapon_name varchar(25),
    
    PRIMARY KEY(u_id, w_id),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (weapon_name) REFERENCES weapons(weapon_name) ON DELETE CASCADE
);*/


CREATE TABLE player_weapons (
	w_id SERIAL,
    u_id integer NOT NULL,
    
    weapon_name varchar(25),
    
    PRIMARY KEY(w_id),
    UNIQUE (u_id),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (weapon_name) REFERENCES weapons(weapon_name) ON DELETE CASCADE
);



CREATE TABLE team (
    team_id SERIAL,
    u_id integer NOT NULL,
    create_time timestamp DEFAULT CURRENT_TIMESTAMP,
    team_name varchar(25) DEFAULT 'default teamname',
    member1 varchar(25),
    member2 varchar(25),
    member3 varchar(25),
    member4 varchar(25),
    expected_damage integer,
    highest_damage integer,
    lowest_damage integer,

    PRIMARY KEY(team_id),
    UNIQUE (u_id, create_time),
    FOREIGN KEY (u_id) REFERENCES players(u_id),
    FOREIGN KEY (member1) REFERENCES player_characters(character_name),
    FOREIGN KEY (member2) REFERENCES player_characters(character_name),
    FOREIGN KEY (member3) REFERENCES player_characters(character_name),
    FOREIGN KEY (member4) REFERENCES player_characters(character_name)

);

-- backup table
-- CREATE TABLE team_backup (
--     team_id SERIAL,
--     u_id integer NOT NULL,
--     create_time timestamp,
--     team_name varchar(25),
--     member1 varchar(25),
--     member2 varchar(25),
--     member3 varchar(25),
--     member4 varchar(25),
--     expected_damage integer,
--     highest_damage integer,
--     lowest_damage integer,

--     PRIMARY KEY(team_id),
--     UNIQUE (u_id),
-- 	FOREIGN KEY (create_time) REFERENCES team(create_time)
-- );


CREATE TABLE team_backup (
    team_id SERIAL PRIMARY KEY,
    u_id integer NOT NULL,
    create_time timestamp,
	backup_time timestamp DEFAULT CURRENT_TIMESTAMP,
    team_name varchar(25),
    member1 varchar(25),
    member2 varchar(25),
    member3 varchar(25),
    member4 varchar(25),
    expected_damage integer,
    highest_damage integer,
    lowest_damage integer,
    UNIQUE (u_id, create_time)
);
