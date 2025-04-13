-- Migration: Create flashcards table
-- Description: Creates the flashcards table and related policies
-- Author: GitHub Copilot
-- Date: 2025-04-13

-- Create flashcards table
create table public.flashcards (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    front varchar(300) not null,
    back varchar(500) not null,
    creation_type varchar(10) not null check (creation_type in ('ai', 'manual')),
    status varchar(20) not null check (status in ('draft', 'accepted', 'rejected')),
    ai_model varchar(50),
    created_at timestamptz default current_timestamp,
    updated_at timestamptz default current_timestamp,
    file_id uuid references public.files(id) on delete set null
);

-- Create indexes
create index idx_flashcards_user_id on public.flashcards(user_id);
create index idx_flashcards_status on public.flashcards(status);

-- Enable row level security
alter table public.flashcards enable row level security;

-- Create policies for authenticated users
create policy "Users can view their own flashcards"
    on public.flashcards for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can create their own flashcards"
    on public.flashcards for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own flashcards"
    on public.flashcards for update
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can delete their own flashcards"
    on public.flashcards for delete
    to authenticated
    using (auth.uid() = user_id);

-- Create updated_at trigger
create or replace function update_updated_at()
returns trigger as $$
begin
    new.updated_at = current_timestamp;
    return new;
end;
$$ language plpgsql;

create trigger update_flashcards_updated_at
    before update on public.flashcards
    for each row
    execute function update_updated_at();

-- Grant access to authenticated users
grant all on public.flashcards to authenticated;

-- Drop all policies
drop policy if exists "Users can view their own flashcards" on public.flashcards;
drop policy if exists "Users can create their own flashcards" on public.flashcards;
drop policy if exists "Users can update their own flashcards" on public.flashcards;
drop policy if exists "Users can delete their own flashcards" on public.flashcards;