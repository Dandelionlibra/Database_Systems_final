CREATE TABLE players (
    uid SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    level INT NOT NULL DEFAULT 1
);

CREATE TABLE player_characters (
    uid INT NOT NULL,
    character_name VARCHAR(100) NOT NULL,
    character_level INT NOT NULL DEFAULT 1,
    weapon_name VARCHAR(100),
    hp INT NOT NULL,
    atk INT NOT NULL,
    def INT NOT NULL,
    crit_rate FLOAT NOT NULL DEFAULT 0,
    crit_dmg FLOAT NOT NULL DEFAULT 0.5,
    PRIMARY KEY (uid, character_name),
    FOREIGN KEY (uid) REFERENCES players(uid),
    FOREIGN KEY (character_name) REFERENCES characters(character_name),
    FOREIGN KEY (weapon_name) REFERENCES weapons(weapon_name)
);
CREATE TABLE player_weapons (
    uid INT NOT NULL,
    weapon_name VARCHAR(100) NOT NULL,
    weapon_level INT NOT NULL DEFAULT 1,
    hp INT NOT NULL,
    atk INT NOT NULL,
    def INT NOT NULL,
    crit_rate FLOAT NOT NULL DEFAULT 0,
    crit_dmg FLOAT NOT NULL DEFAULT 0,
    PRIMARY KEY (uid, weapon_name),
    FOREIGN KEY (uid) REFERENCES players(uid),
    FOREIGN KEY (weapon_name) REFERENCES weapons(weapon_name)
);