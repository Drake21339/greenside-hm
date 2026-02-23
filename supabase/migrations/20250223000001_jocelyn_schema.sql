-- Greenside HM / Jocelyn: tables and RLS for 8-year durable storage
-- Run in Supabase SQL Editor or via Supabase CLI

-- Profiles: extended user data (e.g. audio recording URLs)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  audio_urls jsonb not null default '[]',
  updated_at timestamptz not null default now()
);

-- Corpsman logs: MARCH-PAWS checklist state + 9-Line Medevac saves
create table if not exists public.corpsman_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_type text not null check (log_type in ('march_paws', 'medevac')),
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  unique(user_id, log_type)
);

-- Training stats: e.g. Muay Thai streak
create table if not exists public.training_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  stat_type text not null,
  value jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  unique(user_id, stat_type)
);

-- RLS
alter table public.profiles enable row level security;
alter table public.corpsman_logs enable row level security;
alter table public.training_stats enable row level security;

-- Profiles: user can read/update own row; insert on signup
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);

-- Corpsman logs: user can only access own rows
create policy "corpsman_logs_all_own" on public.corpsman_logs for all using (auth.uid() = user_id);

-- Training stats: user can only access own rows
create policy "training_stats_all_own" on public.training_stats for all using (auth.uid() = user_id);

-- Create profile on signup (trigger)
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Storage bucket: create jocelyn-audio (run in Dashboard → Storage → New bucket if not exists; set Public for direct playback).
-- RLS on storage.objects so users can only upload/read their own folder (path: {user_id}/filename).
create policy "jocelyn_audio_insert_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'jocelyn-audio' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "jocelyn_audio_select_own" on storage.objects for select to authenticated
  using (bucket_id = 'jocelyn-audio' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "jocelyn_audio_delete_own" on storage.objects for delete to authenticated
  using (bucket_id = 'jocelyn-audio' and (storage.foldername(name))[1] = auth.uid()::text);
