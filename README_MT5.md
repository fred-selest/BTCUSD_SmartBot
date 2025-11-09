# 🤖 BTCUSD SmartBot Pro - MetaTrader 5

**Bot de Trading Intelligent pour BTCUSD sur MetaTrader 5**

Compatible avec VPS Windows Server 2022 et Windows 10/11

---

## 📋 Vue d'Ensemble

BTCUSD SmartBot Pro est un Expert Advisor (EA) professionnel pour MetaTrader 5 qui implémente une stratégie de trading automatisée basée sur :

- ✅ **Croisement d'EMA (9/21)** - Signaux d'entrée précis
- ✅ **ATR Dynamique** - Stop Loss et Take Profit adaptatifs
- ✅ **Multi-Timeframe** - Confirmation H4 pour plus de précision
- ✅ **Trailing Stop Intelligent** - Protection et maximisation des profits
- ✅ **Risk Management** - Calcul automatique de la taille de position (1% risque)
- ✅ **Filtres Avancés** - Spread, volatilité, heures de trading
- ✅ **Interface Visuelle** - Panneau d'information en temps réel

---

## 🚀 Installation Rapide

### 1️⃣ Télécharger les Fichiers

Téléchargez depuis ce repository :
- `BTCUSD_SmartBot_Pro.mq5` (fichier principal du bot)
- `BTCUSD_SmartBot_Pro_Default.set` (paramètres par défaut)
- `GUIDE_INSTALLATION_MT5.md` (guide complet)

### 2️⃣ Installer dans MT5

1. Ouvrez MetaTrader 5
2. **Fichier → Ouvrir le dossier de données**
3. Naviguez vers `MQL5 → Experts`
4. Copiez `BTCUSD_SmartBot_Pro.mq5` dans ce dossier
5. Dans MT5, **Navigateur (Ctrl+N) → Expert Advisors → Actualiser**

### 3️⃣ Compiler

1. Ouvrez **MetaEditor (F4)**
2. Ouvrez `BTCUSD_SmartBot_Pro.mq5`
3. Cliquez sur **Compiler (F7)**
4. Vérifiez : "0 erreur(s), 0 avertissement(s)"

### 4️⃣ Configurer

1. Ouvrez un graphique **BTCUSD H1**
2. Glissez-déposez le bot sur le graphique
3. Chargez le fichier `.set` via **"Charger"** dans les paramètres
4. ✅ Cochez **"Autoriser le trading en direct"**
5. Cliquez sur **OK**

### 5️⃣ Activer

- Cliquez sur le bouton **AutoTrading** dans la barre d'outils (ou Alt+A)
- Le bouton doit être **VERT**
- Un **smiley vert 😊** apparaît sur le graphique

---

## 📦 Fichiers Inclus

| Fichier | Description |
|---------|-------------|
| `BTCUSD_SmartBot_Pro.mq5` | Expert Advisor principal |
| `BTCUSD_SmartBot_Pro_Default.set` | Paramètres recommandés (défaut) |
| `BTCUSD_SmartBot_Pro_Conservative.set` | Configuration conservatrice (0.5% risque) |
| `BTCUSD_SmartBot_Pro_Aggressive.set` | Configuration agressive (2% risque) |
| `GUIDE_INSTALLATION_MT5.md` | Guide complet d'installation et utilisation |
| `README_MT5.md` | Ce fichier |

---

## ⚙️ Paramètres Principaux

### 🛡️ Gestion du Risque

| Paramètre | Par Défaut | Description |
|-----------|------------|-------------|
| **Risque par trade** | 1.0% | Pourcentage du capital risqué par position |
| **Nombre max positions** | 1 | Positions simultanées maximum |
| **Balance minimum** | 100 USD | Arrêt si balance inférieure |

### 📊 Stratégie

| Paramètre | Par Défaut | Description |
|-----------|------------|-------------|
| **EMA Rapide** | 9 | Période de l'EMA courte |
| **EMA Lente** | 21 | Période de l'EMA longue |
| **Période ATR** | 14 | Période de calcul de volatilité |
| **Multiplicateur TP** | 2.5 | Take Profit = ATR × 2.5 |
| **Multiplicateur SL** | 1.5 | Stop Loss = ATR × 1.5 |

### 🎯 Trailing Stop

| Paramètre | Par Défaut | Description |
|-----------|------------|-------------|
| **Activer Trailing** | ON | Active/désactive le trailing stop |
| **Activation** | 1.0% | Profit requis pour activer |
| **Distance** | 0.5% | Distance de suivi du prix |
| **Breakeven** | ON | Déplacement du SL à l'entrée |
| **Trigger Breakeven** | 0.5% | Profit pour activer breakeven |

---

## 📊 Interface Utilisateur

Le bot affiche un panneau d'information en temps réel :

```
🤖 BTCUSD SmartBot Pro
💰 Balance: 10000.00 USD
💎 Equity: 10150.00 USD
📊 Positions: 1/1
📡 Spread: 25 pts [VERT = OK]
📈 ATR: 127.45 USD [VERT = Suffisant]
🎯 Tendance: HAUSSIERE [VERT = Buy, ROUGE = Sell]
```

---

## 🎓 Fonctionnement

### Logique de Trading

1. **Attente nouvelle bougie H1**
2. **Vérification filtres** :
   - ✅ Spread < 100 points
   - ✅ ATR > 50 USD
   - ✅ Dans heures de trading
3. **Calcul indicateurs** :
   - EMA 9 et 21 sur H1
   - ATR 14
   - Tendance H4
4. **Détection signal** :
   - 🟢 **BUY** : EMA 9 croise au-dessus EMA 21
   - 🔴 **SELL** : EMA 9 croise en-dessous EMA 21
5. **Confirmation H4** :
   - Trade seulement si tendance H4 confirmée
6. **Calcul position** :
   - SL = Prix ± (ATR × 1.5)
   - TP = Prix ± (ATR × 2.5)
   - Lot = (Balance × 1%) / Distance SL
7. **Exécution ordre**
8. **Gestion** :
   - Breakeven à +0.5% profit
   - Trailing à +1% profit

### Exemple de Trade

```
═══════════════════════════════════════════
🟢 Signal BUY détecté
   Entry: 45000.00
   SL: 44800.00 (200 USD de risque)
   TP: 45500.00 (500 USD de gain potentiel)
   Lot: 0.05 BTC
   ATR: 133.33
   Risk/Reward: 1:2.5

✅ Ordre BUY exécuté - Ticket: 123456789

[À +0.5% profit = 45225.00]
🎯 Breakeven activé | SL: 45000.00

[À +1% profit = 45450.00]
📈 Trailing activé | SL: 45225.00

[Prix monte à 45600.00]
📈 Trailing update | SL: 45375.00

[TP atteint ou trailing stop]
✅ Position fermée avec profit
═══════════════════════════════════════════
```

---

## 🔧 Configurations Prédéfinies

### 📘 Configuration par Défaut (Équilibrée)

**Fichier** : `BTCUSD_SmartBot_Pro_Default.set`

- Risque : **1.0%** par trade
- Positions max : **1**
- Confirmation H4 : **ON**
- Trading : **24h/24**

👉 **Recommandé pour débuter**

### 🛡️ Configuration Conservative (Sécurisée)

**Fichier** : `BTCUSD_SmartBot_Pro_Conservative.set`

- Risque : **0.5%** par trade (réduit)
- SL plus large : **ATR × 2.0**
- ATR minimum : **60 USD** (sélectif)
- Spread max : **80 points** (strict)
- Trading : **8h-20h** (heures actives)
- Trailing activation : **1.5%** (plus tard)

👉 **Pour trading prudent et capital limité**

### ⚡ Configuration Aggressive (Performante)

**Fichier** : `BTCUSD_SmartBot_Pro_Aggressive.set`

⚠️ **ATTENTION : Plus de risque !**

- Risque : **2.0%** par trade (élevé)
- Positions max : **2** (simultanées)
- Confirmation H4 : **OFF** (plus de signaux)
- ATR minimum : **30 USD** (moins sélectif)
- TP plus élevé : **ATR × 3.0**
- Trailing activation : **0.7%** (rapide)

👉 **Uniquement pour traders expérimentés**

---

## 🧪 Test et Validation

### ⚠️ OBLIGATOIRE : Test en DEMO

**NE JAMAIS lancer directement en LIVE !**

#### Phase 1 : Démo (2 semaines minimum)

1. ✅ Compte démo avec 10 000 USD
2. ✅ Configuration par défaut
3. ✅ Surveiller quotidiennement
4. ✅ Noter les performances :
   - Win rate (taux de victoire)
   - Profit factor
   - Maximum drawdown
   - Nombre de trades

#### Phase 2 : Micro-Live (optionnel, 2 semaines)

1. ✅ Compte live avec 500-1000 USD
2. ✅ Risque réduit à 0.5%
3. ✅ Lots minimum
4. ✅ Valider comportement réel

#### Phase 3 : Live Normal

1. ✅ Performances validées en démo
2. ✅ Capital suffisant (1000+ USD)
3. ✅ Risque 1-2% maximum
4. ✅ VPS configuré

### 📊 Performances Attendues

**Caractéristiques typiques** (peuvent varier) :

- **Win Rate** : 40-55%
- **Risk/Reward** : 1:1.67 (favorable)
- **Holding Time** : Quelques heures à 2-3 jours
- **Trades/mois** : 5-15 (selon volatilité)
- **Maximum Drawdown** : 10-20%

**Conditions optimales** :
- Marchés tendanciels (hausse ou baisse claire)
- Volatilité modérée (ATR 80-150 USD)
- Spreads faibles (< 50 points)

---

## 🖥️ Configuration VPS

### Pourquoi un VPS ?

- ✅ **Disponibilité 24/7** - Pas d'interruption
- ✅ **Connexion stable** - Latence faible
- ✅ **Exécution rapide** - Proche des serveurs de brokers
- ✅ **Pas de coupure** - Pas de problèmes électriques/internet

### Spécifications Recommandées

**VPS Windows**
- OS : Windows Server 2022 (ou 2019/2016)
- RAM : 2 GB minimum (4 GB recommandé)
- CPU : 2 cores minimum
- Stockage : 30 GB SSD
- Bande passante : 1 Mbps minimum
- Localisation : Proche du serveur broker

**Fournisseurs Recommandés**
- VPS Forex dédiés (VultrForex, ForexVPS, BeeksVPS)
- Azure/AWS (plus cher mais fiable)
- Contabo (économique)

### Configuration VPS

1. **Installation MT5**
   - Télécharger depuis le site du broker
   - Installer sur le VPS

2. **Démarrage automatique**
   - Fichier → Options → Serveur → "Se connecter au démarrage"
   - Ajouter MT5 au démarrage Windows

3. **Profil persistant**
   - Ouvrir BTCUSD H1 avec bot attaché
   - Fichier → Profils → Enregistrer
   - Au démarrage : charger ce profil automatiquement

4. **Surveillance**
   - Accéder au VPS via Remote Desktop quotidiennement
   - Vérifier logs et performances

---

## 🔒 Sécurité et Bonnes Pratiques

### Protection du Compte

1. **Stop Loss Toujours Actifs**
   - ❌ Ne JAMAIS désactiver les SL du bot
   - ✅ Chaque trade a SL et TP

2. **Risque Limité**
   - Maximum recommandé : **2% par trade**
   - Débutants : **0.5-1%**
   - Jamais plus de **5%** (dangereux)

3. **Drawdown Maximum**
   - Définir une limite (ex: -20%)
   - Si atteinte → **ARRÊTER** le bot
   - Analyser et ajuster

4. **Capital Dédié**
   - Ne trader qu'avec argent "à risque"
   - Jamais avec argent nécessaire à la vie
   - Capital minimum recommandé : **1000 USD**

### Monitoring Quotidien

**Checklist journalière** :
- [ ] VPS en ligne et connecté
- [ ] MT5 connecté au serveur
- [ ] Bot actif (smiley vert)
- [ ] Pas d'erreurs dans logs
- [ ] Positions cohérentes
- [ ] Balance/Equity normaux

---

## 🐛 Problèmes Courants

### Le bot ne s'active pas

**Symptômes** : Croix rouge ❌ sur le graphique

**Solutions** :
1. Activer **AutoTrading** (bouton dans barre d'outils)
2. Paramètres bot → Cocher "Autoriser trading en direct"
3. Outils → Options → Expert Advisors → Tout cocher

### Aucun ordre exécuté

**Causes possibles** :
- 📡 **Spread trop élevé** → Vérifier panneau
- 📉 **ATR trop faible** → Manque de volatilité
- 📊 **Pas de signal** → Attendre croisement EMA
- 🔒 **Position déjà ouverte** → Max 1 par défaut
- ⏰ **Hors heures** → Vérifier paramètres horaires
- ❌ **Pas confirmation H4** → Tendance contraire

**Action** : Lire les messages dans l'onglet "Experts"

### Erreur "Invalid stops"

**Cause** : SL/TP trop proche du prix actuel

**Solutions** :
1. Augmenter **Multiplicateur SL** (ex: 2.0)
2. Vérifier niveau minimum SL du broker
3. Contacter broker si problème persiste

### Trailing stop ne fonctionne pas

**Vérifications** :
1. ✅ Paramètre "Activer Trailing" = true
2. ✅ Profit doit atteindre 1% minimum
3. ✅ Bot doit être actif sur graphique
4. ✅ Lire logs pour messages trailing

---

## 📈 Optimisation

### Adapter aux Conditions de Marché

**Marché très volatil** (ATR > 150 USD)
```
ATR minimum         : 75-100
Multiplicateur SL   : 2.0 (plus large)
Multiplicateur TP   : 3.0 (profiter)
Distance trailing   : 0.7-1.0%
```

**Marché calme** (ATR < 80 USD)
```
ATR minimum         : 30-40
Multiplicateur SL   : 1.2 (serré)
Multiplicateur TP   : 2.0
Distance trailing   : 0.3%
```

**Marché haussier fort**
```
Confirmation H4     : true
Multiplicateur TP   : 3.0
Trailing activation : 0.7%
```

**Marché latéral**
```
ATR minimum         : 60+ (sélectif)
Confirmation H4     : true (obligatoire)
Risque par trade    : 0.5% (prudent)
```

### Backtesting

1. Dans MT5, ouvrez **Strategy Tester** (Ctrl+R)
2. Sélectionnez **BTCUSD_SmartBot_Pro**
3. Symbole : **BTCUSD**
4. Période : **H1**
5. Dates : 6-12 mois minimum
6. Modèle : **Tous les ticks** (précis)
7. Cliquez sur **Démarrer**

**Analysez** :
- Total trades
- Win rate
- Profit factor (> 1.5 bon)
- Maximum drawdown (< 20% excellent)
- Sharpe ratio

---

## 📞 Support

### Obtenir de l'Aide

**En cas de problème**, fournissez :

1. **Logs** : Onglet "Experts" → Copier 50 dernières lignes
2. **Screenshot** : Paramètres du bot + panneau info
3. **Informations** :
   - Broker
   - Symbole exact
   - MT5 Build
   - Type de compte

### Resources

- 📖 **Guide complet** : `GUIDE_INSTALLATION_MT5.md`
- 💻 **Code source** : `BTCUSD_SmartBot_Pro.mq5`
- 🐛 **Issues GitHub** : [Ouvrir un ticket](https://github.com/fred-selest/BTCUSD_SmartBot/issues)
- 📧 **Email** : support@example.com

---

## ⚖️ Licence et Disclaimer

### Licence

Ce projet est sous licence **MIT** - voir fichier `LICENSE`

### ⚠️ DISCLAIMER IMPORTANT

```
╔═══════════════════════════════════════════════════════════╗
║                   ⚠️  AVERTISSEMENT                        ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║  • Le trading comporte des RISQUES FINANCIERS ÉLEVÉS      ║
║  • Les performances passées ne garantissent PAS le futur  ║
║  • Ne tradez JAMAIS avec argent nécessaire à la vie       ║
║  • TESTEZ TOUJOURS en DEMO avant LIVE                     ║
║  • Les auteurs ne sont PAS responsables des pertes        ║
║  • Utilisez à VOS PROPRES RISQUES                         ║
║                                                            ║
║          Consultez un conseiller financier                ║
║                                                            ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🎯 Checklist Avant Live Trading

- [ ] ✅ **Testé en DEMO 2+ semaines** avec succès
- [ ] ✅ **Win rate > 40%** validé
- [ ] ✅ **Drawdown < 20%** en démo
- [ ] ✅ **VPS configuré** et stable
- [ ] ✅ **Connexion testée** (ping < 50ms)
- [ ] ✅ **Capital minimum 1000 USD**
- [ ] ✅ **Risque 1% configuré**
- [ ] ✅ **Paramètres optimisés** pour broker
- [ ] ✅ **Tous les paramètres compris**
- [ ] ✅ **Plan monitoring** défini
- [ ] ✅ **Drawdown max décidé** (ex: -20%)
- [ ] ✅ **Trailing stop testé**
- [ ] ✅ **Logs vérifiés** sans erreurs
- [ ] ✅ **Risques acceptés** ⚠️

---

## 📊 Historique des Versions

### Version 1.00 (2025-01)

**Première version stable**

✨ **Fonctionnalités** :
- Stratégie EMA 9/21 avec croisements
- ATR dynamique pour SL/TP
- Trailing stop intelligent
- Breakeven automatique
- Confirmation multi-timeframe H4
- Risk management 1%
- Panneau d'information
- Filtres spread/volatilité/heures

📦 **Fichiers inclus** :
- Expert Advisor MQ5
- 3 fichiers SET (Default, Conservative, Aggressive)
- Guide d'installation complet
- Documentation

---

**Bon trading ! 🚀📈**

*La clé du succès : Patience, Discipline et Risk Management*
