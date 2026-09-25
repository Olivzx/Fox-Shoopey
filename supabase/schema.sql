-- Fox Shoopey — Supabase schema (production blueprint)
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  store text not null,
  emoji text not null default '🛍️',
  price numeric(12,2) not null check (price >= 0),
  old_price numeric(12,2) not null check (old_price >= 0),
  discount integer not null default 0 check (discount >= 0 and discount <= 100),
  affiliate_url text not null,
  tags text[] not null default '{}',
  rating numeric(2,1) not null default 0,
  review_count integer not null default 0,
  featured boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.recommendations (
  id uuid primary key default gen_random_uuid(),
  author_name text not null,
  body text not null,
  rating integer not null check (rating between 1 and 5),
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role = 'admin'),
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.recommendations enable row level security;
alter table public.admin_profiles enable row level security;

create policy "public can read active products" on public.products
for select to anon, authenticated using (active = true);

create policy "authenticated admins can read products" on public.products
for select to authenticated
using (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));

create policy "authenticated admins can insert products" on public.products
for insert to authenticated
with check (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));

create policy "authenticated admins can update products" on public.products
for update to authenticated
using (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));

create policy "public can read approved recommendations" on public.recommendations
for select to anon, authenticated using (approved = true);

create policy "public can submit recommendation" on public.recommendations
for insert to anon, authenticated with check (approved = false);

create policy "admins can moderate recommendations" on public.recommendations
for all to authenticated
using (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_profiles a where a.user_id = auth.uid()));

create policy "admins can read own admin profile" on public.admin_profiles
for select to authenticated using (user_id = auth.uid());

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at before update on public.products
for each row execute function public.set_updated_at();