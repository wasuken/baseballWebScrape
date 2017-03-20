create table player_year_scores(
       id integer primary key,
       year varchar(40),
       term_name varchar(40),
       defense_rate real,
       game_number integer,
       win integer,
       lose integer,
       hold_save integer,
       pitching_time varchar(80),
       hit integer,
       homerun integer,
       strikeout integer,
       four integer,
       dead integer,
       point integer,
       create_at,
       update_at
);
