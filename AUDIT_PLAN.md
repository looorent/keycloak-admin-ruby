
## Commit 12 — Durcir le workflow de release

**Pourquoi.** Trois défauts, aucun bloquant mais tous coûteux le jour d'une release ratée :

1. L'étape *create realm* enchaîne des `curl` sans `--fail`. Un échec de provisioning renvoie
   0, le step passe au vert, et ce sont les tests d'intégration qui cassent trois étapes plus
   loin avec un message sans rapport.
2. Le commentaire du step *Start Keycloak* annonce que `bundle exec rspec` sert de garde-fou,
   alors que les steps lancent `rake spec` puis `rake integration`. Commentaire périmé.
3. `release.yml` utilise `actions/checkout@v4`, `ci.yml` utilise `@v6`.

**Fichiers.** `.github/workflows/release.yml` — ajouter `--fail` aux `curl` de provisioning (et
`set -euo pipefail` en tête du script), corriger le commentaire, aligner sur `checkout@v6`.

**Vérif.** Pas de suite locale. Contrôler la syntaxe (`actionlint` si disponible) ; la
validation réelle vient du prochain tag.

```
Harden the release workflow

The realm provisioning curls had no --fail, so a failed setup left the step green
and surfaced three steps later as an unrelated integration failure. Also refresh
a stale comment naming `bundle exec rspec` and align actions/checkout with ci.yml.
```

---

## Commit 13 — Audit de dépendances en CI

**Pourquoi.** Aucun garde-fou sur les dépendances : ni Dependabot, ni `bundle audit`. Pour une
gem d'administration d'un serveur d'identité, une advisory sur `faraday` ou `http-cookie` doit
remonter automatiquement.

**Fichiers.**
- `.github/dependabot.yml` — écosystèmes `bundler` et `github-actions`, cadence hebdomadaire
- `.github/workflows/ci.yml` — un job `audit` distinct de la matrice (il n'a pas besoin de
  Keycloak ni des 20 combinaisons Ruby × Keycloak), lançant `bundle exec bundler-audit check --update`
- `keycloak-admin.gemspec` — `add_development_dependency "bundler-audit"`

> Non retenu ici : RuboCop. L'introduire sur une base sans style figé génère un commit de
> plusieurs centaines de lignes qui noierait le reste. À traiter séparément si tu le souhaites,
> avec un `.rubocop_todo.yml` généré.

**Vérif.** `bundle install && bundle exec bundler-audit check --update`

```
Add Dependabot and a dependency audit job

Nothing watched the dependency tree. The audit job runs outside the Ruby x
Keycloak matrix since it needs neither a server nor every combination.
```

---

# Phase 4 — Ruptures, à réserver à la 3.0.0

À grouper dans une branche `3.0` plutôt qu'à sortir au fil de l'eau. Chacun casse du code
appelant.

## Commit 14 — `Representation` sous le namespace `KeycloakAdmin`

`representation.rb:5` définit `Representation` **dans le namespace global** :
`Object.const_defined?(:Representation) # => true`. Pour une gem, c'est une collision en
attente avec le code hôte (une app Rails avec son propre `Representation` casse à
l'autoload).

Renommer en `KeycloakAdmin::Representation` et laisser `Representation = KeycloakAdmin::Representation`
en alias top-level **déprécié** (warning à l'usage), supprimé en 4.0. Touche les 25 fichiers de
représentation.

```
Move Representation under the KeycloakAdmin namespace

The class was defined at top level, colliding with any host application constant
of the same name. A deprecated top-level alias is kept for one major version.
```

## Commit 15 — Contrats de retour homogènes sur les créations

`GroupClient#create!` renvoie l'id lu dans `Location` ; `OrganizationClient#save`
(`organization_client.rb:47`), `ClientScopeClient#create!` (`client_scope_client.rb:28`) et
`ClientScopeProtocolMapperClient#create!` renvoient `true` et **jettent** l'id. L'appelant doit
re-lister pour retrouver ce qu'il vient de créer. Aligner tout le monde sur `created_id`.

```
Return the created id from every create call

save/create! on organizations, client scopes and protocol mappers returned true
and discarded the Location header, forcing callers to re-list to find the
resource they had just created.
```

## Commit 16 — Échappatoire au filtrage des `nil` dans `as_json`

`representation.rb:11` supprime **tous** les `nil`. Le CHANGELOG l'assume (Keycloak 19+ refuse
`null` sur certains champs), mais sans échappatoire : `user.first_name = nil` puis `update` ne
fait rien, et il devient impossible d'effacer un champ côté serveur.

Deux pistes, à trancher :
- **(a)** une sentinelle explicite (`KeycloakAdmin::NULL`) sérialisée en `null` ;
- **(b)** remplacer la règle globale par une liste ciblée des champs connus comme stricts
  (`subGroupCount`, etc.), ce qui rétablit le comportement standard partout ailleurs.

(b) est plus juste mais demande d'inventorier les champs concernés par version de Keycloak.

```
Allow explicitly clearing a field through as_json

as_json stripped every nil, which fixed strict Keycloak 19+ payloads but made it
impossible to unset a field: assigning nil and updating was a no-op.
```
