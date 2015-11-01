
create table item (
  id bigint primary key auto_increment,
  name varchar (255) unique not null,
  parent_id bigint null,
  foreign key item_parent_id (parent_id) references item (id)
) engine InnoDB;

create table instant_transfer (
  item_id bigint not null,
  amount bigint not null,
  at date not null,
  foreign key instant_transfer_item (item_id) references item (id)
) engine InnoDB;

create table monthly_transfer (
  item_id bigint not null,
  amount bigint not null,
  begin date not null,
  end date not null,
  foreign key instant_transfer_item (item_id) references item (id)
) engine InnoDB;

create table initial_balance (
  amount bigint
) engine InnoDB;
insert into initial_balance (amount) values (0);

create table actual_balance (
  at date not null,
  amount bigint not null
);

insert into actual_balance (at, amount) values ('2015-10-01', 110000);

commit;