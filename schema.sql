-- ============================================================
-- Conviver Run 2026 · Schema Supabase
-- Rode este arquivo inteiro no SQL Editor do seu projeto Supabase
-- (Supabase Dashboard > SQL Editor > New query > cole tudo > Run)
-- ============================================================

-- ------------------------------------------------------------
-- Tabelas
-- ------------------------------------------------------------

create table if not exists checklist_state (
  id text primary key,
  done boolean not null default false,
  responsavel text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists daily_log (
  date date primary key,
  total integer not null,
  updated_at timestamptz not null default now()
);

create table if not exists embaixadores (
  id text primary key,
  nome text not null default '',
  handle text not null default '',
  cupom text not null default '',
  reels boolean not null default false,
  data_pub date,
  updated_at timestamptz not null default now()
);

create table if not exists channels (
  nome text primary key,
  meta integer not null default 0,
  resultado integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists dashboard_metrics (
  id integer primary key default 1,
  patrocinadores integer not null default 0,
  esquentas integer not null default 0,
  updated_at timestamptz not null default now(),
  constraint singleton check (id = 1)
);

create table if not exists patrocinios (
  id text primary key,
  empresa text not null default '',
  data_primeiro_contato date,
  data_ultimo_contato date,
  status text not null default 'Prospecção',
  fechado boolean not null default false,
  observacoes text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists producao_checklist (
  id text primary key,
  titulo text not null default '',
  categoria text not null default 'producao', -- 'producao' | 'documentacao'
  prazo date,
  responsavel text not null default '',
  done boolean not null default false,
  observacoes text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists orcamento_cotacoes (
  item_id text primary key references producao_checklist(id) on delete cascade,
  fornecedor1 text not null default '', valor1 numeric,
  fornecedor2 text not null default '', valor2 numeric,
  fornecedor3 text not null default '', valor3 numeric,
  escolhido smallint,
  observacoes text not null default '',
  updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- RLS: liberado para o time interno via link, sem login.
-- Isso significa que qualquer pessoa com a URL do site lê E escreve
-- em todas as tabelas abaixo. É a troca consciente que você fez
-- (link aberto, confiando no time). Se um dia quiser travar mais,
-- é aqui que se troca `using (true)` por uma checagem de usuário
-- autenticado (Supabase Auth).
-- ------------------------------------------------------------

alter table checklist_state enable row level security;
alter table daily_log enable row level security;
alter table embaixadores enable row level security;
alter table channels enable row level security;
alter table dashboard_metrics enable row level security;
alter table patrocinios enable row level security;
alter table producao_checklist enable row level security;
alter table orcamento_cotacoes enable row level security;

create policy "anon full access" on checklist_state for all using (true) with check (true);
create policy "anon full access" on daily_log for all using (true) with check (true);
create policy "anon full access" on embaixadores for all using (true) with check (true);
create policy "anon full access" on channels for all using (true) with check (true);
create policy "anon full access" on dashboard_metrics for all using (true) with check (true);
create policy "anon full access" on patrocinios for all using (true) with check (true);
create policy "anon full access" on producao_checklist for all using (true) with check (true);
create policy "anon full access" on orcamento_cotacoes for all using (true) with check (true);

-- ------------------------------------------------------------
-- Realtime: publica as tabelas para sincronizar entre os
-- navegadores do time em tempo real. Se der erro dizendo que a
-- tabela já está na publicação, pode ignorar.
-- ------------------------------------------------------------

alter publication supabase_realtime add table checklist_state, daily_log, embaixadores, channels, dashboard_metrics, patrocinios, producao_checklist, orcamento_cotacoes;

-- ------------------------------------------------------------
-- Seed: itens do checklist (mesmos ids do painel atual)
-- ------------------------------------------------------------

insert into checklist_state (id) values
  ('f1-1'),('f1-2'),('f1-3'),('f1-4'),('f1-5'),('f1-6'),('f1-7'),('f1-8'),('f1-9'),('f1-10'),('f1-11'),('f1-12'),('f1-13'),
  ('u1'),('u13'),('u2'),('u3'),('u4'),('u5'),('u6'),('u7'),('u8'),('u9'),('u10'),('u11'),('u12'),
  ('g-1'),('g-2'),('g-3'),('g-7'),
  ('f2-1'),('f2-2'),('f2-3'),('f2-4'),('f2-5'),('f2-6'),('f2-7'),('f2-8'),('f2-9'),
  ('f3-1'),('f3-2'),('f3-3'),('f3-4'),('f3-5'),('f3-6'),
  ('g-4'),('g-5'),
  ('f4-1'),('f4-2'),('f4-3'),('f4-4'),('f4-5'),
  ('g-6')
on conflict (id) do nothing;

-- u1 (prazos TF) já sai marcado como concluído, conforme confirmado
update checklist_state set done = true where id = 'u1';

-- ------------------------------------------------------------
-- Seed: canais de conversão padrão
-- ------------------------------------------------------------

insert into channels (nome) values
  ('Academias'),('Embaixadores'),('Influenciadores'),('Corretores'),('Parceiros'),
  ('Assessorias esportivas'),('Ativações presenciais'),('Mídia paga'),('WhatsApp'),
  ('E-mail marketing'),('Conteúdo orgânico')
on conflict (nome) do nothing;

-- ------------------------------------------------------------
-- Seed: linha única de métricas do dashboard
-- ------------------------------------------------------------

insert into dashboard_metrics (id) values (1) on conflict (id) do nothing;

-- ------------------------------------------------------------
-- Seed: ponto de partida da evolução diária (09/07 = 100 inscritos)
-- ------------------------------------------------------------

insert into daily_log (date, total) values ('2026-07-09', 100) on conflict (date) do nothing;

-- ------------------------------------------------------------
-- Seed: primeira embaixadora já confirmada
-- ------------------------------------------------------------

insert into embaixadores (id, nome) values ('amb-seed-1', 'Ilana (Garotos que Correm)')
on conflict (id) do nothing;
