CREATE OR REPLACE VIEW view_teams_before_backup AS
SELECT
    team_id,
    u_id,
    create_time,
    backup_time,
    team_name,
    member1,
	weapon1,
    member2,
	weapon2,
    member3,
	weapon3,
    member4,
	weapon4,
    expected_damage,
    highest_damage,
    lowest_damage
SELECT *
FROM team_backup
WHERE backup_time > '2024-06-09 00:00:00' and backup_time < '2024-06-012 00:00:00';


-- SELECT *
-- FROM view_teams_before_backup