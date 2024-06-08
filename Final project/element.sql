CREATE TABLE elements (
    element_type VARCHAR(50) PRIMARY KEY
);
INSERT INTO elements (element_type) VALUES 
('火'),('水'),('風'),('雷'),('草'),('冰'),('岩');

CREATE TABLE players (
	u_id SERIAL, -- SERIAL is a special data type that auto-increments
	player_name varchar(255),
	players_level integer,
	PRIMARY KEY(u_id, player_name)
);
-- 玩家擁有許多角色，玩家擁有的角色不能重複
-- 每個角色都對應一個元素，元素有七種，分別是Pyro、Hydro、Anemo、Electro、Dendro、Cryo、Geo
-- 玩家擁有許多武器，玩家擁有的武器可以重複
-- 每個武器都對應一個武器類型，武器類型有五種，分別是單手劍、雙手劍、弓、長柄武器、法器
-- 玩家可以將武器裝備到自己擁有的角色上，但不一定要將所有的角色裝備武器，
-- 玩家要從自己擁有的角色中選至少一個，最多四個角色組成一個隊伍，
-- 組成隊伍後需要計算，並記錄這個隊伍的角色組成、期望戰力、最高戰力、最低戰力

-- ('Pyro'),
-- ('Hydro'),
-- ('Anemo'),
-- ('Electro'),
-- ('Dendro'),
-- ('Cryo'),
-- ('Geo');

CREATE TABLE characters (
    character_name VARCHAR(100) PRIMARY KEY,
    element_type VARCHAR(50) NOT NULL,
    weapon_type VARCHAR(50) NOT NULL,
    hp INT NOT NULL CHECK (hp >= 0),
    atk INT NOT NULL CHECK (atk >= 0),
    def INT NOT NULL CHECK (def >= 0),
	crit_rate FLOAT NOT NULL DEFAULT 0,
	crit_dmg FLOAT NOT NULL DEFAULT 0.5,
    -- elemental_mastery INT NOT NULL CHECK (elemental_mastery >= 0),
    FOREIGN KEY (element_type) REFERENCES elements(element_type),
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type)
);

