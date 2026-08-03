create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  focused_domain_id uuid,
  total_xp integer not null default 0,
  level integer not null default 1,
  streak_days integer not null default 0,
  weekly_capacity_hours integer not null default 5,
  reward_preference_summary text,
  last_active_date timestamptz,
  last_synced_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.life_domains (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  icon text not null,
  color text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  domain_id uuid references public.life_domains(id) on delete set null,
  title text not null,
  description text,
  type text not null,
  status text not null,
  progress double precision not null default 0,
  milestones jsonb,
  target_date timestamptz not null,
  start_date timestamptz not null default timezone('utc', now()),
  project_ids uuid[],
  target_value integer,
  current_value integer,
  unit text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  domain_id uuid references public.life_domains(id) on delete set null,
  name text not null,
  description text,
  status text not null,
  progress double precision not null default 0,
  color text not null,
  goal_ids uuid[],
  todo_ids uuid[],
  start_date timestamptz not null default timezone('utc', now()),
  end_date timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.todos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  domain_id uuid references public.life_domains(id) on delete set null,
  goal_id uuid references public.goals(id) on delete set null,
  project_id uuid references public.projects(id) on delete set null,
  title text not null,
  description text,
  priority text not null default 'medium',
  is_done boolean not null default false,
  due_date timestamptz,
  reminder_time timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.todo_schedule_slots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  todo_id uuid not null references public.todos(id) on delete cascade,
  scheduled_date date not null,
  scheduled_start timestamptz,
  scheduled_end timestamptz,
  status text not null default 'scheduled',
  source text not null default 'ai',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.focus_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  todo_id uuid references public.todos(id) on delete set null,
  duration integer not null,
  completed boolean not null default false,
  start_time timestamptz not null,
  end_time timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.daily_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  review_date date not null,
  what_done text,
  blockers text,
  top_priority_tomorrow text,
  xp_earned integer not null default 0,
  is_completed boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  unique(user_id, review_date)
);

create table if not exists public.xp_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source text not null,
  source_id uuid,
  domain_id uuid references public.life_domains(id) on delete set null,
  xp integer not null,
  description text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.praise_point_ledgers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source text not null,
  source_id uuid,
  delta integer not null,
  description text not null,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reward_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  description text,
  price_in_praise_points integer not null,
  tier text not null,
  is_system_template boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reward_template_id uuid not null references public.reward_templates(id) on delete cascade,
  price_in_praise_points integer not null,
  reward_todo_id uuid,
  status text not null default 'pending',
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reward_todos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reward_template_id uuid not null references public.reward_templates(id) on delete cascade,
  redemption_id uuid not null references public.reward_redemptions(id) on delete cascade,
  title text not null,
  description text,
  due_date timestamptz,
  status text not null default 'pending',
  completed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles enable row level security;
alter table public.life_domains enable row level security;
alter table public.goals enable row level security;
alter table public.projects enable row level security;
alter table public.todos enable row level security;
alter table public.todo_schedule_slots enable row level security;
alter table public.focus_sessions enable row level security;
alter table public.daily_reviews enable row level security;
alter table public.xp_events enable row level security;
alter table public.praise_point_ledgers enable row level security;
alter table public.reward_templates enable row level security;
alter table public.reward_redemptions enable row level security;
alter table public.reward_todos enable row level security;

create policy "profiles_own_rows" on public.profiles
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "life_domains_own_rows" on public.life_domains
  using (auth.uid() = user_id or user_id is null)
  with check (auth.uid() = user_id or user_id is null);

create policy "goals_own_rows" on public.goals
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "projects_own_rows" on public.projects
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "todos_own_rows" on public.todos
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "todo_schedule_slots_own_rows" on public.todo_schedule_slots
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "focus_sessions_own_rows" on public.focus_sessions
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "daily_reviews_own_rows" on public.daily_reviews
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "xp_events_own_rows" on public.xp_events
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "praise_point_ledgers_own_rows" on public.praise_point_ledgers
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "reward_templates_visible_rows" on public.reward_templates
  using (auth.uid() = user_id or is_system_template = true)
  with check (auth.uid() = user_id or is_system_template = true);

create policy "reward_redemptions_own_rows" on public.reward_redemptions
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "reward_todos_own_rows" on public.reward_todos
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

insert into public.reward_templates (title, description, price_in_praise_points, tier, is_system_template)
values
  ('散步 20 分钟', '立刻离开屏幕，轻量恢复一下。', 3, 'small', true),
  ('一顿喜欢的正餐', '阶段性庆祝，不赶时间地好好吃一顿。', 8, 'medium', true),
  ('半天完全放松', '为自己留出半天恢复和庆祝时间。', 15, 'large', true)
on conflict do nothing;
