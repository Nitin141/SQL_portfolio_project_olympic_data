use project1

select * from athletes

select distinct team from athletes order by team asc--id,name sex,height,weight,team

select * from athlete_events

--1 which team has won the maximum gold medals over the years.

with cte as (
select distinct team,event from athlete_events e
inner join athletes a
on a.id = e.athlete_id
where medal = 'Gold')
select top 1 team,count(event) as medals from cte group by team order by medals desc



--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte as (
select distinct team,year, event as medal from athlete_events e
inner join athletes a
on e.athlete_id = a.id
where medal = 'Silver'),
final as (select team,year,count(medal) as year_sum from cte group by team,year),
rank_tab as (select team,year,year_sum,rank() over (partition by team order by year_sum desc) ranks from final)
select team,max(case when ranks=1 then year end) as year_of_max_silver,sum(year_sum) as total_silver_medals from rank_tab group by team



--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

with cte as (
select name,medal,count(medal) as medal_won from athletes a 
inner join athlete_events e on
a.id=e.athlete_id
group by name,medal),
final as (select *,sum(medal_won) over(partition by name order by medal) as tlt_cnt from cte where medal not in ('NA'))
select * from final where medal='Gold' and medal_won=tlt_cnt order by tlt_cnt desc


--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as 
(select name,year,count(medal) medal_cnt from athletes a
inner join athlete_events e on a.id = e.athlete_id
where medal = 'Gold' group by name,year),
final as (select name,year,medal_cnt,max(medal_cnt) over(partition by year) as max_cnt from cte)
select year,STRING_AGG(name,',') as names from final where medal_cnt = max_cnt group by year



--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

select * from athletes

select * from athlete_events

with cte as (
select year,sport,medal,rank() over (partition by medal order by year) as ranks from athletes a 
inner join athlete_events e on a.id = e.athlete_id where team = 'India' and medal not in ('NA'))
select distinct year,sport,medal from cte where ranks = 1


--6 find players who won gold medal in summer and winter olympics both.

select name from athletes a
inner join athlete_events e on a.id = e.athlete_id where medal = 'Gold' 
group by name having count(distinct season)>1




--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.


select name,year from athletes a
inner join athlete_events e on a.id = e.athlete_id where medal!= 'NA' group by name,year
having count(distinct medal) = 3




--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte as (
select distinct name,event,year,lag(year,1,0) over(partition by name,event order by year) as prev_year,
lead(year,1,0) over(partition by name,event order by year) as next_year from athletes a
inner join athlete_events e on a.id = e.athlete_id where medal = 'Gold' and year >=2000 and season = 'Summer')
select name,event from cte where year=prev_year + 4 and year = next_year - 4 










