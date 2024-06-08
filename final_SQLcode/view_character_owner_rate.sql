-- 計算角色持有數量
CREATE OR REPLACE VIEW view_count_character AS
SELECT
    pc.character_name,
    COUNT(DISTINCT pc.u_id) AS ownership_count
FROM
    player_characters pc
GROUP BY
    pc.character_name;

-- 計算玩家總數量
CREATE OR REPLACE VIEW view_count_player AS

SELECT
    COUNT(DISTINCT u_id) AS total_player_count
FROM
    players;

-- 計算角色持有率
CREATE OR REPLACE VIEW view_character_owner_rate AS
SELECT
    c.character_name,
    COALESCE(oc.ownership_count, 0) AS ownership_count,
    tpc.total_player_count,
    COALESCE(oc.ownership_count, 0)::float / tpc.total_player_count * 100 AS ownership_rate
FROM
    characters c
    LEFT JOIN view_count_character oc ON c.character_name = oc.character_name,
    view_count_player tpc
order by ownership_rate DESC, character_name;



SELECT * FROM view_count_character;
SELECT * FROM view_count_player;

SELECT *
FROM view_character_owner_rate
order by ownership_rate DESC, character_name;





