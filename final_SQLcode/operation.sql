SELECT *
FROM characters;

SELECT *
FROM weapons
WHERE w_crit_rate > 0;

SELECT *
FROM player_characters
WHERE u_id = 100001

UPDATE player_characters
SET character_level = 95
WHERE u_id = 100000 AND character_name = 'Thoma';

UPDATE player_characters
SET character_name = 'Dilu'
WHERE u_id = 100000 AND character_name = 'Diluc';


SELECT *
FROM players
ORDER BY u_id;

SELECT *
FROM team
Order by u_id

SELECT *
FROM team_backup;

INSERT INTO players (player_name, players_level) VALUES ('jjjenny', 50);

UPDATE players
	SET players_level = 99
	Where player_name = 'jjjenny'

SELECT *
FROM player_characters
order by u_id
	
-- 插入角色資訊
INSERT INTO player_characters (u_id, character_name, character_level, character_weapon)VALUES
(100000, 'Hu Tao', 70, '飛雷')

(100000, 'Diluc', 1, '赤角石潰杵'),
(100000, 'Thoma', 1, '貫虹之槊');

INSERT INTO player_characters (u_id, character_name, character_level, character_weapon) VALUES 
(100003, 'Shenhe', -1, '飛雷之弦振'),
(100000, 'Yoimiya', FLOOR(RANDOM() * 90) + 1, '飛雷之弦振'),
(100001, 'Hu Tao', FLOOR(RANDOM() * 90) + 1, '護摩之杖'),
(100001, 'Diluc', FLOOR(RANDOM() * 90) + 1, '狼的末路'),
(100002, 'Dehya', FLOOR(RANDOM() * 90) + 1, '松籟響起之時'),
(100002, 'Lyney', FLOOR(RANDOM() * 90) + 1, '若水'),
(100003, 'Arlecchino', FLOOR(RANDOM() * 90) + 1, '赤月之形'),
(100003, 'Amber', FLOOR(RANDOM() * 90) + 1, '最初的大魔術'),
(100009, 'Dehya', FLOOR(RANDOM() * 90) + 1, '赤角石潰杵'),
(100010, 'Lyney', FLOOR(RANDOM() * 90) + 1, '若水'),
(100010, 'Arlecchino', FLOOR(RANDOM() * 90) + 1, '赤月之形');




UPDATE player_characters SET character_weapon = '若水' WHERE u_id = 100000 AND character_name = 'Thoma';

UPDATE players SET u_id = 1 WHERE u_id = 100000;


-- 創建新隊伍
INSERT INTO team (u_id, team_name, member1, member2, member3)
VALUES (100000, 'Team1', 'Wriothesley', 'Diluc', 'Furina');



INSERT INTO team (u_id, team_name, member2)
VALUES (100000, 'Team2', 'Thoma');

SELECT * 
FROM view_show_player_character_data
ORDER BY character_expected_atk DESC; -- DESC:遞減排序, ASC:遞增排序

SELECT *
FROM view_character_hp as v_hp
	NATURAL JOIN view_character_def as v_def-- ON v_hp.character_name::text = v_def.character_name::text
	NATURAL JOIN view_character_atk as v_atk-- ON v_hp.character_name::text = v_atk.character_name::text
	NATURAL JOIN view_character_highest_atk as v_highest_atk-- ON v_hp.character_name::text = v_def.character_name::text
	NATURAL JOIN view_character_expected_atk as v_expected_atk-- ON v_hp.character_name::text = v_def.character_name::text

-- WHERE v_hp.u_id = 100000;

INSERT INTO players (player_name, players_level) VALUES 
('bubble', 65)
-- ('泡泡瑪莉', FLOOR(RANDOM() * 60) + 1),
-- ('skull panda', FLOOR(RANDOM() * 60) + 1),
-- ('', FLOOR(RANDOM() * 60) + 1);

	
UPDATE players SET u_id = 100009 WHERE u_id = 100003
SELECT *
FROM players

UPDATE player_characters SET character_level = 10 WHERE u_id = 100003 AND character_name = 'Shenhe';


SELECT *
FROM view_character_owner_rate

SELECT *
FROM view_show_player_character_data
-- FROM view_character_expected_atk
WHERE u_id = 100003 and (character_name = 'Kamisato Ayaka' or character_name = 'Shenhe' or character_name = 'Layla' or character_name = 'Sangonomiya Kokomi')

INSERT INTO team (u_id, team_name, member1, member2, member3, member4) VALUES
(100004, '我不會想名字', 'Jean', 'Keqing', 'Yaoyao', 'Zhongli')

INSERT INTO team (u_id, team_name, member1, member2, member3, member4) VALUES
(100004, 'da da da', 'Chongyun', 'Xianyun', 'Rosaria', 'Jean')

SELECT *
FROM view_team_damage_summary
WHERE u_id = 100004


SELECT *
FROM team_backup
WHERE backup_time > '2024-06-09 00:00:00' and backup_time < '2024-06-012 00:00:00';

	
UPDATE players
	SET u_id = 99
	Where player_name = 'jjjenny'


INSERT INTO players (u_id, player_name, players_level) VALUES (45, 'jjjenny', 50);
INSERT INTO players (player_name, players_level) VALUES ('Libra', 45);

SELECT *
FROM players

SELECT *
FROM characters

SELECT *
FROM player_characters
WHERE u_id = 100004
	
SELECT *
FROM team
order by u_id, create_time
	
SELECT *
FROM team_backup

UPDATE player_characters
SET character_level = 6
WHERE u_id = 100000 and character_name = 'Sangonomiya Kokomi'

SELECT *
FROM view_show_player_character_data
WHERE u_id = 100000 and character_name = 'Sangonomiya Kokomi'
	
SELECT *
FROM view_show_player_character_data
	natural join player_characters
order by u_id, character_name
	
INSERT INTO player_characters (u_id, character_name, character_level, character_weapon) VALUES 
-- (100003, 'Candace', 20, '4')
(100003, 'Kaveh', 880, '風鷹劍')
	

INSERT INTO team (u_id, team_name, member1, member2, member3, member4) VALUES
(100003, 'test team', 'Collei', 'Keqing', 'Layla', 'Sangonomiya Kokomi'),
(100002, 'Team2', 'Candace', NULL, 'Yanfei', NULL),
(100004, 'Team3', 'Keqing', 'Yaoyao', 'Baizhu', NULL),
(100003, 'Team4', 'Noelle', 'Kamisato Ayaka', NULL, NULL),
(100004, 'Team5', 'Rosaria', 'Amber', NULL, NULL),
(100003, 'Team', 'Sangonomiya Kokomi', 'Shenhe', NULL, 'Noelle'),
(100003, 'Team2', 'Kamisato Ayaka', 'Noelle', NULL, NULL),
(100001, 'Team3', 'Kaveh', 'Diluc', NULL, NULL),
(100001, 'Team4', 'Mona', 'Chiori', NULL, NULL),
(100005, 'Team4', 'Raiden Shogun', 'Xingqiu', NULL, 'Qiqi'),
(100005, 'Team4', 'Collei', 'Yae Miko', NULL, NULL),
(100003, 'Team5', 'Dehya', 'Chevreuse', NULL, NULL);



-- (備份隊伍ID，玩家ID)
SELECT create_team_from_backup(21, 100004);
INSERT INTO player_characters (u_id, character_name, character_weapon)
VALUES (100001, 'Kamisato Ayaka', NULL );

-- (備份隊伍ID，玩家ID)
SELECT create_team_from_backup(6, 100007);

---------------------------------------------------------------------
SELECT *
FROM player_characters
WHERE u_id = 100007 and (character_name = 'Sangonomiya Kokomi' or character_name = 'Shenhe' or character_name = 'Noelle')

INSERT INTO player_characters (u_id, character_name, character_level, character_weapon) VALUES 
(100007, 'Shenhe', 23, '息災'),
(100007, 'Noelle', 15, '狼的末路')
	
Where u_id = 100004
order by u_id
	
 --team_id, member1, member2, member3, member4, weapon1, weapon2, weapon3, weapon4
SELECT team_id, member1, member2, member3, member4, weapon1, weapon2, weapon3, weapon4
FROM team_backup
WHERE 'Noelle' IN (member1, member2, member3, member4);
-- Where u_id = 100004
---------------------------------------------------------------------
SELECT *
FROM team
Where u_id = 100004
order by team_id

SELECT *
-- FROM view_show_player_character_data
FROM view_team_damage_summary
Where u_id = 100004
order by u_id
	
SELECT *
FROM team_backup
Where u_id = 100004
	
UPDATE player_characters
SET character_weapon = '和璞鳶'
WHERE u_id = 100004 and character_name = 'Yaoyao'

UPDATE player_characters
SET character_weapon = '碧落之瓏'
WHERE u_id = 100004 and character_name = 'Baizhu'
	
SELECT *
FROM player_characters
-- WHERE character_name = 'Noelle'
ORDER by u_id

SELECT *
FROM view_show_player_character_data
ORDER by u_id



