CREATE OR REPLACE VIEW view_most_used_character_by_user AS
WITH combined_teams AS (
    SELECT u_id, member1 AS character_name FROM team_backup WHERE member1 IS NOT NULL
    UNION ALL
    SELECT u_id, member2 AS character_name FROM team_backup WHERE member2 IS NOT NULL
    UNION ALL
    SELECT u_id, member3 AS character_name FROM team_backup WHERE member3 IS NOT NULL
    UNION ALL
    SELECT u_id, member4 AS character_name FROM team_backup WHERE member4 IS NOT NULL
    UNION ALL
    SELECT u_id, member1 AS character_name FROM team WHERE member1 IS NOT NULL
    UNION ALL
    SELECT u_id, member2 AS character_name FROM team WHERE member2 IS NOT NULL
    UNION ALL
    SELECT u_id, member3 AS character_name FROM team WHERE member3 IS NOT NULL
    UNION ALL
    SELECT u_id, member4 AS character_name FROM team WHERE member4 IS NOT NULL
),
character_usage_by_user AS (
    SELECT 
        u_id, 
        character_name,
        COUNT(*) AS usage_count
    FROM combined_teams
    WHERE character_name IS NOT NULL
    GROUP BY u_id, character_name
)
SELECT 
    u_id,
    character_name,
    usage_count
FROM (
    SELECT 
        u_id,
        character_name,
        usage_count,
        ROW_NUMBER() OVER (PARTITION BY u_id ORDER BY usage_count DESC) AS rn
    FROM character_usage_by_user
) AS ranked_usage
WHERE rn = 1
ORDER by u_id ASC, usage_count DESC
