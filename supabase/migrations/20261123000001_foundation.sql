-- Foundation schema for Ceylon Trails.
create extension if not exists "pgcrypto";

create type public.user_role as enum ('customer', 'admin');
create type public.booking_status as enum (
  'draft',
  'pending',
  'confirmed',
  'cancelled',
  'completed'
);
create type public.payment_status as enum (
  'pending',
  'paid',
  'failed',
  'refunded',
  'expired'
);
create type public.vehicle_type as enum ('car', 'suv', 'van', 'mini-bus', 'bus');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text,
  last_name text,
  phone text,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.destinations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  region text,
  image_url text,
  latitude numeric(9,6),
  longitude numeric(9,6),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.packages (
  id uuid primary key default gen_random_uuid(),
  destination_id uuid references public.destinations(id) on delete set null,
  title text not null,
  slug text not null unique,
  summary text,
  description text,
  duration_days integer not null check (duration_days > 0),
  base_price_lkr bigint not null default 0 check (base_price_lkr >= 0),
  max_guests integer not null default 1 check (max_guests > 0),
  is_featured boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.package_days (
  id uuid primary key default gen_random_uuid(),
  package_id uuid not null references public.packages(id) on delete cascade,
  day_number integer not null check (day_number > 0),
  title text not null,
  description text,
  created_at timestamptz not null default now(),
  unique (package_id, day_number)
);

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type public.vehicle_type not null unique,
  seat_capacity integer not null check (seat_capacity > 0),
  luggage_capacity integer not null check (luggage_capacity >= 0),
  rate_per_km_lkr integer not null check (rate_per_km_lkr >= 0),
  is_active boolean not null default true,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.drivers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique references public.profiles(id) on delete set null,
  name text not null,
  phone text,
  license_number text,
  languages text[] not null default '{}',
  is_active boolean not null default true,
  rating numeric(2,1) check (rating is null or (rating >= 0 and rating <= 5)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users(id) on delete restrict,
  package_id uuid references public.packages(id) on delete set null,
  vehicle_id uuid references public.vehicles(id) on delete set null,
  driver_id uuid references public.drivers(id) on delete set null,
  reference text not null unique,
  status public.booking_status not null default 'draft',
  start_date date,
  end_date date,
  guest_count integer not null default 1 check (guest_count > 0),
  total_lkr bigint not null default 0 check (total_lkr >= 0),
  deposit_lkr bigint not null default 0 check (deposit_lkr >= 0),
  customer_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint valid_booking_dates check (end_date is null or start_date is null or end_date >= start_date)
);

create table public.booking_days (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  day_number integer not null check (day_number > 0),
  date date,
  title text,
  notes text,
  created_at timestamptz not null default now(),
  unique (booking_id, day_number)
);

create table public.booking_places (
  id uuid primary key default gen_random_uuid(),
  booking_day_id uuid not null references public.booking_days(id) on delete cascade,
  destination_id uuid references public.destinations(id) on delete set null,
  name text not null,
  latitude numeric(9,6),
  longitude numeric(9,6),
  visit_time time,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now()
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  provider text not null default 'payhere',
  provider_order_id text unique,
  amount_lkr bigint not null check (amount_lkr > 0),
  status public.payment_status not null default 'pending',
  currency text not null default 'LKR',
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.settings (
  key text primary key,
  value jsonb not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users(id) on delete cascade,
  booking_id uuid references public.bookings(id) on delete set null,
  destination_id uuid references public.destinations(id) on delete set null,
  rating integer not null check (rating between 1 and 5),
  title text,
  body text,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, first_name, last_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.destinations enable row level security;
alter table public.packages enable row level security;
alter table public.package_days enable row level security;
alter table public.vehicles enable row level security;
alter table public.drivers enable row level security;
alter table public.bookings enable row level security;
alter table public.booking_days enable row level security;
alter table public.booking_places enable row level security;
alter table public.payments enable row level security;
alter table public.settings enable row level security;
alter table public.reviews enable row level security;

-- Profiles
create policy "Users can read own profile"
on public.profiles for select to authenticated
using (id = auth.uid());
create policy "Users can update own profile"
on public.profiles for update to authenticated
using (id = auth.uid()) with check (id = auth.uid());
create policy "Admins manage profiles"
on public.profiles for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Public catalog
create policy "Public can read active destinations"
on public.destinations for select
using (is_active = true);
create policy "Admins manage destinations"
on public.destinations for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Public can read active packages"
on public.packages for select
using (is_active = true);
create policy "Admins manage packages"
on public.packages for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Public can read package days"
on public.package_days for select
using (
  exists (
    select 1 from public.packages
    where packages.id = package_days.package_id and packages.is_active = true
  )
);
create policy "Admins manage package days"
on public.package_days for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Public can read active vehicles"
on public.vehicles for select
using (is_active = true);
create policy "Admins manage vehicles"
on public.vehicles for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Public can read active drivers"
on public.drivers for select
using (is_active = true);
create policy "Admins manage drivers"
on public.drivers for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Public settings are readable for pricing and launch configuration.
create policy "Public can read settings"
on public.settings for select
using (true);
create policy "Admins manage settings"
on public.settings for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Public reviews
create policy "Public can read published reviews"
on public.reviews for select
using (is_published = true);
create policy "Customers can create reviews"
on public.reviews for insert to authenticated
with check (customer_id = auth.uid());
create policy "Customers can update own reviews"
on public.reviews for update to authenticated
using (customer_id = auth.uid()) with check (customer_id = auth.uid());
create policy "Admins manage reviews"
on public.reviews for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Customer booking access
create policy "Customers can read own bookings"
on public.bookings for select to authenticated
using (customer_id = auth.uid());
create policy "Customers can create own bookings"
on public.bookings for insert to authenticated
with check (customer_id = auth.uid());
create policy "Customers can update own drafts"
on public.bookings for update to authenticated
using (customer_id = auth.uid() and status = 'draft')
with check (customer_id = auth.uid() and status = 'draft');
create policy "Admins manage bookings"
on public.bookings for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Customers can read own booking days"
on public.booking_days for select to authenticated
using (
  exists (
    select 1 from public.bookings
    where bookings.id = booking_days.booking_id
      and bookings.customer_id = auth.uid()
  )
);
create policy "Customers can manage own draft booking days"
on public.booking_days for all to authenticated
using (
  exists (
    select 1 from public.bookings
    where bookings.id = booking_days.booking_id
      and bookings.customer_id = auth.uid()
      and bookings.status = 'draft'
  )
) with check (
  exists (
    select 1 from public.bookings
    where bookings.id = booking_days.booking_id
      and bookings.customer_id = auth.uid()
      and bookings.status = 'draft'
  )
);
create policy "Admins manage booking days"
on public.booking_days for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Customers can read own booking places"
on public.booking_places for select to authenticated
using (
  exists (
    select 1
    from public.booking_days
    join public.bookings on bookings.id = booking_days.booking_id
    where booking_days.id = booking_places.booking_day_id
      and bookings.customer_id = auth.uid()
  )
);
create policy "Customers can manage own draft booking places"
on public.booking_places for all to authenticated
using (
  exists (
    select 1
    from public.booking_days
    join public.bookings on bookings.id = booking_days.booking_id
    where booking_days.id = booking_places.booking_day_id
      and bookings.customer_id = auth.uid()
      and bookings.status = 'draft'
  )
) with check (
  exists (
    select 1
    from public.booking_days
    join public.bookings on bookings.id = booking_days.booking_id
    where booking_days.id = booking_places.booking_day_id
      and bookings.customer_id = auth.uid()
      and bookings.status = 'draft'
  )
);
create policy "Admins manage booking places"
on public.booking_places for all to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Customers can read own payments"
on public.payments for select to authenticated
using (
  exists (
    select 1 from public.bookings
    where bookings.id = payments.booking_id
      and bookings.customer_id = auth.uid()
  )
);
create policy "Admins manage payments"
on public.payments for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Seed pricing settings
insert into public.settings (key, value, description) values
  ('deposit_percent', '10'::jsonb, 'Percentage of booking total required as a deposit'),
  ('launch_discount_slots', '15'::jsonb, 'Remaining promotional discount slots'),
  ('airport_rate_per_km', '200'::jsonb, 'Airport transfer rate per kilometre in LKR'),
  ('rate_per_km_suv', '250'::jsonb, 'SUV rate per kilometre in LKR'),
  ('rate_per_km_bus', '400'::jsonb, 'Bus rate per kilometre in LKR');

-- Seed destinations
insert into public.destinations (name, slug, description, region) values
  ('Sigiriya', 'sigiriya', 'Ancient rock fortress and surrounding cultural landscapes.', 'Central'),
  ('Dalada Maligawa', 'dalada-maligawa', 'Sacred Temple of the Tooth in Kandy.', 'Central'),
  ('Perahera', 'perahera', 'Traditional Kandy Esala Perahera experience.', 'Central'),
  ('Mountains', 'mountains', 'Scenic Sri Lankan mountain regions and viewpoints.', 'Hill Country'),
  ('Waterfall', 'waterfall', 'Highland waterfalls, forest walks, and viewpoints.', 'Hill Country'),
  ('Ella', 'ella', 'A lively hill-country base for walks and rail journeys.', 'Uva'),
  ('Nuwara Eliya', 'nuwara-eliya', 'Tea country landscapes and cool-climate heritage.', 'Central');

-- Seed fleet types
insert into public.vehicles (name, type, seat_capacity, luggage_capacity, rate_per_km_lkr) values
  ('Car', 'car', 4, 2, 220),
  ('SUV', 'suv', 5, 4, 250),
  ('Van', 'van', 8, 6, 300),
  ('Mini-Bus', 'mini-bus', 16, 12, 350),
  ('Bus', 'bus', 35, 25, 400);
