-- Table for her medical and training checklists
-- Run this in Supabase Dashboard → SQL Editor

create table user_data (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  category text not null, -- 'medical', 'muay-thai', or 'vocal'
  content jsonb default '{}',  -- stores the actual checklist states
  updated_at timestamp with time zone default now(),
  unique(user_id, category)
);

-- Enable Security (RLS)
alter table user_data enable row level security;

create policy "Jocelyn can only see her own data"
on user_data for all
using (auth.uid() = user_id);
