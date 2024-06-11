CREATE OR REPLACE FUNCTION get_used_characters_rank(rank_n INTEGER)
RETURNS TABLE (
    u_id INTEGER,
    character_name TEXT,
    usage_count INTEGER,
    rank INTEGER
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'WITH combined_teams AS (
            SELECT u_id, member1::text AS character_name FROM team_backup WHERE member1 IS NOT NULL
            UNION ALL
            SELECT u_id, member2::text AS character_name FROM team_backup WHERE member2 IS NOT NULL
            UNION ALL
            SELECT u_id, member3::text AS character_name FROM team_backup WHERE member3 IS NOT NULL
            UNION ALL
            SELECT u_id, member4::text AS character_name FROM team_backup WHERE member4 IS NOT NULL
            UNION ALL
            SELECT u_id, member1::text AS character_name FROM team WHERE member1 IS NOT NULL
            UNION ALL
            SELECT u_id, member2::text AS character_name FROM team WHERE member2 IS NOT NULL
            UNION ALL
            SELECT u_id, member3::text AS character_name FROM team WHERE member3 IS NOT NULL
            UNION ALL
            SELECT u_id, member4::text AS character_name FROM team WHERE member4 IS NOT NULL
        ),
        character_usage_by_user AS (
            SELECT 
                u_id, 
                character_name,
                COUNT(*)::INTEGER AS usage_count
            FROM combined_teams
            WHERE character_name IS NOT NULL
            GROUP BY u_id, character_name
        )
        SELECT 
            u_id,
            character_name,
            usage_count,
            rank::INTEGER
        FROM (
            SELECT 
                u_id,
                character_name,
                usage_count,
                ROW_NUMBER() OVER (PARTITION BY u_id ORDER BY usage_count DESC) AS rank
            FROM character_usage_by_user
        ) AS ranked_usage
        WHERE rank <= %L
        ORDER BY u_id, rank;',
        rank_n
    );
END;
$$ LANGUAGE plpgsql;



SELECT * FROM get_used_characters_rank(10)
Where u_id = 100001
order by character_name;

