CREATE OR REPLACE VIEW view_character_usage_count AS
SELECT 
    character_name,
    COUNT(*) AS usage_count
FROM (
    SELECT member1 AS character_name FROM team_backup
    UNION ALL
    SELECT member2 AS character_name FROM team_backup
    UNION ALL
    SELECT member3 AS character_name FROM team_backup
    UNION ALL
    SELECT member4 AS character_name FROM team_backup
) AS all_characters
WHERE character_name IS NOT NULL
GROUP BY character_name
ORDER BY usage_count DESC;

SELECT *
FROM team_backup
