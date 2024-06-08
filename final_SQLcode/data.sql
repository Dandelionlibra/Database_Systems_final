/*
CREATE TABLE weapons ( -- game weapons
    w_id SERIAL,
    weapon_name varchar(25),
    weapon_type varchar(25) NOT NULL,
    base_atk integer NOT NULL DEFAULT 0,
    w_hp FLOAT NOT NULL DEFAULT 0,
    w_atk FLOAT NOT NULL DEFAULT 0,
    w_def FLOAT NOT NULL DEFAULT 0,
    W_crit_damage FLOAT NOT NULL DEFAULT 0,
    W_crit_rate FLOAT NOT NULL DEFAULT 0,

    weapon_description varchar(255) NOT NULL,
    PRIMARY KEY(w_id, weapon_name)
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name)
);
*/

INSERT INTO weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, W_crit_damage, W_crit_rate) VALUES 
('天空之刃', '單手劍', 0, 0, 0, 0, 0),
('斫峰之刃', '單手劍', 0, 0, 0, 0, 0),
('波亂月白經津', '單手劍', 0, 0, 0, 0, 0),
('磐岩結綠', '單手劍', 0, 0, 0, 0, 0),
('蒼古自由之誓', '單手劍', 0, 0, 0, 0, 0),
('霧切之回光', '單手劍', 0, 0, 0, 0, 0),
('風鷹劍', '單手劍', 0, 0, 0, 0, 0),
('聖顯之鑰', '單手劍', 0, 0, 0, 0, 0),
('裁葉萃光', '單手劍', 0, 0, 0, 0, 0),
('靜水流湧之輝', '單手劍', 0, 0, 0, 0, 0),
('有樂御簾切', '單手劍', 0, 0, 0, 0, 0);


INSERT INTO weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, W_crit_damage, W_crit_rate) VALUES 
('狼的末路', '雙手劍', 0, 0, 0, 0, 0),
('天空之傲', '雙手劍', 0, 0, 0, 0, 0),
('松籟響起之時', '雙手劍', 0, 0, 0, 0, 0),
('無工之劍', '雙手劍', 0, 0, 0, 0, 0),
('赤角石潰杵', '雙手劍', 0, 0, 0, 0, 0),
('葦海信標', '雙手劍', 0, 0, 0, 0, 0),
('裁斷', '雙手劍', 0, 0, 0, 0, 0);

INSERT INTO weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, W_crit_damage, W_crit_rate) VALUES 
('天空之翼', '弓', 0, 0, 0, 0, 0),
('冬極白星', '弓', 0, 0, 0, 0, 0),
('終末嗟嘆之詩', '弓', 0, 0, 0, 0, 0),
('阿莫斯之弓', '弓', 0, 0, 0, 0, 0),
('飛雷之弦振', '弓', 0, 0, 0, 0, 0),
('若水', '弓', 0, 0, 0, 0, 0),
('獵人之徑', '弓', 0, 0, 0, 0, 0),
('最初的大魔術', '弓', 0, 0, 0, 0, 0);

INSERT INTO weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, W_crit_damage, W_crit_rate) VALUES 
('天空之脊', '長柄武器', 0, 0, 0, 0, 0),
('和璞鳶', '長柄武器', 0, 0, 0, 0, 0),
('息災', '長柄武器', 0, 0, 0, 0, 0),
('護摩之杖', '長柄武器', 0, 0, 0, 0, 0),
('薙草之稻光', '長柄武器', 0, 0, 0, 0, 0),
('貫虹之槊', '長柄武器', 0, 0, 0, 0, 0),
('赤沙之杖', '長柄武器', 0, 0, 0, 0, 0),
('赤月之形', '長柄武器', 674, 0, 0, 0, 0.221);


INSERT INTO weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, W_crit_damage, W_crit_rate) VALUES 
('天空之卷', '法器', 0, 0, 0, 0, 0),
('四風原典', '法器', 0, 0, 0, 0, 0),
('不滅月華', '法器', 0, 0, 0, 0, 0),
('塵世之鎖', '法器', 0, 0, 0, 0, 0),
('神樂之真意', '法器', 0, 0, 0, 0, 0),
('千夜浮夢', '法器', 0, 0, 0, 0, 0),
('圖萊杜拉的回憶', '法器', 0, 0, 0, 0, 0),
('碧落之瓏', '法器', 0, 0, 0, 0, 0),
('萬世流湧大典', '法器', 0, 0, 0, 0, 0),
('金流監督', '法器', 0, 0, 0, 0, 0),
('鶴鳴餘音', '法器', 0, 0, 0, 0, 0);



CREATE TABLE characters ( -- game characters
    -- c_id SERIAL,
    character_name VARCHAR(25) PRIMARY KEY,
    element VARCHAR(25) NOT NULL,
    weapon_type VARCHAR(25) NOT NULL,
    c_hp integer NOT NULL DEFAULT 0,
    c_atk integer NOT NULL DEFAULT 0,
    c_def integer NOT NULL DEFAULT 0,
    c_crit_damage FLOAT NOT NULL DEFAULT 0.5,
    c_crit_rate FLOAT NOT NULL DEFAULT 0,

    FOREIGN KEY (element) REFERENCES elements(element_type),
    FOREIGN KEY (weapon_type) REFERENCES weapon_types(weapon_type_name)
);


INSERT INTO characters (character_name, element, weapon_type, c_hp, c_atk, c_def, c_crit_damage, c_crit_rate) VALUES
('Klee', 'Pyro', '法器', 801, 24, 48, 0, 0.0),
('Yoimiya', 'Pyro', '弓', 792, 25, 48, 0, 0.0),
('Hu Tao', 'Pyro', '長柄武器', 1211, 8, 68, 0, 0.0),
('Diluc', 'Pyro', '雙手劍', 1011, 26, 61, 0, 0.0),
('Dehya', 'Pyro', '雙手劍', 1220, 21, 49, 0, 0.0),
('Lyney', 'Pyro', '弓', 858, 25, 42, 0, 5.0),
('Arlecchino', 'Pyro', '長柄武器', 1020, 27, 60, 0, 0.0),

('Amber', 'Pyro', '弓', 793, 19, 50, 0, 0.0),
('Thoma', 'Pyro', '長柄武器', 866, 17, 63, 0, 0.0),
('Yanfei', 'Pyro', '法器', 784, 20, 49, 0, 0.0),
('Bennett', 'Pyro', '單手劍', 1039, 16, 65, 0, 0.0),
('Xinyan', 'Pyro', '雙手劍', 939, 21, 67, 0, 0.0),
('Xiangling', 'Pyro', '長柄武器', 912, 19, 56, 0, 0),
('Chevreuse', 'Pyro', '長柄武器', 1003, 16, 51, 0, 0.0),
('Gaming', 'Pyro', '雙手劍', 957, 25, 59, 0, 0.0),
------------------------------------------------
('Mona', 'Hydro', '法器', 810, 22, 51, 0, 0.0),
('Tartaglia', 'Hydro', '弓', 1020, 23, 63, 0, 0.0),
('Sangonomiya Kokomi', 'Hydro', '法器', 1049, 18, 51, 0, 0.0),
('Kamisato Ayato', 'Hydro', '單手劍', 1068, 23, 60, 0, 0.0),
('Yelan', 'Hydro', '弓', 1125, 19, 43, 0, 0.0),
('Nilou', 'Hydro', '單手劍', 1182, 18, 57, 0, 0,0),
('Furina', 'Hydro', '單手劍', 1192, 19, 54, 0, 0.0),
('Neuvillette', 'Hydro', '法器', 1144, 16, 45, 0, 0.0),

('Barbara', 'Hydro', '法器', 821, 13, 56, 0, 0.0),
('Xingqiu', 'Hydro', '單手劍', 857, 17, 64, 0, 0.0),
('Candace', 'Hydro', '長柄武器', 912, 18, 57, 0, 0.0),
------------------------------------------------
('Jean', 'Anemo', '單手劍', 1144, 19, 60, 0, 0.0),
('Venti', 'Anemo', '弓', 820, 20, 52, 0, 0.0),
('Xiao', 'Anemo', '長柄武器', 991, 27, 62, 0, 0.0),
('Kaedehara Kazuha', 'Anemo', '單手劍', 1039, 23, 63, 0, 0),
('Wanderer', 'Anemo', '法器', 791, 26, 47, 0, 0.0),
('Xianyun', 'Anemo', '法器', 810, 26, 45, 0, 0.0),

('Sucrose', 'Anemo', '法器', 775, 14, 59, 0, 0.0),
('Shikanoin Heizou', 'Anemo', '法器', 894, 19, 57, 0, 0.0),
('Sayu', 'Anemo', '雙手劍', 994, 20, 62, 0, 0),
('Faruzan', 'Anemo', '法器', 802, 17, 53, 0, 0.0),
('Lynette', 'Anemo', '單手劍', 1039, 19, 60, 0, 0.0),
------------------------------------------------
('Yae Miko', 'Electro', '法器', 807, 26, 44, 0, 0.0),
('Keqing', 'Electro', '單手劍', 1020, 25, 62, 0, 0.0),
('Raiden Shogun', 'Electro', '長柄武器', 1005, 26, 61, 0, 0.0),
('Cyno', 'Electro', '長柄武器', 972, 25, 67, 0, 0.0),

('Lisa', 'Electro', '法器', 802, 19, 48, 0, 0),
('Fischl', 'Electro', '弓', 770, 20, 50, 0, 0.0),
('Razor', 'Electro', '雙手劍', 1003, 20, 63, 0, 0.0),
('Kujou Sara', 'Electro', '弓', 802, 16, 53, 0, 0.0),
('Beidou', 'Electro', '雙手劍', 1094, 19, 54, 0, 0.0),
('Kuki Shinobu', 'Electro', '單手劍', 1030, 18, 63, 0, 0.0),
('Dori', 'Electro', '雙手劍', 1039, 19, 61, 0, 0.0),
------------------------------------------------
('Qiqi', 'Cryo', '單手劍', 963, 22, 72, 0, 0.0),
('Eula', 'Cryo', '雙手劍', 1030, 27, 58, 0, 0.0),
('Ganyu', 'Cryo', '弓', 763, 26, 49, 0, 0.0),
('Shenhe', 'Cryo', '長柄武器', 1011, 24, 65, 0, 0.0),
('Kamisato Ayaka', 'Cryo', '單手劍', 1001, 27, 61, 0, 0.0),
('Wriothesley', 'Cryo', '法器', 1058, 24, 59, 0, 0.0),

('Kaeya', 'Cryo', '單手劍', 976, 19, 66, 0, 0.0),
('Rosaria', 'Cryo', '長柄武器', 1030, 20, 60, 0, 0.0),
('Diona', 'Cryo', '弓', 802, 18, 50, 0, 0.0),
('Chongyun', 'Cryo', '雙手劍', 921, 19, 54, 0, 0.0),
('Layla', 'Cryo', '單手劍', 930, 18, 55, 0, 0.0),
('Mika', 'Cryo', '法器', 1049, 19, 60, 0, 0.0),
('Freminet', 'Cryo', '雙手劍', 1012, 21, 59, 0, 0.0),
('Charlotte', 'Cryo', '法器', 903, 15, 46, 0, 0.0),
------------------------------------------------
('Zhongli', 'Geo', '長柄武器', 1144, 20, 57, 0, 0.0),
('Arataki Itto', 'Geo', '雙手劍', 1001, 18, 75, 0, 0.0),
('Albedo', 'Geo', '單手劍', 1030, 20, 68, 0, 0.0),
('Navia', 'Geo', '雙手劍', 985, 27, 62, 0, 0.0),
('Chiori', 'Geo', '單手劍', 890, 25, 74, 0, 0.0),

('Noelle', 'Geo', '雙手劍', 1012, 16, 67, 0, 0.0),
('Ningguang', 'Geo', '法器', 821, 18, 48, 0, 0.0),
('Gorou', 'Geo', '弓', 802, 15, 54, 0, 0.0),
('Yun Jin', 'Geo', '長柄武器', 894, 16, 62, 0, 0.0),
------------------------------------------------
('Tighnari', 'Dendro', '弓', 845, 42, 49, 0, 0.0),
('Nahida', 'Dendro', '法器', 807, 24, 49, 0, 0),
('Alhaitham', 'Dendro', '單手劍', 1039, 25, 61, 0, 0.0),
('Baizhu', 'Dendro', '法器', 1039, 15, 39, 0, 0.0),

('Collei', 'Dendro', '弓', 821, 17, 50, 0, 0.0),
('Yaoyao', 'Dendro', '長柄武器', 1030, 18, 63, 0, 0.0)
('Kaveh', 'Dendro', '雙手劍', 1003, 20, 63, 0, 0),
('Kirara', 'Cryo', '單手劍', 1021, 19, 46, 0, 0.0);



INSERT INTO elements (element_type) VALUES 
('Pyro'), -- 火
('Hydro'), -- 水
('Anemo'), -- 風
('Electro'), -- 雷
('Dendro'), -- 草
('Cryo'), -- 冰
('Geo'); -- 岩
