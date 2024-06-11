-- 計算每個角色被使用的次數
CREATE OR REPLACE VIEW view_character_usage_counts AS
SELECT 
    character_name,
    COUNT(*) AS usage_count
FROM (
    -- 當前隊伍的角色
    SELECT member1 AS character_name FROM team
    UNION ALL
    SELECT member2 AS character_name FROM team
    UNION ALL
    SELECT member3 AS character_name FROM team
    UNION ALL
    SELECT member4 AS character_name FROM team
    -- 備份隊伍的角色
    UNION ALL
    SELECT member1 AS character_name FROM team_backup
    UNION ALL
    SELECT member2 AS character_name FROM team_backup
    UNION ALL
    SELECT member3 AS character_name FROM team_backup
    UNION ALL
    SELECT member4 AS character_name FROM team_backup
) AS all_characters
WHERE character_name IS NOT NULL
GROUP BY character_name;


SELECT *
FROM view_character_usage_counts
WHERE 