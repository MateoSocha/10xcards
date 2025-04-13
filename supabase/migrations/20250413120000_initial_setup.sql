-- Migration: Initial database setup
-- Description: Enables required extensions and sets up initial database configuration
-- Author: GitHub Copilot
-- Date: 2025-04-13

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- Set up storage for file uploads
create schema if not exists storage;

-- Enable RLS by default for all new tables
alter default privileges in schema public grant all on tables to postgres, anon, authenticated;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated;