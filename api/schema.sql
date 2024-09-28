create table users (
    id serial primary key,
    username text not null,
    password text not null
);

create table pokemon (
    pokemon_id integer not null,
    user_id integer not null
        references users (id)
            on delete cascade
);
