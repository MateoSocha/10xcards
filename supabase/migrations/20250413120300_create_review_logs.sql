-- Migration: Create review_logs table
-- Description: Creates the review_logs table for tracking flashcard reviews
-- Author: GitHub Copilot
-- Date: 2025-04-13

-- Create review_logs table
create table public.review_logs (
    id uuid primary key default uuid_generate_v4(),
    flashcard_id uuid not null unique references public.flashcards(id) on delete cascade,
    review_date timestamptz default current_timestamp,
    review_status varchar(20) not null check (review_status in ('accepted', 'edited', 'rejected')),
    rejection_reason text,
    original_front varchar(300),
    original_back varchar(500)
);

-- Create index
create index idx_review_logs_flashcard_id on public.review_logs(flashcard_id);

-- Enable row level security
alter table public.review_logs enable row level security;

-- Create policies for authenticated users
create policy "Users can view review logs of their flashcards"
    on public.review_logs for select
    to authenticated
    using (
        exists (
            select 1 from public.flashcards 
            where flashcards.id = review_logs.flashcard_id 
            and flashcards.user_id = auth.uid()
        )
    );

create policy "Users can create review logs for their flashcards"
    on public.review_logs for insert
    to authenticated
    with check (
        exists (
            select 1 from public.flashcards 
            where flashcards.id = review_logs.flashcard_id 
            and flashcards.user_id = auth.uid()
        )
    );

-- Grant access to authenticated users
grant all on public.review_logs to authenticated;

-- Drop all policies
drop policy if exists "Users can view review logs of their flashcards" on public.review_logs;
drop policy if exists "Users can create review logs for their flashcards" on public.review_logs;