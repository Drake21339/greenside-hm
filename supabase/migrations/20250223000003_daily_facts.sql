-- Daily Deck Log: one fact per user per day, persisted for history
-- Run in Supabase Dashboard → SQL Editor (or via supabase db push)

create table daily_facts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  fact_date date not null,
  fact_text text not null,
  source text not null check (source in ('wikipedia', 'backup')),
  created_at timestamp with time zone default now(),
  unique(user_id, fact_date)
);

create index daily_facts_user_date on daily_facts (user_id, fact_date desc);

alter table daily_facts enable row level security;

create policy "Users see only own daily facts"
  on daily_facts for all
  using (auth.uid() = user_id);
