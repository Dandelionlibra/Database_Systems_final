CREATE OR REPLACE VIEW view_team_damage_summary AS
SELECT
    t.team_id,
    t.u_id,
    t.team_name,
    t.member1,
    t.member2,
    t.member3,
    t.member4,
    COALESCE(
        (SELECT SUM(vce.character_expected_atk)
         FROM view_character_expected_atk vce
         WHERE vce.u_id = t.u_id AND vce.character_name IN (t.member1, t.member2, t.member3, t.member4)), 0
	) AS total_expected_damage,
    COALESCE(
        (SELECT SUM(vch.character_highest_atk)
         FROM view_character_highest_atk vch
         WHERE vch.u_id = t.u_id AND vch.character_name IN (t.member1, t.member2, t.member3, t.member4)), 0
	) AS total_highest_damage,
    COALESCE(
        (SELECT SUM(vca.character_atk)
         FROM view_character_atk vca
         WHERE vca.u_id = t.u_id AND vca.character_name IN (t.member1, t.member2, t.member3, t.member4)), 0
    ) AS total_damage
FROM
    team t
-- LEFT JOIN
--     view_character_expected_atk vce ON t.u_id = vce.u_id AND (t.member1 = vce.character_name OR t.member2 = vce.character_name OR t.member3 = vce.character_name OR t.member4 = vce.character_name)
-- LEFT JOIN
--     view_character_highest_atk vch ON t.u_id = vch.u_id AND (t.member1 = vch.character_name OR t.member2 = vch.character_name OR t.member3 = vch.character_name OR t.member4 = vch.character_name)
-- WHERE team_id =15
GROUP BY
    t.u_id, t.team_id, t.team_name, t.member1, t.member2, t.member3, t.member4


-- 查詢某個 team_id 的隊伍傷害
SELECT * FROM view_team_damage_summary WHERE team_id = $1;

-- 查詢某個 u_id 的玩家所有隊伍的傷害
SELECT * FROM view_team_damage_summary WHERE u_id = $1;