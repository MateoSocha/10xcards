-- Migration: Create files table
-- Description: Creates the files table for storing uploaded document metadata
-- Author: GitHub Copilot
-- Date: 2025-04-13

-- Create files table
create table public.files (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    filename varchar(255) not null,
    file_type varchar(10) not null check (file_type in ('pdf', 'txt', 'md')),
    size_bytes integer not null check (size_bytes <= 10485760),
    created_at timestamptz default current_timestamp,
    status varchar(20) not null check (status in ('processing', 'processed', 'error')),
    error_message text
);

-- Create index for faster lookups by user_id
create index idx_files_user_id on public.files(user_id);

-- Enable row level security
alter table public.files enable row level security;

-- Create policies for authenticated users
create policy "Users can view their own files"
    on public.files for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can upload their own files"
    on public.files for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can delete their own files"
    on public.files for delete
    to authenticated
    using (auth.uid() = user_id);

-- Grant access to authenticated users
grant all on public.files to authenticated;

-- Drop all policies
drop policy if exists "Users can view their own files" on public.files;
drop policy if exists "Users can upload their own files" on public.files;
drop policy if exists "Users can delete their own files" on public.files;