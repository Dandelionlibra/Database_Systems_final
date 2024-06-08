CREATE OR REPLACE FUNCTION get_teams_before_backup(backuptime TIMESTAMP)
RETURNS TABLE (
    team_id INTEGER,
    u_id INTEGER,
    create_time TIMESTAMP,
    backup_time TIMESTAMP,
    team_name VARCHAR(25),
    member1 VARCHAR(25),
    member2 VARCHAR(25),
    member3 VARCHAR(25),
    member4 VARCHAR(25),
    expected_damage INTEGER,
    highest_damage INTEGER,
    lowest_damage INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tmp.team_id,
        tmp.u_id,
        tmp.create_time,
        tmp.backup_time,
        tmp.team_name,
        tmp.member1,
        tmp.member2,
        tmp.member3,
        tmp.member4,
        tmp.expected_damage,
        tmp.highest_damage,
        tmp.lowest_damage
    FROM
        team_backup as tmp
    WHERE
        tmp.backup_time < backuptime;
END; $$
LANGUAGE plpgsql;

SELECT * FROM get_teams_before_backup('2024-06-08 00:00:00');


