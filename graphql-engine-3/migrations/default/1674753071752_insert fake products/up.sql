insert into product (id, name)
select generate_series(1, 1000), md5(random()::text);
