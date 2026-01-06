# Procédure Gitleaks - Secrets Exposés

## Protection 3 Couches

1. **Pre-commit** : Blocage local avant git commit
2. **.gitleaks.toml** : Config rules + exclusions
3. **CI** : Scan PR (protect) + historique (detect hebdo)

## Installation Pre-commit

```bash
pip install pre-commit
pre-commit install

# Test
echo "API_KEY=sk-1234567890abcdef" > test.rb
git add test.rb
git commit -m "test"  # Bloqué par gitleaks
```

## Scénarios

### Scénario 1: Pre-commit Bloque (✅ OK)
```bash
# Secret détecté avant commit
# → Retirer du fichier, utiliser .env
# → git commit (succès)
```

### Scénario 2: Secret Dans PR (**<24h**)
1. **Ne pas merger**
2. Retirer secret:
```bash
git rebase -i HEAD~3  # Éditer commits concernés
# Remplacer secret par ENV var
git push --force-with-lease
```
3. **Rotationner** secret exposé (voir SECRETS-MANAGEMENT.md)

### Scénario 3: Secret Mergé (**<4h CRITICAL**)
1. **Rotation immédiate** (<4h)
2. Cleanup historique:
```bash
# git filter-repo (recommandé par Git, maintenu activement)
pip install git-filter-repo

# Cloner et nettoyer
git clone --mirror git@github.com:org/repo.git
cd repo.git

# Option A: Supprimer un fichier entier de l'historique
git filter-repo --path .env --invert-paths

# Option B: Remplacer une valeur spécifique
echo 'SECRET_VALUE==>REDACTED' > replacements.txt
git filter-repo --replace-text replacements.txt

# Pousser les changements
git push --force
```
3. Notification équipe technique

## Rotation Timeline par Secret

| Type | Délai | Action |
|------|-------|--------|
| 🔐 **Encryption** | Compromission uniquement | Rechiffrement DB |
| 🔑 **API/Auth** | < 4h (CRITICAL) | Régénération console externe |
| ⚪ **Monitoring** | < 24h | Régénération webhook |

## Faux Positifs

Ajouter à `.gitleaks.toml` :
```toml
[allowlist]
paths = [
  "spec/**/*_spec.rb",  # Tests
  ".env.example"         # Template
]
regexes = [
  "example_api_key"      # Valeur factice
]
```

## Scan Historique

```bash
# Baseline (1ère fois)
gitleaks detect --log-opts="--all" --report-path baseline.json

# Trier: faux positifs vs vrais secrets
# Si vrais secrets → Rotation + BFG cleanup
```

## CI Workflow

- **PR** : `gitleaks protect` (changements seulement)
- **Push/Schedule** : `gitleaks detect --all` (historique complet)
- **SARIF** : Upload → GitHub Security tab

Blocage automatique si secrets détectés.

