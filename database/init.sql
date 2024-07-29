-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table for spaces
CREATE TABLE spaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL
);

-- Table for users
CREATE TABLE users (
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
CREATE TABLE widgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    space_id UUID NOT NULL,
    user_id UUID NOT NULL,
    media_type media NOT NULL,
    media_file TEXT,
    FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

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

