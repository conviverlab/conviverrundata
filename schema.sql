-- ============================================================
-- Conviver Run 2026 · Schema Supabase
-- Rode este arquivo inteiro no SQL Editor do seu projeto Supabase
-- (Supabase Dashboard > SQL Editor > New query > cole tudo > Run)
--
-- Esta versão substitui checklist_state e a estrutura antiga de
-- channels por tabelas totalmente editáveis. Se você já rodou uma
-- versão anterior deste schema, pode rodar este arquivo de novo:
-- ele recria checklist_state (removida), channels e adiciona
-- phases e checklist_items do zero.
-- ============================================================

drop table if exists checklist_state cascade;
drop table if exists channels cascade;

-- ------------------------------------------------------------
-- Fases da campanha: datas, metas e objetivos são editáveis.
-- Os "goals" (bullets de cada card) ficam num array de texto.
-- ------------------------------------------------------------

create table if not exists phases (
  id text primary key,
  label text not null,
  ordem integer not null,
  date_inicio date not null,
  date_fim date not null,
  meta_inicio integer not null,
  meta_fim integer not null,
  goals text[] not null default '{}',
  updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- Checklist principal (divulgação + operacional): totalmente
-- editável e com itens que podem ser adicionados/removidos.
-- "section" referencia o id de uma fase (f1..f4), "grp" é
-- 'divulgacao' ou 'operacional'.
-- ------------------------------------------------------------

create table if not exists checklist_items (
  id text primary key,
  section text not null,
  grp text not null default 'divulgacao',
  title text not null default '',
  date_label text not null default '',
  priority text not null default 'media',
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

-- Canais de conversão: id próprio, então o nome pode ser editado
-- livremente e novos canais podem ser adicionados/removidos.
create table if not exists channels (
  id text primary key,
  nome text not null default '',
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
-- ------------------------------------------------------------

alter table phases enable row level security;
alter table checklist_items enable row level security;
alter table daily_log enable row level security;
alter table embaixadores enable row level security;
alter table channels enable row level security;
alter table dashboard_metrics enable row level security;
alter table patrocinios enable row level security;
alter table producao_checklist enable row level security;
alter table orcamento_cotacoes enable row level security;

create policy "anon full access" on phases for all using (true) with check (true);
create policy "anon full access" on checklist_items for all using (true) with check (true);
create policy "anon full access" on daily_log for all using (true) with check (true);
create policy "anon full access" on embaixadores for all using (true) with check (true);
create policy "anon full access" on channels for all using (true) with check (true);
create policy "anon full access" on dashboard_metrics for all using (true) with check (true);
create policy "anon full access" on patrocinios for all using (true) with check (true);
create policy "anon full access" on producao_checklist for all using (true) with check (true);
create policy "anon full access" on orcamento_cotacoes for all using (true) with check (true);

-- ------------------------------------------------------------
-- Realtime
-- ------------------------------------------------------------

alter publication supabase_realtime add table phases, checklist_items, daily_log, embaixadores, channels, dashboard_metrics, patrocinios, producao_checklist, orcamento_cotacoes;

-- ------------------------------------------------------------
-- Seed: fases (datas, metas e objetivos atuais — editáveis depois)
-- ------------------------------------------------------------

insert into phases (id, label, ordem, date_inicio, date_fim, meta_inicio, meta_fim, goals) values
  ('f1','Fase 1',1,'2026-07-09','2026-07-16',100,180, ARRAY['Ativar base atual de inscritos','Fechar 1º patrocinador','Selecionar 30 embaixadores']),
  ('f2','Fase 2',2,'2026-07-16','2026-07-31',180,280, ARRAY['4 ativações presenciais (esquentas)','Fechar 2º patrocinador','Embaixadores publicando']),
  ('f3','Fase 3',3,'2026-08-01','2026-08-15',280,370, ARRAY['Mídia paga no ar','Conteúdo diário','Disparos WhatsApp/e-mail']),
  ('f4','Fase 4',4,'2026-08-16','2026-08-23',370,450, ARRAY['Comunicação de urgência','Último ciclo de mobilização','Otimização diária'])
on conflict (id) do nothing;

-- ------------------------------------------------------------
-- Seed: checklist principal (52 itens atuais)
-- ------------------------------------------------------------

insert into checklist_items (id, section, grp, title, date_label, priority, done) values
  ('f1-1','f1','divulgacao','Extrair lista dos 100 inscritos atuais e contatar individualmente','10/07','alta',false),
  ('f1-2','f1','divulgacao','Criar arte de Stories para compartilhamento dos inscritos','10/07','media',false),
  ('f1-3','f1','divulgacao','Revisar influenciadores acionados e reforçar quem não publicou','11/07','media',false),
  ('f1-4','f1','divulgacao','Republicar conteúdos já produzidos pelos influenciadores','12/07','baixa',false),
  ('f1-5','f1','divulgacao','Produzir conteúdo de conversão: troféu, medalha, kit, percurso, benefícios','12/07','media',false),
  ('f1-6','f1','divulgacao','Reforçar parceiros e revisar oportunidades de e-mail marketing','13/07','media',false),
  ('f1-7','f1','divulgacao','Reforçar assessorias esportivas e identificar atletas influentes','13/07','media',false),
  ('f1-8','f1','divulgacao','Selecionar cerca de 30 embaixadores e formalizar convites','14/07','alta',false),
  ('f1-9','f1','divulgacao','Confirmar embaixadora Ilana (Garotos que Correm)','10/07','media',false),
  ('f1-10','f1','divulgacao','Mapear academias de Parnaíba e liberar cupons exclusivos','14/07','media',false),
  ('f1-11','f1','divulgacao','Criar competição entre academias e definir premiação','15/07','media',false),
  ('f1-12','f1','divulgacao','Confirmar com Jair a equipe de beach tennis patrocinada e acionar atletas','11/07','baixa',false),
  ('f1-13','f1','divulgacao','Fechar o 1º patrocinador oficial','16/07','alta',false),
  ('u1','f1','operacional','Prazos TF (abertura no app, camisetas, logos, arte) finalizados. Confirmar registro formal com a TF','09/07','baixa',true),
  ('u13','f1','operacional','Acompanhar chegada dos kits (camisetas + gym bags) e liberar cronograma de distribuição','a confirmar','alta',false),
  ('u2','f1','operacional','Validar trajeto aprovado e configurações da prova junto à TF','10/07','alta',false),
  ('u3','f1','operacional','Confirmar ausência de pendências na plataforma TFSports/Deskfy','10/07','alta',false),
  ('u4','f1','operacional','Revisar orçamentos ponto a ponto (Fabiano x Maurício), recalculando itens que escalam com o público de 450','10/07','alta',false),
  ('u5','f1','operacional','Fechar orçamento, fornecedor e modelo final de troféus e medalhas','10/07','alta',false),
  ('u6','f1','operacional','Decidir sobre troféus PCD e 60+ (110 unidades em revisão)','10/07','alta',false),
  ('u7','f1','operacional','Confirmar ponto exato de largada/chegada na Av. Portinho e alinhar com planta do evento e alvará','10/07','alta',false),
  ('u8','f1','operacional','Solicitar aos produtores locais: levantamento, orçamento e 2-3 fornecedores por categoria','10/07','alta',false),
  ('u9','f1','operacional','Consolidar planilha mestre comparativa de fornecedores','12/07','alta',false),
  ('u10','f1','operacional','Estruturar cupons de desconto por canal, rastreáveis por origem','10/07','alta',false),
  ('u11','f1','operacional','Criar cupom exclusivo e arte de divulgação para corretores','09/07','alta',false),
  ('u12','f1','operacional','Distribuir material e iniciar captação via corretores','10/07','alta',false),
  ('g-1','f1','operacional','Reunião semanal de acompanhamento de indicadores','toda sexta','alta',false),
  ('g-2','f1','operacional','Atualizar este painel diariamente','diário','alta',false),
  ('g-3','f1','operacional','Criar calendário único de comunicação (marketing, imprensa, redes, mídia paga, parceiros, embaixadores)','14/07','media',false),
  ('g-7','f1','operacional','Definir formato de premiação 2027 (todas as categorias x sorteio)','a definir','media',false),
  ('f2-1','f2','divulgacao','Planejar e executar ativação no Aeroporto','18/07','media',false),
  ('f2-2','f2','divulgacao','Planejar e executar ativação na Praça do Trem','21/07','media',false),
  ('f2-3','f2','divulgacao','Planejar e executar ativação na Av. São Sebastião / loja TF','24/07','media',false),
  ('f2-4','f2','divulgacao','Planejar e executar ativação em academia de grande fluxo','27/07','media',false),
  ('f2-5','f2','divulgacao','Iniciar oficialmente a competição entre academias e divulgar ranking','16/07','media',false),
  ('f2-6','f2','divulgacao','Criar dashboard público de academias (ranking, evolução semanal)','20/07','baixa',false),
  ('f2-7','f2','divulgacao','Gravar briefing e conteúdos dos 30 embaixadores','16/07','alta',false),
  ('f2-8','f2','divulgacao','Embaixadores publicam Reels: convite, inscrição, cupom','16 a 31/07','media',false),
  ('f2-9','f2','divulgacao','Fechar o 2º patrocinador oficial','31/07','alta',false),
  ('f3-1','f3','divulgacao','Montar calendário diário de conteúdo até o evento','01/08','media',false),
  ('f3-2','f3','divulgacao','Integrar narrativa com o lançamento do Bairro Planejado','03/08','baixa',false),
  ('f3-3','f3','divulgacao','Planejar campanhas de mídia paga (kit, percurso, medalha, últimas vagas)','05/08','alta',false),
  ('f3-4','f3','divulgacao','Rodar mídia paga','10 a 23/08','alta',false),
  ('f3-5','f3','divulgacao','Criar e executar cronograma de disparos WhatsApp e e-mail','05/08','media',false),
  ('f3-6','f3','divulgacao','Projetar e acompanhar metas por canal semanalmente','01/08','alta',false),
  ('g-4','f3','operacional','Providenciar documentos obrigatórios: PERMIT, ECAD, planta, RRT/ART, alvará','01/08','alta',false),
  ('g-5','f3','operacional','Contratar seguro atleta via TFSports','01/08','media',false),
  ('f4-1','f4','divulgacao','Produzir comunicação de urgência: últimas vagas, contagem regressiva','16/08','alta',false),
  ('f4-2','f4','divulgacao','Publicar bastidores de montagem e entrega de kits','18/08','media',false),
  ('f4-3','f4','divulgacao','Último ciclo de mobilização de todos os canais','16/08','alta',false),
  ('f4-4','f4','divulgacao','Reforçar mídia paga, WhatsApp e e-mail na reta final','16/08','alta',false),
  ('f4-5','f4','divulgacao','Monitorar diariamente e otimizar investimento se necessário','16 a 22/08','alta',false),
  ('g-6','f4','operacional','Validar itens obrigatórios TF no dia do evento (arena, dispersão, comunicação, cronometragem)','20/08','alta',false)
on conflict (id) do nothing;

-- ------------------------------------------------------------
-- Seed: canais de conversão padrão
-- ------------------------------------------------------------

insert into channels (id, nome) values
  ('ch-1','Academias'),('ch-2','Embaixadores'),('ch-3','Influenciadores'),('ch-4','Corretores'),
  ('ch-5','Parceiros'),('ch-6','Assessorias esportivas'),('ch-7','Ativações presenciais'),
  ('ch-8','Mídia paga'),('ch-9','WhatsApp'),('ch-10','E-mail marketing'),('ch-11','Conteúdo orgânico')
on conflict (id) do nothing;

-- ------------------------------------------------------------
-- Seed: métricas do dashboard, evolução diária e embaixadora inicial
-- ------------------------------------------------------------

insert into dashboard_metrics (id) values (1) on conflict (id) do nothing;
insert into daily_log (date, total) values ('2026-07-09', 100) on conflict (date) do nothing;
insert into embaixadores (id, nome) values ('amb-seed-1', 'Ilana (Garotos que Correm)') on conflict (id) do nothing;
