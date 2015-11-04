
delete from item1;

-- groups
insert
into item1 (id, name, parent_id, type)
  select id, name, parent_id, 'GROUP' from item i
  where (select count(*) from instant_transfer t where t.item_id = i.id) != 1;

-- instant transfers
insert
into item1 (name, parent_id, amount, at, type)
  select i.name, i.id, t.amount, t.at,
    case when t.at < date(now()) then 'INSTANT_ACTUAL' else 'INSTANT_PLANNED' end
  from instant_transfer t
    inner join item i on t.item_id = i.id
  where (select count(*) from instant_transfer t where t.item_id = i.id) != 1;
;
-- single child instant transfers
insert
into item1 (id, name, parent_id, amount, at, type)
  select i.id, i.name, i.parent_id, t.amount, t.at,
    case when t.at < date(now()) then 'INSTANT_ACTUAL' else 'INSTANT_PLANNED' end
  from instant_transfer t
    inner join item i on t.item_id = i.id
  where (select count(*) from instant_transfer t where t.item_id = i.id) = 1
;

-- montly transfers from past and present
insert
into item1 (name, parent_id, amount, at, type)
  select i.name, i.id, t.amount, d._date, 'INSTANT_ACTUAL'
  from monthly_transfer t
    inner join item i on t.item_id = i.id
    cross join (
                 select date_add(makedate(y.x, 1), interval m.x-1 month) _date
                 from (
                        select 2014 x union select 2015 union select 2016) y
                   cross join (
                                select 1 x union select 2 union select 3 union select 4 union select 5 union select 6 union
                                select 7 union select 8 union select 9 union select 10 union select 11 union select 12
                              ) m
               ) d
  where d._date <= date(now())
        and d._date between t.begin and t.end
;

-- montly transfers from future
insert
into item1 (name, parent_id, amount, period_begin, period_end, type)
  select i.name, i.id, t.amount, greatest(t.begin, date_add(makedate(year(now()), 1), interval month(now()) month)), t.end, 'MONTHLY_PLANNED'
  from monthly_transfer t
    inner join item i on t.item_id = i.id
  where year(t.end) > year(now()) && month(t.end) > month(now())
;
