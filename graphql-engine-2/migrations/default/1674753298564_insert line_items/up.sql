insert into line_item (id, product_id)
select generate_series(1, 100), floor(random()*1000)+1;
