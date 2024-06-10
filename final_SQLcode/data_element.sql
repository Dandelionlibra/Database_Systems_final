
-- 玩家擁有許多角色，玩家擁有的角色不能重複
-- 每個角色都對應一個元素，元素有七種，分別是Pyro、Hydro、Anemo、Electro、Dendro、Cryo、Geo
-- 遊戲庫中的武器大家都可以自由裝備
-- 每個武器都對應一個武器類型，武器類型有五種，分別是單手劍、雙手劍、弓、長柄武器、法器
-- 玩家可以將武器裝備到自己擁有的角色上，但角色不一定要裝備武器，
-- 玩家要從自己擁有的角色中選至少一個，最多四個角色組成一個隊伍，
-- 組成隊伍後需要計算，並記錄這個隊伍的角色組成、期望戰力、最高戰力、最低戰力


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