
select * from athlete_events

select * from noc_regions

--How many Olympic games have been held

select count(distinct(sport) ) as Total_olympic_game
from athlete_events

--all olympic game played so far

select distinct(Year),Season,City
from athlete_events

--Total no of nation participating in each olympic games


	with all_countries as(
	select games,nr.region
	from 
	athlete_events ae
	join  noc_regions nr
	on ae.NOC=nr.NOC
	group by games, nr.region
	)
	select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;

--Which Year Saw the Highest and lowest no of country participating

 with yearly_partition as (

select distinct(Games),count(distinct(region)) as number_of_team_participated
from athlete_events ae
join noc_regions nr
	on ae.NOC=nr.NOC
group by Game
)
select Games,number_of_team_participated
from yearly_partition

--which nation has participated in all olympic Events


      with tot_games as
              (select count(distinct games) as total_games
              from athlete_events),
          countries as
              (select games, nr.region as country
              from athlete_events oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;

--Which sport was played in all summer olympics


with t1 as
          	(select count(distinct games) as total_games
          	from athlete_events where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from athlete_events where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games;

--Which Games were  played only once in the olympics

with t1 as

	(select distinct Sport,Games
	from athlete_events),
	t2 as 
	(select  Sport,count(1) as no_of_games
	from t1
	group by Sport)

	select t2.*,t1.Games
	from t2
	join t1 
	on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;

--Fetch the total no of sports played in each olympic games


with t1 as
      	(select distinct games, sport
      	from athlete_events),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;

--Fetch oldest athletes to win a gold medal

select Name as Athlete,Age,Medal,Games,Team,City,Event
from athlete_events
Where Medal='Gold'
Order by Age desc

--Find the Ratio of male and female athletes participated in all olympic games.

with male as 
(
select count(Sex) as Male_athlete
from athlete_events
where Sex='M'
),
Female as
(
select count(Sex) as Female_athlete
from athlete_events
where Sex='F'
),
Ratio_Male_Female
(
select Male_athlete/Female
from FeMale)

select * from Ratio_Male_Female
  

    with t1 as
        	(select sex, count(1) as cnt
        	from athlete_events
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;

-- Fetch the top 5 athletes who have won the most gold medals.


SELECT top 5 Name, COUNT(Medal) AS Total_Gold_Medals
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
order by Total_Gold_Medals desc

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT Name, COUNT(Medal) AS Total_Gold_Medals
FROM athlete_events
where Medal in('Gold','Silver','Bronze')
GROUP BY Name
order by Total_Gold_Medals desc

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with t1 as
(
select Top 5 region,count(1) as Total_medal 
from athlete_events as ae
join noc_regions as nr
	on ae.NOC=nr.NOC
where Medal in('Gold','Silver','Bronze') and Medal <> 'NA'
GROUP BY region,Team 
order by count(Medal) desc
),
t2 as
(
select* ,DENSE_RANK() over (order by Total_medal desc) as Rank
from t1
)
select * from t2

-- List down total gold, silver and bronze medals won by each country.


select nr.region as Country,
sum(case when Medal='Gold' then 1 else 0 end) as gold,
sum(case when Medal='Silver' then 1 else 0 end) as silver,
sum(case when Medal='Bronze' then 1 else 0 end) as bronze
from athlete_events as ae
join noc_regions as nr
on ae.Noc=nr.NOC
group by region
order by gold desc,silver desc,bronze desc

--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.


select Games,nr.region as Country,
sum(case when Medal='Gold' then 1 else 0 end) as gold,
sum(case when Medal='Silver' then 1 else 0 end) as silver,
sum(case when Medal='Bronze' then 1 else 0 end) as bronze
from athlete_events as ae
join noc_regions as nr
on ae.Noc=nr.NOC
group by Games,region
order by Games

--Identify which country won the most gold, most silver and most bronze medals in each olympic games. 


WITH MedalCounts AS (
    SELECT 
        ae.Games,
        nr.region AS Country,
        ae.Medal,
        COUNT(*) AS MedalCount,
        ROW_NUMBER() OVER (PARTITION BY ae.Games, ae.Medal ORDER BY COUNT(*) DESC) AS Rank
    FROM 
        athlete_events AS ae
    JOIN 
        noc_regions AS nr ON ae.NOC = nr.NOC
    WHERE 
        ae.Medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY 
        ae.Games, nr.region, ae.Medal
)
SELECT 
    Games,
    MAX(CASE WHEN Medal = 'Gold' THEN Country END) AS MostGold,
    MAX(CASE WHEN Medal = 'Silver' THEN Country END) AS MostSilver,
    MAX(CASE WHEN Medal = 'Bronze' THEN Country END) AS MostBronze
FROM 
    MedalCounts
WHERE 
    Rank = 1
GROUP BY 
    Games;


--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.



WITH MedalCounts AS (
    SELECT 
        ae.Games,
        nr.region AS Country,
        ae.Medal,
        COUNT(*) AS MedalCount,
        ROW_NUMBER() OVER (PARTITION BY ae.Games, ae.Medal ORDER BY COUNT(*) DESC) AS Rank
    FROM 
        athlete_events AS ae
    JOIN 
        noc_regions AS nr ON ae.NOC = nr.NOC
    WHERE 
        ae.Medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY 
        ae.Games, nr.region, ae.Medal
)
SELECT 
    Games,
    MAX(CASE WHEN Medal = 'Gold' THEN Country END) AS MostGold,
    MAX(CASE WHEN Medal = 'Silver' THEN Country END) AS MostSilver,
    MAX(CASE WHEN Medal = 'Bronze' THEN Country END) AS MostBronze
FROM 
    MedalCounts
WHERE 
    Rank = 1
GROUP BY 
    Games;

select games,NOC,count(1),
row_number() OVER (PARTITION BY Games, Medal ORDER BY COUNT(*) DESC) AS Rank
from athlete_events
group by games,NOC
order by 1,2

 



 SELECT 
    games,
    NOC,
    COUNT(*) AS medal_count,
    ROW_NUMBER() OVER (
        PARTITION BY games 
        ORDER BY COUNT(*) DESC
    ) AS Rank
FROM 
    athlete_events
WHERE 
    Medal IS NOT NULL
GROUP BY 
    games, NOC
ORDER BY 
    games, Rank;





