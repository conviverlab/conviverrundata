# Conviver Run 2026 — Painel do Time (Supabase + GitHub Pages)

Painel compartilhado em tempo real: todo mundo do time abre o mesmo link,
edita o checklist, o roteiro de embaixadores e a evolução diária de inscritos,
e vê a atualização de qualquer pessoa aparecer na hora, sem precisar dar F5.

Link aberto, sem login — qualquer pessoa com a URL lê e edita. É a troca que
você escolheu (confiar no time interno). Se um dia quiser travar mais, dá para
adicionar autenticação depois sem precisar refazer o resto.

Tempo estimado de deploy: 15 a 20 minutos.

---

## 1. Criar o projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e entre na sua conta.
2. **New project** → escolha um nome (ex: `conviver-run-2026`), uma senha de
   banco (guarde em local seguro, mas você não vai precisar dela no dia a dia)
   e a região mais próxima (ex: South America - São Paulo, se disponível).
3. Aguarde o projeto terminar de provisionar (1-2 minutos).

## 2. Rodar o schema

1. No menu lateral do projeto, abra **SQL Editor**.
2. Clique em **New query**.
3. Abra o arquivo `schema.sql` (deste mesmo pacote), copie tudo, cole no editor.
4. Clique em **Run**.
5. Confira se apareceu "Success" sem erros. Se aparecer um erro dizendo que a
   tabela já está na publicação de realtime, pode ignorar — só significa que
   já estava configurado.

Isso cria as 5 tabelas, libera acesso de leitura/escrita para o link (sem
login) e já popula o checklist, os canais e a primeira embaixadora.

## 3. Pegar a URL e a chave do projeto

1. No menu lateral, vá em **Project Settings** (ícone de engrenagem) → **API**.
2. Copie o campo **Project URL** (algo como `https://xxxxx.supabase.co`).
3. Copie o campo **anon public** em Project API keys (uma chave longa).

Guarde os dois, você vai colar no próximo passo.

## 4. Configurar o `index.html`

1. Abra o arquivo `index.html` (deste pacote) em qualquer editor de texto.
2. Encontre este trecho, perto do topo do bloco `<script>`:

   ```js
   const SUPABASE_URL = 'https://YOUR-PROJECT-REF.supabase.co';
   const SUPABASE_ANON_KEY = 'YOUR-ANON-PUBLIC-KEY';
   ```

3. Substitua pelos valores que você copiou no passo 3. Salve o arquivo.

## 5. Subir para o GitHub

1. Crie um repositório novo no GitHub (pode ser privado ou público — como o
   link de acesso já não tem login, um repositório privado não protege os
   dados em si, só o código-fonte).
2. Suba os arquivos `index.html`, `schema.sql` e este `README.md` para o
   repositório (pela interface web do GitHub — **Add file → Upload files** —
   ou via `git push` se preferir linha de comando).

## 6. Ativar o GitHub Pages

1. No repositório, vá em **Settings → Pages**.
2. Em **Source**, escolha **Deploy from a branch**.
3. Em **Branch**, escolha `main` e a pasta `/ (root)`. Salve.
4. Aguarde 1-2 minutos. O GitHub mostra a URL pública no topo da mesma tela
   (algo como `https://seu-usuario.github.io/nome-do-repo/`).

Esse é o link que você distribui para o time.

## 7. Ativar o Realtime (se a sincronização ao vivo não aparecer)

O `schema.sql` já tenta ativar isso automaticamente. Se, depois de testar com
duas abas abertas, uma não atualizar quando a outra edita algo:

1. No Supabase, vá em **Database → Replication**.
2. Localize a publicação `supabase_realtime`.
3. Confirme que as 5 tabelas (`checklist_state`, `daily_log`, `embaixadores`,
   `channels`, `dashboard_metrics`) estão marcadas.

## 8. Testar

1. Abra o link do GitHub Pages em duas abas (ou peça para alguém do time abrir
   ao mesmo tempo).
2. Marque um item do checklist em uma aba.
3. Confira se a outra aba atualiza sozinha em menos de 1 segundo. Se atualizar,
   está tudo funcionando.

---

## O que fica salvo onde

- **Checklist, embaixadores, log diário, canais, patrocinadores/esquentas,
  patrocínios, checklist de produção &amp; documentação, cotações de
  orçamento**: no banco Postgres do seu projeto Supabase. É a fonte de
  verdade.
- **Backup manual**: o botão "Exportar backup (.json)" no rodapé baixa uma
  cópia local a qualquer momento. Recomendo exportar antes de mudanças grandes
  (ex: reorganizar o checklist).

## Módulos do painel

- **Dashboard**: KPIs gerais, evolução diária de inscritos com meta por
  marcos, conversão por canal.
- **Linha do tempo**: as 4 fases da campanha.
- **Checklist**: as ações do plano emergencial (divulgação + operacional).
- **Embaixadores**: nome, @, cupom, se gravou o Reels, data de publicação.
- **Patrocínios**: empresas em contato, data do 1º e do último contato,
  status da negociação, se fechou, observações.
- **Produção &amp; Doc.**: checklist livre que você cadastra item por item,
  separado em "Produção" e "Documentação".
- **Orçamento**: para cada item marcado como "Produção", compara até 3
  fornecedores lado a lado, destaca o menor valor, e soma uma estimativa
  total (usando o fornecedor escolhido quando marcado, senão o menor valor
  disponível).

## Sobre o acesso aberto

Qualquer pessoa com o link do GitHub Pages lê e escreve nos dados. Não há
distinção entre "quem fez a edição" — o campo "Responsável" nos itens do
checklist é preenchido manualmente por quem edita, não é um login automático.
Se o time crescer ou o painel virar algo mais permanente, duas evoluções
possíveis mais adiante:

1. **Senha única**: adicionar uma tela simples de senha antes de carregar o
   app (proteção básica, não é segurança de verdade, mas afasta acesso casual).
2. **Supabase Auth**: login individual por e-mail, com RLS restringindo escrita
   por usuário. Dá mais trabalho de configurar, mas permite saber exatamente
   quem editou o quê.

Nenhuma das duas está implementada aqui — o pacote atual reflete a decisão de
"link aberto, confiar no time".

## Se algo der errado

- **Tela ficou em "Conectando ao Supabase..." para sempre**: confira se a
  URL e a chave no `index.html` estão exatamente como aparecem no Supabase
  (sem espaços extras, sem aspas duplicadas).
- **Erro de conexão na tela**: geralmente é schema.sql não executado, ou
  RLS bloqueando — confira se rodou o passo 2 até o fim.
- **Dados sumiram**: use o backup mais recente exportado (botão no rodapé) e
  importe de volta.
