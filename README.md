# Fox Shoopey

Catálogo de produtos afiliados com vitrine responsiva, categorias, ofertas, recomendações e área administrativa isolada.

## Vitrine pública

Abra `index.html` para visualizar a loja.

A home possui:
- vitrine e ofertas em destaque
- categorias + busca
- favoritos locais
- redirecionamento para oferta externa
- recomendações
- tema automático seguindo `prefers-color-scheme`
- botão de tema com ciclo `Auto → Claro → Escuro → Auto`
- animações leves e ícones flutuantes na hero

## Área administrativa

O painel foi retirado da navegação pública. Não existe mais `#admin`, senha fixa ou autorização via `localStorage`.

A entrada fica em `admin.html` e só libera o dashboard depois de:
1. autenticar o usuário com Supabase Auth usando e-mail e senha
2. verificar se o `user_id` possui uma linha em `public.admin_profiles` com `role = 'admin'`
3. operar sobre `public.products` protegido por Row Level Security (RLS)

Sem Supabase configurado, a tela administrativa permanece bloqueada. O login de demonstração foi removido de propósito.

## Configuração do Supabase

1. Crie/configure um projeto Supabase.
2. Rode `supabase/schema.sql` no SQL Editor.
3. Crie o usuário administrativo em Auth.
4. Insira o `user_id` desse usuário em `public.admin_profiles`.
5. Copie `config.example.js` para `config.js` e preencha somente a URL do projeto e a publishable key.
6. Nunca coloque uma `service_role`/secret key no navegador.

Exemplo de `config.js`:

```js
window.FOX_SUPABASE = {
  url: 'https://SEU-PROJETO.supabase.co',
  publishableKey: 'SUA_PUBLISHABLE_KEY'
};
```

## Proteção contra exclusões acidentais

O painel não oferece exclusão definitiva. O comando disponível é **Arquivar**, que altera `active = false` e preserva o registro no banco.

O último produto ativo não pode ser arquivado pelo painel, evitando deixar a vitrine sem nenhum produto por engano.

## Afiliados

Cadastre o link específico do produto gerado pelo programa oficial de cada marketplace. O painel não tenta transformar páginas genéricas em links de afiliado.
