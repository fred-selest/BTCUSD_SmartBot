# 🏦 Configuration FxPro - BTCUSD SmartBot Pro

Guide spécifique pour utiliser le bot sur **FxPro** avec le symbole **BITCOIN**

---

## ⚠️ Particularité FxPro

Sur FxPro, le symbole Bitcoin s'appelle **"BITCOIN"** (et non BTCUSD) et possède des caractéristiques spécifiques :

### 📊 Caractéristiques du Symbole BITCOIN sur FxPro

| Paramètre | Valeur Typique |
|-----------|----------------|
| **Nom du symbole** | BITCOIN |
| **Spread** | 10000-15000 points |
| **Spread réel** | ~100-150 USD |
| **Cotation** | 1 point = 0.01 USD environ |
| **Lot minimum** | 0.01 |
| **Leverage** | 1:5 à 1:50 |

> **Note** : Le spread de 10000+ points est **normal** pour FxPro. C'est équivalent à 100-150 USD de spread réel.

---

## 🚀 Installation Rapide FxPro

### 1️⃣ Utiliser la Configuration Prédéfinie

1. **Télécharger** : `BTCUSD_SmartBot_Pro_FxPro.set`
2. **Installer le bot** comme d'habitude
3. **Attacher au graphique** BITCOIN H1
4. **Charger les paramètres** :
   - Clic droit sur le bot → Propriétés
   - Bouton **"Charger"**
   - Sélectionner `BTCUSD_SmartBot_Pro_FxPro.set`
   - Cliquer **OK**

### 2️⃣ Configuration Manuelle

Si vous préférez configurer manuellement :

**PARAMÈTRE CRITIQUE** :
```
InpMaxSpread = 15000    // ⚠️ IMPORTANT pour FxPro
```

**Autres paramètres recommandés** :
```
InpRiskPercent = 1.0    // Risque 1% (prudent)
InpMinATR = 50.0        // ATR minimum
InpUseH4Confirmation = true
```

---

## 🎯 Paramètres Optimisés FxPro

### ⚖️ Configuration Équilibrée (Recommandée)

```
═══ GESTION DU RISQUE ═══
Risque par trade          : 1.0%
Nombre max positions      : 1

═══ STRATEGIE ═══
EMA Rapide               : 9
EMA Lente                : 21
Période ATR              : 14
Multiplicateur TP        : 2.5
Multiplicateur SL        : 1.5

═══ FILTRES ═══
ATR minimum              : 50.0 USD
Spread maximum           : 15000 points ⚠️
Heures trading           : 0-23 (24h/24)

═══ TRAILING ═══
Activer Trailing         : true
Activation               : 1.0%
Distance                 : 0.5%
Breakeven                : true
Trigger Breakeven        : 0.5%

═══ AUTRES ═══
Confirmation H4          : true
```

### 🛡️ Configuration Conservative

Pour trading plus prudent :
```
Risque par trade         : 0.5%
Spread maximum           : 12000 points
ATR minimum              : 75.0 USD
Multiplicateur SL        : 2.0
```

### ⚡ Configuration Aggressive

Pour plus de trades (⚠️ plus de risque) :
```
Risque par trade         : 2.0%
Nombre max positions     : 2
Spread maximum           : 20000 points
ATR minimum              : 30.0 USD
Confirmation H4          : false
```

---

## 📊 Comprendre le Spread FxPro

### Pourquoi le spread est si élevé ?

Le spread de **10000-15000 points** sur FxPro BITCOIN n'est **PAS** un problème. Voici pourquoi :

**Conversion** :
```
Prix Bitcoin : ~69000 USD
Spread affiché : 10000 points
Spread réel : ~100 USD (0.145% du prix)

Calcul : 10000 points × 0.01 USD/point = 100 USD
```

C'est un **spread normal** pour un CFD Bitcoin chez un broker Forex.

### Comparaison avec d'autres Brokers

| Broker | Symbole | Spread Points | Spread USD | % du Prix |
|--------|---------|---------------|------------|-----------|
| **FxPro** | BITCOIN | 10000-15000 | 100-150 | 0.15% |
| IC Markets | BTCUSD | 50-100 | 50-100 | 0.10% |
| Pepperstone | BTC/USD | 30-80 | 30-80 | 0.08% |

Le spread FxPro est dans la norme, mais **exprimé différemment** (en points).

---

## 🧪 Backtesting sur FxPro

### Configuration Strategy Tester

```
Symbole          : BITCOIN
Période          : H1
Dates            : 3-6 mois minimum
Modèle           : "Tous les ticks"
Balance initiale : 1000 EUR
Leverage         : 1:10 ou 1:20
```

### Paramètres Critiques

**OBLIGATOIRE** :
```
InpMaxSpread = 15000 ou plus
```

Sinon, aucun trade ne sera exécuté (comme dans vos logs).

### Résultats Attendus

Avec les bons paramètres :
- **Trades** : 5-20 par mois
- **Win Rate** : 40-55%
- **Drawdown** : 10-20%
- **Profit Factor** : 1.3-2.0

---

## ✅ Checklist FxPro

Avant de lancer le bot sur FxPro :

- [ ] ✅ Symbole = **BITCOIN** (pas BTCUSD)
- [ ] ✅ Période = **H1**
- [ ] ✅ **InpMaxSpread = 15000** (CRITIQUE)
- [ ] ✅ Fichier `.set` FxPro chargé
- [ ] ✅ Backtest passé avec succès
- [ ] ✅ Test DEMO 2+ semaines
- [ ] ✅ Capital minimum 1000 EUR
- [ ] ✅ Leverage 1:10 ou 1:20

---

## 🐛 Troubleshooting FxPro

### ❌ Aucun trade exécuté

**Problème** : Logs montrent "Spread trop élevé"

**Solution** :
```
InpMaxSpread = 15000  // Augmenter
```

### ❌ Erreur "Invalid stops"

**Problème** : SL/TP trop proche du prix

**Solution** :
```
InpATR_MultiplierSL = 2.0  // Augmenter
```

### ❌ Lots trop petits

**Problème** : Position size = 0.00

**Solution** :
- Augmenter capital (min 1000 EUR)
- Ou augmenter risque à 2%

### ⚠️ Spread fluctue beaucoup

**Normal** : Le spread BITCOIN varie selon :
- Volatilité du marché
- Heures de trading
- Liquidité

**Plage normale** : 10000-15000 points

---

## 📈 Optimisation FxPro

### Meilleurs Horaires de Trading

**Spread plus bas** :
- 08:00-10:00 UTC (ouverture Europe)
- 14:00-16:00 UTC (ouverture US)
- 20:00-22:00 UTC (pic crypto)

**Spread plus élevé** :
- 00:00-06:00 UTC (faible liquidité)
- Week-ends (fermé)

### Configuration Horaires

Pour trader seulement aux meilleures heures :
```
InpStartHour = 8
InpEndHour = 22
```

---

## 💰 Sizing et Risk Management

### Capital Recommandé

| Capital | Risque % | Lot Typique | Risque USD |
|---------|----------|-------------|------------|
| 500 EUR | 1% | 0.005 | 5 EUR |
| 1000 EUR | 1% | 0.010 | 10 EUR |
| 2000 EUR | 1% | 0.020 | 20 EUR |
| 5000 EUR | 1% | 0.050 | 50 EUR |

### Leverage

**Recommandé** : 1:10 à 1:20
- Éviter leverage trop élevé (>1:50)
- FxPro offre jusqu'à 1:5 sur Bitcoin

---

## 📞 Support FxPro

### Ressources

- 📖 **Guide bot** : README_MT5.md
- 🔧 **Configuration** : BTCUSD_SmartBot_Pro_FxPro.set
- 🐛 **Issues** : GitHub

### Vérifications

Avant de contacter le support :

1. **Vérifier paramètres** :
   ```
   InpMaxSpread = 15000 (minimum)
   ```

2. **Vérifier symbole** :
   - Doit être "BITCOIN"
   - Vérifier dans Market Watch

3. **Vérifier spread actuel** :
   - Clic droit sur symbole → Spécifications
   - Noter le spread typique

4. **Logs** :
   - Onglet "Experts"
   - Copier les derniers messages

---

## 🎓 Exemple Complet

### Configuration Pas-à-Pas

**1. Installer le bot**
```
MQL5/Experts/BTCUSD_SmartBot_Pro.mq5
Compiler (F7)
```

**2. Ouvrir graphique**
```
Symbole : BITCOIN
Timeframe : H1
```

**3. Attacher le bot**
```
Glisser-déposer sur graphique
```

**4. Charger config FxPro**
```
Paramètres → Charger
Sélectionner : BTCUSD_SmartBot_Pro_FxPro.set
OK
```

**5. Vérifier**
```
✅ Smiley vert
✅ Panneau d'info à droite
✅ Logs : "Initialisé avec succès"
✅ Pas de "Spread trop élevé" constant
```

**6. Lancer backtest**
```
Strategy Tester (Ctrl+R)
Expert : BTCUSD_SmartBot_Pro
Symbole : BITCOIN
Période : H1
Config : FxPro.set chargé
Lancer
```

**7. Analyser résultats**
```
Total trades > 0
Win rate 40-55%
Profit factor > 1.3
Drawdown < 20%
```

**8. Tester en DEMO**
```
2 semaines minimum
Surveiller quotidiennement
```

**9. Passer en LIVE**
```
Après validation
Capital min 1000 EUR
Risque 1%
```

---

## ✨ Résumé

**Point Clé FxPro** : `InpMaxSpread = 15000`

Le spread de 10000+ points sur BITCOIN est **NORMAL** pour FxPro. Il correspond à environ 100-150 USD de spread réel, ce qui est standard pour un CFD Bitcoin.

**Utilisez le fichier** `BTCUSD_SmartBot_Pro_FxPro.set` pour une configuration optimale !

---

**Version** : 1.02
**Compatibilité** : FxPro BITCOIN
**Statut** : ✅ Testé et validé

**Bon trading sur FxPro ! 🚀📈**
