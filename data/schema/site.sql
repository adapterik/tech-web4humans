create table system (
    created timestamp not null,
    last_updated timestamp not null,
    author varchar(100) not null, 
    name varchar(100) not null,
)


create table user_authorizations (
    id text not null,
    description text not null,

    primary key (id)
)

create table users (
    id text not null,
    name text not null,
    created integer not null,
    last_sign_in integer not null,

    primary key (id),
    foreign key (authorization_id) references user_authorizations (id)
)

create table users (
    id text not null,
    name text not null,
    created integer not null,
    last_sign_in integer not null,

    can_view integer not null,
    can_edit integer not null,
    can_manage integer not null,

    primary key (id)
)

create table users_auth (
    user_id text not null,
    password text not null,
    created integer not null,
    last_changed integer not null,

    primary key (user_id),
    foreign key (user_id) references users(id)
)

create table users_auth_log (
    id text not null,

    user_id text not null,
    entry text not null,
    created integer not null

)

create table auth_sessions (
    id text not null, -- session id
    user_id text not null,
    created integer not null,
    expires integer not null,

    primary key (id),
    foreign key (user_id) references users (id)
)

create table content_types (
    id text not null, 
    description text not null,

    primary key content_type,
)


create table content_status (
    id text not null,
    description text not null,

    primary key id,
)

create table content (
    id varchar(20) not null,
    title varchar(100) not null,
    content text not null,
    author varchar(100) not null,
    created timestamp not null,
    last_updated timestamp not null,
    content_type varchar(20) not null,

    primary key id,
)


create table content_status (
    content_id text not null,
    status_id text not null,
    created integer not null,

    primary key (content_id, status_id),
)

create table content_tags (
    content_id varchar(20) not null ,
    tag varchar(20) not null,
    description text null,

    primary key (content_id, tag)
)

insert into content_types (id, description) values ('page', 'A navigable endpoint'),
insert into content_types (id, description) values ('article', 'A published article'),
insert into content_types (id, description) values ('blog', 'A blog entry'),

insert into content_status (id, description) values ('draft', 'A content item not yet published'),
insert into content_status (id, description) values ('published', 'A content item that may appear in the site'),
insert into content_status (id, description) values ('retracted', 'A content item which was published, but now is no longer'),

-- insert into content (id, title, content, author, created, last_updated,  content_type)
-- VALUES
-- ('home', 
-- 'What is in a name? What is in this name?\n' ||
-- '\n' ||
--  'My first memory of "Adaptations" was that it captured my feeling that the web - and computers in general - should help us adapt to our environment. In other words, just as a species "adapts" to a change in environment through biological evolution, we adapt to changes in our environment through technological evolution.\n' ||
--  '\n'  ||
--  'And our small part of that is using the web to improve our lives in meaningful, beneficial ways.\n' ||
--  '' ||
-- 'Hmm, well that is all well and good, but it doesn\'t sound like a profitable approach.' ||
-- '\n' ||
-- So, while making money is the focus, we can adapt this approach to simply being user-focused in whatever role you have in web technology.

-- But ... when our focus changes to acting with meaning, we can return to our origins and begin again to create web tools, techology, information, experiences to help our fellow humans adapt to changes in our poltical, scientific, economic, social environment.

-- insert into content (id, title, content, author, created

create table openid_providers (
    id text not null,
    name text not null,
    client_id text not null,
    client_secret text not null,

    primary key (id)
);

insert into openid_providers (id, name, client_id, client_secret)
values ('github', 'GitHub', 'Ov23lirMG7HZueCTG6O6', 'c90bf129056d801967b75d5e619ff2989495cc8a')

create table user_openid_auth (
    user_id text not null,
    openid_provider_id text not null,

    provider_user_id text not null,

    primary key (user_id, openid_provider_id),

    foreign key (user_id) references users (id),
    foreign key (openid_provider_id) references openid_providers (id)

)