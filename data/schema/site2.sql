create table site (
    author text not null, 
    name text not null,
    description text not null,
    
    created integer not null,
    last_updated integer not null,
)

-- okay, what next ... oh, there are "resources" which are the target
-- of requests. Let us consider the resources we have initially:
-- content
--   pages
--   articles
--   blog entries
-- accounts
-- auth sessions

-- ---------------------------------------
-- ACCOUNTS
-- resource is 'users'
-- ---------------------------------------

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

-- ---------------------------------------
-- ENDPOINTS
-- ---------------------------------------

create table endpoints (
    name text not null,
    description text not null,

    primary key (name)
)

create table endpoint_instances (
    name text not null,
    arity integer not null,
    class text not null,
    description text not null,

    primary key (name, arity),
    foreign key (name) references endpoints (name)
)

-- ---------------------------------------
-- SESSIONS
-- resource 'auth_sessions'
-- ---------------------------------------

create table auth_sessions (
    id text not null, -- session id
    user_id text not null,
    created integer not null,
    expires integer not null,

    primary key (id),
    foreign key (user_id) references users (id)
)

-- ---------------------------------------
-- CONTENT
-- includes pages, articles, blog entries
-- ---------------------------------------

create table content_classes (
    class text not null,
    description text not null,

    primary key class
)

create table content_types (
    id text not null, 
    class text not null,
    description text not null,

    primary key content_type,
    foreign key (class) references content_classes (class)
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

-- TODO: insert here the base types, content items, etc.

