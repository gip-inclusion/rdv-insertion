# Procédure SAST - Analyse Statique Code

## Dual Scanner

- **Brakeman** : Rails-specific (confidence-2, bloque High/Medium)
- **Semgrep** : Multi-language (4 rulesets, bloque Error + >10 Warning)

## CI Workflow

Scan auto sur:
- Chaque PR/push → Bloque si vulnérabilités
- Quotidien 2h → Rapport complet
- Manuel : Actions → SAST → Run workflow

## Classification

| Niveau | Délai | Action |
|--------|-------|--------|
| **High/Error** | 48h | Correction immédiate |
| **Medium/Warning** (>10) | 7j | Sprint en cours |
| **Low/Note** | 30j | Backlog |

## Scan Local

```bash
# Brakeman
gem install brakeman
brakeman --confidence-level 2 --format text

# Semgrep
docker run -v $(pwd):/src semgrep/semgrep scan \
  --config p/security-audit --config p/rails --config p/owasp-top-ten
```

## Faux Positifs

### Brakeman
```ruby
# Code
User.where("status = '#{safe_value}'")  # false positive

# Supprimer
# brakeman:ignore SQLInjection
User.where("status = '#{safe_value}'")
```

Ou ajouter à `config/brakeman.ignore` (JSON généré via `brakeman -I`)

### Semgrep
```python
# nosemgrep: python.lang.security.audit.sqli
execute_query(f"SELECT * FROM users WHERE id = {user_id}")
```

## Premier Scan

1. Baseline:
```bash
brakeman --format json --output baseline.json
semgrep scan --config p/security-audit --json --output semgrep-baseline.json
```

2. Trier findings:
   - **Vrais positifs** → Tickets
   - **Faux positifs** → Documenter suppressions

3. Activation progressive:
   - Semaine 1: Warning threshold = 50
   - Semaine 2: Warning threshold = 30
   - Semaine 3: Warning threshold = 20
   - Semaine 4: Warning threshold = 10 (cible)

## GitHub Security

Résultats SARIF auto-upload: `Security → Code scanning → Alerts`

## Ressources

- Brakeman: https://brakemanscanner.org/docs/
- Semgrep: https://semgrep.dev/docs/
- OWASP Top 10: https://owasp.org/www-project-top-ten/
