UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Книга')
WHERE sourname = 'Иванов Иван Иванович';
UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Монитор')
WHERE sourname = 'Петров Петр Петрович';
UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Гитара')
WHERE sourname = 'Иоганн Себастьян Бах';
