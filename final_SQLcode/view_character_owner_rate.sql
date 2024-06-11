/*CREATE OR REPLACE VIEW view_character_owner_rate AS
 SELECT c.character_name,
    COALESCE(character_amount.ownership_count, 0::bigint) AS ownership_count,
    player_amount.total_player_count,
    COALESCE(character_amount.ownership_count, 0::bigint)::double precision / player_amount.total_player_count::double precision * 100::double precision AS ownership_rate
   FROM characters as c
     LEFT JOIN ( SELECT character_name, count(DISTINCT u_id) AS ownership_count
                 FROM player_characters pc
                 GROUP BY character_name ) as character_amount ON c.character_name::text = character_amount.character_name::text,
    ( SELECT count(DISTINCT u_id) AS total_player_count
   FROM players) as player_amount
  ORDER BY (COALESCE(character_amount.ownership_count, 0::bigint)::double precision / player_amount.total_player_count::double precision * 100::double precision) DESC, c.character_name;
*/
CREATE OR REPLACE VIEW view_character_owner_rate AS
 SELECT c.character_name,
    COALESCE(character_amount.ownership_count, 0::bigint) AS ownership_count,
    player_amount.total_player_count,
    COALESCE(character_amount.ownership_count, 0::bigint)::double precision / player_amount.total_player_count::double precision * 100::double precision AS ownership_rate
   FROM characters c
     LEFT JOIN ( SELECT pc.character_name, count(DISTINCT pc.u_id) AS ownership_count
                 FROM player_characters pc
                 GROUP BY pc.character_name ) character_amount ON c.character_name::text = character_amount.character_name::text,
    ( SELECT count(DISTINCT players.u_id) AS total_player_count
           FROM players) player_amount
  ORDER BY (COALESCE(character_amount.ownership_count, 0::bigint)::double precision / player_amount.total_player_count::double precision * 100::double precision) DESC, c.character_name;