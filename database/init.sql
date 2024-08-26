-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

<<<<<<< HEAD
CREATE DATABASE twocents WITH TEMPLATE twocents OWNER admin;

-- Table for spaces
CREATE TABLE IF NOT EXISTS spaces (
=======
-- Table for spaces
CREATE TABLE spaces (
>>>>>>> 7343c76 (Added init.sql)
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL
);

-- Table for users
<<<<<<< HEAD
CREATE TABLE IF NOT EXISTS users (
=======
CREATE TABLE users (
>>>>>>> 7343c76 (Added init.sql)
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phonenumber VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL
);

-- Enum for widget media types
CREATE TYPE media AS ENUM ('Video', 'Image', 'Poll', 'Todo', 'Map', 'Text');

-- Table for widgets
<<<<<<< HEAD
CREATE TABLE IF NOT EXISTS widgets (
=======
CREATE TABLE widgets (
>>>>>>> 7343c76 (Added init.sql)
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    space_id UUID NOT NULL,
    user_id UUID NOT NULL,
    media_type media NOT NULL,
    media_file TEXT,
    FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

<<<<<<< HEAD
CREATE TYPE IF NOT EXISTS POLL_OPTION AS (
    user_ids UUID[],
    vote_count INTEGER,
    description TEXT
);

-- Table for Poll media type
CREATE TABLE IF NOT EXISTS polls (
    id UUID PRIMARY KEY NOT NULL,
    question TEXT NOT NULL,
    options POLL_OPTION[] NOT NULL,
    FOREIGN KEY (id) REFERENCES widgets(id) ON DELETE CASCADE
);


CREATE TYPE TASK AS (
    user_id UUID NOT NULL,
    description TEXT NOT NULL,
    completed BOOLEAN
);

-- Table for Todo media type
CREATE TABLE IF NOT EXISTS todos (
    id UUID PRIMARY KEY,
    tasks TASK[],
    FOREIGN KEY (id) REFERENCES widgets(id) ON DELETE CASCADE
);

CREATE TYPE LOCATION AS (
  longitude FLOAT,
  latitude FLOAT,
);

-- Table for Map media type
CREATE TABLE IF NOT EXISTS maps (
    id UUID PRIMARY KEY NOT NULL,
    location LOCATION NOT NULL,
=======
-- Table for Poll media type
CREATE TABLE polls (
    id UUID PRIMARY KEY,
    question TEXT NOT NULL,
    options TEXT[] NOT NULL,
    FOREIGN KEY (id) REFERENCES widgets(id) ON DELETE CASCADE
);

-- Table for Todo media type
CREATE TABLE todos (
    id UUID PRIMARY KEY,
    task TEXT NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id) REFERENCES widgets(id) ON DELETE CASCADE
);

-- Table for Map media type
CREATE TABLE maps (
    id UUID PRIMARY KEY,
    location TEXT NOT NULL,
>>>>>>> 7343c76 (Added init.sql)
    description TEXT,
    FOREIGN KEY (id) REFERENCES widgets(id) ON DELETE CASCADE
);

-- Relationship table for space members
CREATE TABLE space_members (
    space_id UUID NOT NULL,
    user_id UUID NOT NULL,
    PRIMARY KEY (space_id, user_id),
    FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
<<<<<<< HEAD
=======

>>>>>>> 7343c76 (Added init.sql)
