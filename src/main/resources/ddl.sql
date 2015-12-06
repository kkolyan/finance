
create table item (
  id bigint primary key auto_increment,
  name varchar (255) unique not null,
  parent_id bigint null,
  foreign key item_parent_id (parent_id) references item (id)
) engine InnoDB;

create table instant_transfer (
  id bigint primary key auto_increment,
  item_id bigint not null,
  amount bigint not null,
  at date not null,
  foreign key instant_transfer_item (item_id) references item (id)
) engine InnoDB;

create table monthly_transfer (
  id bigint primary key auto_increment,
  item_id bigint not null,
  amount bigint not null,
  begin date not null,
  end date not null,
  foreign key instant_transfer_item (item_id) references item (id)
) engine InnoDB;


create table actual_balance (
  at date primary key,
  amount bigint not null,
  owner_id bigint,
  foreign key actual_balance_owner (owner_id) references user (id)
);

insert into actual_balance (at, amount) values ('2015-10-01', 110000);
commit;


create table item1 (
  id bigint primary key auto_increment,
  name varchar (255) not null,
  parent_id bigint null,
  foreign key item1_parent_id (parent_id) references item1 (id),
  amount bigint null,
  at date null,
  period_begin date null,
  period_end date null,
  type enum ('GROUP', 'INSTANT_PLANNED', 'INSTANT_ACTUAL', 'MONTHLY_PLANNED') not null,
  owner_id bigint,
  foreign key actual_balance_owner (owner_id) references user (id)
);

drop table user;
create table user (
  id bigint primary key auto_increment,
  name varchar (255) not null,
  description text,
  pwd_hash text not null
);

drop table invitation;
create table invitation (
  code varchar (255) primary key,
  description text,
  invited_at timestamp not null default now(),
  registered_at timestamp null
);