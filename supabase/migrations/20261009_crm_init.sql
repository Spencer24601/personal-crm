-- Applied to Supabase project lbejhxvcmjaiictddzdu (todo-app) on 2026-10-09 as migration "crm_init".
create table public.crm_contacts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  organization text,
  role text,
  how_met text,
  email text,
  phone text,
  notes text,
  follow_up_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.crm_interactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  contact_id uuid not null references public.crm_contacts(id) on delete cascade,
  happened_on date not null default current_date,
  kind text not null default 'meeting' check (kind in ('meeting','call','email','text','event','other')),
  summary text not null check (length(trim(summary)) > 0),
  next_step text,
  created_at timestamptz not null default now()
);

create index crm_contacts_owner_idx on public.crm_contacts(owner_id);
create index crm_interactions_owner_idx on public.crm_interactions(owner_id);
create index crm_interactions_contact_idx on public.crm_interactions(contact_id, happened_on desc);

create or replace function public.crm_touch_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger crm_contacts_touch before update on public.crm_contacts
  for each row execute function public.crm_touch_updated_at();

alter table public.crm_contacts enable row level security;
alter table public.crm_interactions enable row level security;

revoke all on public.crm_contacts, public.crm_interactions from anon;
grant select, insert, update, delete on public.crm_contacts, public.crm_interactions to authenticated;

create policy "own contacts" on public.crm_contacts
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "own interactions" on public.crm_interactions
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (
    owner_id = (select auth.uid())
    and exists (select 1 from public.crm_contacts c where c.id = contact_id and c.owner_id = (select auth.uid()))
  );
