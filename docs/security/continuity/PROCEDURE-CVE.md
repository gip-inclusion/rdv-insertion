# Procédure CVE - Vulnérabilités Dépendances

## SLA par Sévérité

| Sévérité | CVSS | Délai | Action |
|----------|------|-------|--------|
| CRITICAL | 9.0-10 | **48h** | Patch immédiat, hotfix si nécessaire |
| HIGH | 7.0-8.9 | **7j** | Planifier patch, tester en staging |
| MEDIUM | 4.0-6.9 | **30j** | Inclure dans prochain sprint |
| LOW | 0.1-3.9 | **90j** | Backlog, correction opportuniste |

## Scan Automatique

- **Dependabot** : Scan quotidien, PRs auto (gems/npm/actions)
- **Bundler-audit** : CI sur chaque PR/push (bloque HIGH/CRITICAL)
- **NPM audit** : CI sur chaque PR/push (bloque HIGH/CRITICAL)

## Procédure de Réponse

### 1. Détection (Auto)
- Dependabot alert GitHub
- CI bloqué si HIGH/CRITICAL
- Notification via GitHub Watch (équipe doit "Watch" le repo)

### 2. Évaluation (< 2h)
```bash
# Vérifier exploitabilité
bundle audit check --verbose
npm audit --production

# Contexte: Fonction utilisée ? Données sensibles exposées ?
```

**Décision**: Patch / Contournement / Accept Risk

### 3. Correction
```bash
# Gems Ruby
bundle update NOM_GEM --conservative
bundle audit check

# NPM
npm update NOM_PACKAGE
npm audit

# Test
bin/rails test
yarn test
```

### 4. Déploiement
```bash
# Staging
git checkout staging && git merge main
# Attendre CI vert, tester manuellement

# Production (si CRITICAL < 48h)
git checkout main && git push
```

### 5. Communication
**Si CRITICAL** :
- Slack #tech : "CVE-XXXX corrigée, déployée production"
- Si data breach potentiel : notification CNIL dans 72h

## Acceptation de Risque

Si patch impossible (breaking change), documenter :

```yaml
# security/accepted-risks/CVE-YYYY-XXXX.md
CVE: CVE-YYYY-XXXX
Sévérité: MEDIUM (CVSS 6.5)
Reason: Breaking change, fonctionnalité non utilisée
Mitigation: Désactivé feature X via ENV
Accepté par: Lead Tech
Date: 2025-XX-XX
Revue: Q1 2026
```

## Ressources

- Dependabot: `Settings → Security → Dependabot`
- GitHub Security: `Security → Advisories`
- CNIL notification (si data breach)
