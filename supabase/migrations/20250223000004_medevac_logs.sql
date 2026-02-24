-- Radio Stress Test: log every MEDEVAC drill attempt for analytics and personal best
create table medevac_logs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  scenario_id int not null,
  scenario_title text,
  time_limit_seconds int not null,
  finish_time_seconds numeric,
  passed boolean not null,
  created_at timestamp with time zone default now(),
  answers jsonb
);

create index medevac_logs_user_created on medevac_logs (user_id, created_at desc);

alter table medevac_logs enable row level security;

create policy "Users see only own medevac logs"
  on medevac_logs for all
  using (auth.uid() = user_id);
