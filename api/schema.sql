create table users (
    id serial primary key,
    username text not null,
    password text not null
);

create table pokemon (
    id integer not null,
    user_id integer not null
        references users (id)
            on delete cascade,
    image_url text not null,
    name text not null,
    types text not null
);
