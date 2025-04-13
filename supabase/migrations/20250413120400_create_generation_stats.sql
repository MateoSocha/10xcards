-- Migration: Create generation_stats table and triggers
-- Description: Creates the generation_stats table and related triggers for tracking flashcard statistics
-- Author: GitHub Copilot
-- Date: 2025-04-13

-- Create generation_stats table
create table public.generation_stats (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    manual_count integer default 0,
    ai_generated_count integer default 0,
    ai_accepted_count integer default 0,
    ai_rejected_count integer default 0,
    last_updated timestamptz default current_timestamp,
    constraint unique_user_stats unique (user_id)
);

-- Create index
create index idx_generation_stats_user_id on public.generation_stats(user_id);

-- Enable row level security
alter table public.generation_stats enable row level security;

-- Create policies for authenticated users
create policy "Users can view their own stats"
    on public.generation_stats for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can update their own stats"
    on public.generation_stats for update
    to authenticated
    using (auth.uid() = user_id);

-- Create trigger function for updating stats on flashcard creation
create or replace function update_generation_stats()
returns trigger as $$
begin
    insert into public.generation_stats (user_id, manual_count, ai_generated_count, ai_accepted_count, ai_rejected_count)
    values (new.user_id, 0, 0, 0, 0)
    on conflict (user_id) do nothing;

    if tg_op = 'INSERT' then
        if new.creation_type = 'manual' then
            update public.generation_stats
            set manual_count = manual_count + 1,
                last_updated = current_timestamp
            where user_id = new.user_id;
        elsif new.creation_type = 'ai' then
            update public.generation_stats
            set ai_generated_count = ai_generated_count + 1,
                last_updated = current_timestamp
            where user_id = new.user_id;
        end if;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger update_stats_on_flashcard_insert
    after insert on public.flashcards
    for each row
    execute function update_generation_stats();

-- Create trigger function for updating stats on review
create or replace function update_stats_on_review()
returns trigger as $$
begin
    if new.review_status = 'rejected' then
        update public.generation_stats
        set ai_rejected_count = ai_rejected_count + 1,
            last_updated = current_timestamp
        where user_id = (
            select user_id 
            from public.flashcards 
            where id = new.flashcard_id
        );
    elsif new.review_status in ('accepted', 'edited') then
        update public.generation_stats
        set ai_accepted_count = ai_accepted_count + 1,
            last_updated = current_timestamp
        where user_id = (
            select user_id 
            from public.flashcards 
            where id = new.flashcard_id
        );
    end if;
    
    return new;
end;
$$ language plpgsql;

create trigger update_stats_on_review_insert
    after insert on public.review_logs
    for each row
    execute function update_stats_on_review();

-- Grant access to authenticated users
grant all on public.generation_stats to authenticated;

-- Drop all policies
drop policy if exists "Users can view their own stats" on public.generation_stats;
drop policy if exists "Users can update their own stats" on public.generation_stats;