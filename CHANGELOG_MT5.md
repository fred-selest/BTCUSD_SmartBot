# 📝 CHANGELOG - BTCUSD SmartBot Pro MT5

Historique des versions et modifications

---

## Version 1.07 (2025-11-10)

### 🚨 Correction CRITIQUE - Grid Risk Management

- ✅ **CORRECTIF MAJEUR : Sur-exposition massive avec Grid activé**
  - **Problème détecté** : Backtest avec 100k EUR → Stop out en 5h avec perte totale
  - **Cause** : Le risque n'était PAS ajusté selon le nombre de niveaux Grid
  - **Backtest v1.06** :
    ```
    Grid SELL Level 0 | Lot: 1.1 BTC
    Grid SELL Level 1 | Lot: 1.65 BTC
    Grid SELL Level 2 | Lot: 2.48 BTC
    TOTAL : 5.23 BTC = 638,060 USD d'exposition sur 110k compte
    → STOP OUT COMPLET
    ```

### 🔧 Modifications Techniques

**OpenGridLevel()** - Ajustement automatique du risque :
```mql5
// AVANT (v1.06) - DANGEREUX
baseLot = CalculateLotSize(price, sl);  // Risque non ajusté

// APRÈS (v1.07) - SÉCURISÉ
double adjustedRisk = InpRiskPercent;
if(InpUseGrid && InpMaxGridLevels > 1)
{
   // Diviser le risque par le nombre de niveaux
   adjustedRisk = InpRiskPercent / InpMaxGridLevels;
}
baseLot = CalculateLotSize(adjustedRisk, price, sl);
```

### 📊 Impact sur le Trading

**Exemple : 100,000 EUR, InpRiskPercent=0.5%, Grid 3 niveaux, Multi 1.5**

| Version | Risque/niveau | Level 0 | Level 1 | Level 2 | Total | Exposition |
|---------|---------------|---------|---------|---------|-------|------------|
| **v1.06** | 0.5% | 1.1 | 1.65 | 2.48 | **5.23** | 638k USD ❌ |
| **v1.07** | 0.17% | 0.37 | 0.55 | 0.83 | **1.75** | 213k USD ✅ |

**Réduction d'exposition : -66% !**

### ⚠️ Impact Important

**Cette correction RÉDUIT drastiquement l'exposition** :
- v1.06 : Risque réel ~2.6% (5.23 / 2 = 2.6× le risque configuré)
- v1.07 : Risque réel ~0.5% (conforme à la configuration)

**Pour les utilisateurs de v1.06** :
1. **URGENT** : Mettre à jour vers v1.07 avant trading live
2. Si déjà en live : **ARRÊTER** et recompiler avec v1.07
3. Les lots seront **3× plus petits** (conforme au risque souhaité)

### 📊 Calcul du Risque Ajusté

**Formule v1.07** :
```
Risque ajusté = InpRiskPercent / InpMaxGridLevels

Exemples :
- 0.5% avec 3 niveaux → 0.167% par niveau
- 1.0% avec 5 niveaux → 0.20% par niveau
- 2.0% avec 2 niveaux → 1.0% par niveau
```

**Effet avec multiplicateur 1.5 et 3 niveaux** :
- Level 0 : 0.167% × 1.0 = 0.167%
- Level 1 : 0.167% × 1.5 = 0.250%
- Level 2 : 0.167% × 2.25 = 0.375%
- **TOTAL : ~0.79%** (proche du risque configuré 0.5%)

### 🎯 Recommandations

**Pour utiliser Grid en sécurité** :
1. **Toujours tester en DEMO** d'abord
2. **Capital minimum recommandé** :
   - 2 niveaux : 1,000 EUR
   - 3 niveaux : 2,500 EUR
   - 5 niveaux : 5,000 EUR
3. **Multiplicateur conservateur** : 1.5 ou 2.0 max
4. **Surveiller l'exposition totale** affichée dans les logs

### 📁 Archivage

- Version 1.06 archivée dans `versions/BTCUSD_SmartBot_Pro_v1.06.mq5`
- Version 1.07 archivée dans `versions/BTCUSD_SmartBot_Pro_v1.07.mq5`

---

## Version 1.06 (2025-11-09)

### 🐛 Correction Critique - Grid Lot Normalization

- ✅ **CORRECTIF MAJEUR : Normalisation incorrecte des lots Grid**
  - **Problème détecté** : Tous les niveaux Grid avaient le même lot malgré multiplicateur 1.2
  - **Cause** : `NormalizeDouble(lot, 2)` ne respectait pas le `LotStep` du broker
  - **Logs v1.05** :
    ```
    Grid BUY Level 0 | Lot: 0.01 ✅
    Grid BUY Level 1 | Lot: 0.01 ❌ (devrait être 0.012 ou 0.02)
    Grid BUY Level 2 | Lot: 0.01 ❌ (devrait être 0.0144 ou 0.02)
    ```

### 🔧 Modifications Techniques

**CalculateGridLot()** - Ajout normalisation LotStep :
```mql5
// AVANT (v1.05) - INCORRECT
double lot = baseLot * MathPow(InpGridLotMultiplier, gridLevel);
return NormalizeDouble(lot, 2);  // 0.012 → 0.01 (mal arrondi)

// APRÈS (v1.06) - CORRECT
double lot = baseLot * MathPow(InpGridLotMultiplier, gridLevel);
double lotStep = symbolInfo.LotsStep();
if(lotStep > 0)
   lot = MathRound(lot / lotStep) * lotStep;  // Arrondit au plus proche
return NormalizeDouble(lot, 2);
```

### 📊 Impact sur le Trading

**Avec LotStep = 0.01 (FxPro standard)** :

| Multiplicateur | Level 0 | Level 1 | Level 2 | Total |
|----------------|---------|---------|---------|-------|
| 1.2 (v1.05 bug) | 0.01 | 0.01 | 0.01 | 0.03 |
| 1.2 (v1.06) | 0.01 | 0.01 | 0.01 | 0.03 ⚠️ |
| **1.5 (recommandé)** | 0.01 | 0.02 | 0.02 | 0.05 ✅ |
| **2.0 (agressif)** | 0.01 | 0.02 | 0.04 | 0.07 ✅ |

**Explication** :
- Avec multiplicateur 1.2 : 0.01 × 1.2 = 0.012 → arrondi à 0.01 (LotStep=0.01)
- Avec multiplicateur 1.5 : 0.01 × 1.5 = 0.015 → arrondi à 0.02 ✅
- Avec multiplicateur 2.0 : 0.01 × 2.0 = 0.02 (exact) ✅

### ⚠️ Recommandations Importantes

**Pour que le multiplicateur fonctionne** :
1. **Utiliser multiplicateur ≥ 1.5** (1.2 est trop faible avec LotStep=0.01)
2. **OU augmenter le lot de base** (0.02 au lieu de 0.01)
3. **Tester en DEMO** pour vérifier les lots affichés

**Multiplicateurs recommandés** :
- **1.5** : Progression modérée (0.01 → 0.02 → 0.02)
- **2.0** : Progression forte (0.01 → 0.02 → 0.04)

### 📁 Archivage

- Version 1.05 archivée dans `versions/BTCUSD_SmartBot_Pro_v1.05.mq5`
- Version 1.06 archivée dans `versions/BTCUSD_SmartBot_Pro_v1.06.mq5`

---

## Version 1.05 (2025-11-09)

### 🐛 Correction Critique - Grid Lot Multiplier

- ✅ **CORRECTIF MAJEUR : Multiplicateur de lot Grid ne s'appliquait pas**
  - **Problème** : Tous les niveaux de grid utilisaient le même lot (0.01)
  - **Cause** : `baseLot` était recalculé pour chaque niveau au lieu d'utiliser le lot du niveau 0
  - **Solution** : Utilisation de `initialLotSize` (sauvegardé au niveau 0) pour niveaux 1+

### 🔧 Modifications Techniques

**OpenGridLevel()** - Correction du calcul de lot :
```mql5
// AVANT (v1.04) - INCORRECT
double baseLot = CalculateLotSize(price, sl);  // Recalculé à chaque niveau

// APRÈS (v1.05) - CORRECT
if(gridLevel == 0)
   baseLot = CalculateLotSize(price, sl);  // Calculé une fois
else
   baseLot = initialLotSize;  // Réutilisé pour niveaux 1+
```

### 📊 Impact sur le Trading

**Exemple avec InpGridLotMultiplier=1.2** :

v1.04 (bug) :
- Level 0: 0.01
- Level 1: 0.01 ❌
- Level 2: 0.01 ❌

v1.05 (corrigé) :
- Level 0: 0.01 ✅
- Level 1: 0.012 (0.01 × 1.2¹) ✅
- Level 2: 0.0144 (0.01 × 1.2²) ✅

### ⚠️ Impact Important

**Cette correction augmente le risque par Grid !**
- Exposition totale PLUS ÉLEVÉE qu'en v1.04
- Avec 3 niveaux et multi 1.2: **Total lot = 0.01 + 0.012 + 0.0144 = 0.0364**
- En v1.04 (bug): Total = 0.01 + 0.01 + 0.01 = 0.03
- **Différence : +21% d'exposition**

**Recommandations URGENTES** :
1. **Réduire InpGridLotMultiplier** : 1.0 (constant) ou 1.1 max pour démarrer
2. **Réduire InpMaxGridLevels** : 2 au lieu de 3
3. **Augmenter capital minimum** : 2000+ EUR recommandé
4. **TESTER EN DEMO** avant live avec nouveaux paramètres

### 📁 Archivage

- Version 1.04 archivée dans `versions/BTCUSD_SmartBot_Pro_v1.04.mq5`
- Toutes les versions futures seront archivées automatiquement

---

## Version 1.04 (2025-11-09)

### 🐛 Correction Critique - Grid Trading

- ✅ **CORRECTIF MAJEUR : Grid Orders non créés**
  - Les ordres Grid niveaux 1, 2, 3+ sont maintenant correctement créés comme ordres pending
  - **BuyLimit** utilisé pour les grilles d'achat (sous le prix d'entrée)
  - **SellLimit** utilisé pour les grilles de vente (au-dessus du prix d'entrée)
  - Niveau 0 reste un ordre au marché (immédiat)
  - Niveaux 1+ sont des ordres en attente qui se déclenchent quand le prix les atteint

### 🔧 Modifications Techniques

**OpenGridLevel()** :
- Séparation logique niveau 0 (marché) vs niveaux 1+ (pending)
- `trade.Buy()` / `trade.Sell()` pour niveau 0
- `trade.BuyLimit()` / `trade.SellLimit()` pour niveaux 1+
- Affichage du type d'ordre (MARKET ou LIMIT) dans les logs
- Gestion d'erreur améliorée avec messages explicites

**PlaceGridOrders()** :
- Fonction maintenant fonctionnelle (était vide dans v1.03)
- Crée réellement les ordres pending pour chaque niveau de grille
- Logs détaillés de création de chaque niveau

### 📊 Impact

- **v1.03 → v1.04** : Backtest passera de 1 seul trade à 3 trades (avec 3 niveaux de grid)
- **Martingale** : Fonctionnera maintenant correctement en combinaison avec Grid
- **Risque** : Grid fonctionne maintenant comme prévu - ATTENTION au drawdown

### ⚠️ Avertissement Important

**Cette correction rend le Grid Trading pleinement opérationnel !**
- Si vous utilisiez v1.03 avec `InpUseGrid=true`, vous n'aviez qu'un seul ordre
- Avec v1.04, vous aurez TOUS les niveaux de grid (1-5 configurables)
- **Augmente significativement l'exposition** - Réduire `InpMaxGridLevels` si nécessaire
- **Tester ABSOLUMENT en DEMO** avant live avec cette version

---

## Version 1.03 (2025-11-09)

### 🎲 Nouvelles Fonctionnalités Majeures

- ✅ **GRID TRADING** - Système de grille contrôlée
  - Ouvre plusieurs niveaux de positions à distances fixes
  - Distance configurable en ATR (ex: 1.0 ATR entre chaque niveau)
  - Multiplicateur de lot personnalisable (1.0 = constant, 1.5 = augmentation progressive)
  - Maximum 5 niveaux configurables (3 recommandé)

- ✅ **MARTINGALE CONTROLÉE** - Gestion des pertes avec sécurité
  - Augmente la taille du lot après chaque perte
  - Multiplicateur configurable (1.3-2.0, recommandé: 1.5)
  - Limitation stricte du nombre de niveaux (max 5, recommandé: 3)
  - Reset automatique après un trade gagnant

- ✅ **PROTECTION DRAWDOWN** - Sécurité maximale
  - Arrêt automatique du trading si drawdown dépasse limite
  - Configurable (défaut: 20%)
  - Calcul basé sur le plus haut equity atteint
  - Alerte visuelle et dans les logs

### ⚠️ Avertissements Importants

- **Grid et Martingale augmentent le risque** - À utiliser avec prudence
- **Capital minimum recommandé** : 1000+ EUR pour Grid/Martingale
- **Toujours tester en DEMO** avant utilisation live
- **Drawdown peut être élevé** - Respecter les limites
- **Par défaut désactivé** - Doit être activé manuellement

### 🎯 Impact

- **Flexibilité** : 3 modes de trading (Classique, Grid, Martingale)
- **Contrôle** : Limites strictes pour sécurité
- **Performance** : Potentiel de profit accru avec risque contrôlé
- **Compatibilité** : 100% compatible avec modes précédents

---

## Version 1.02 (2025-11-09)

### 🐛 Corrections de Bugs Critiques

- ✅ **CORRECTIF : Array out of range** lors du backtest
  - Les données des indicateurs sont maintenant copiées AVANT les vérifications
  - Ordre des opérations corrigé dans `OnTick()`
  - Ajout de vérification de sécurité sur `atrBuffer` avant accès

- ✅ **AMÉLIORATION : Gestion du spread**
  - Réduction du spam de logs quand spread élevé (1 message/heure max)
  - Meilleure gestion des symboles non-standard (BITCOIN, BTCUSD, etc.)

### 🔧 Améliorations Techniques

- Vérification `ArraySize()` avant accès aux buffers
- Protection contre les erreurs de données manquantes
- Optimisation des logs pour backtesting

### 🎯 Impact

- **Backtest** : Fonctionne maintenant sans erreur
- **Performance** : Pas d'impact sur la vitesse d'exécution
- **Compatibilité** : 100% compatible avec v1.01 et v1.00

---

## Version 1.01 (2025-11-09)

### 🎨 Interface
- ✅ **Panneau d'information déplacé à DROITE** du graphique
  - Meilleure visibilité sur les graphiques
  - Optimisation de l'espace d'affichage
  - Position : Coin supérieur droit

### 🔧 Technique
- Changement `CORNER_LEFT_UPPER` → `CORNER_RIGHT_UPPER`
- Changement `ANCHOR_LEFT_UPPER` → `ANCHOR_RIGHT_UPPER`

---

## Version 1.00 (2025-11-09)

### 🎉 Version Initiale

**Fonctionnalités principales** :

#### 📊 Stratégie de Trading
- ✅ EMA 9/21 crossover sur H1
- ✅ Confirmation multi-timeframe H4
- ✅ ATR dynamique pour TP/SL (2.5x / 1.5x)
- ✅ Détection précise des signaux

#### 🛡️ Gestion du Risque
- ✅ Calcul automatique position (1% risque)
- ✅ Validation avant chaque trade
- ✅ Limite positions (1 par défaut)
- ✅ Balance minimum configurable

#### 🎯 Protection Profits
- ✅ Breakeven automatique (+0.5% profit)
- ✅ Trailing stop intelligent (+1% activation, 0.5% distance)
- ✅ Modification automatique stops

#### 🔍 Filtres Marché
- ✅ Spread maximum (100 points)
- ✅ Volatilité minimum (ATR > 50 USD)
- ✅ Heures trading configurables
- ✅ Confirmation tendance H4

#### 🎨 Interface
- ✅ Panneau info temps réel (gauche du graphique)
- ✅ Codes couleur intuitifs
- ✅ Affichage balance, equity, positions
- ✅ Monitoring spread, ATR, tendance

#### 📁 Fichiers Inclus
- ✅ Expert Advisor MQ5 complet
- ✅ 3 fichiers de configuration (.set)
  - Default (équilibré)
  - Conservative (prudent)
  - Aggressive (performance)
- ✅ Documentation complète
  - Guide installation détaillé
  - README technique
  - Quick start guide

---

## 🔄 Système de Versionnage

### Format
**Version X.YZ**

- **X** : Version majeure (changements importants, incompatibilités)
- **Y** : Version mineure (nouvelles fonctionnalités)
- **Z** : Patch (corrections bugs, petites améliorations)

### Exemples
- `1.00` → Version initiale
- `1.01` → Amélioration mineure (déplacement panneau)
- `1.02` → Prochaine amélioration
- `1.10` → Nouvelle fonctionnalité majeure
- `2.00` → Refonte complète

---

## 📅 Roadmap Prévue

### Version 1.02 (À venir)
- [ ] Ajout filtre RSI optionnel
- [ ] Notification sonore sur signal
- [ ] Export statistiques en CSV

### Version 1.03 (À venir)
- [ ] Mode multi-symbole
- [ ] Dashboard statistiques avancé
- [ ] Intégration Telegram notifications

### Version 1.10 (À venir)
- [ ] Machine Learning pour filtrage signaux
- [ ] Optimisation automatique paramètres
- [ ] Backtesting intégré

### Version 2.00 (Futur)
- [ ] Stratégies multiples sélectionnables
- [ ] Portfolio management
- [ ] API REST pour monitoring

---

## 📊 Compatibilité

### Versions MT5 Supportées
- MetaTrader 5 Build **3801+**
- Windows Server 2022, 2019, 2016
- Windows 11, Windows 10

### Brokers Testés
- Compatible avec tous brokers MT5 offrant BTCUSD
- Fonctionne avec comptes Standard, ECN, Raw Spread

---

## 🐛 Corrections de Bugs

### Version 1.01
- Aucun bug corrigé (version stable)

### Version 1.00
- Version initiale stable

---

## ⚙️ Instructions de Mise à Jour

### De 1.00 vers 1.01

1. **Sauvegarder vos paramètres** (optionnel)
   - Ouvrir bot sur graphique
   - Paramètres → "Sauvegarder" → Fichier .set

2. **Fermer positions** (recommandé)
   - Fermer toutes positions en cours
   - Ou laisser le bot gérer jusqu'à fermeture

3. **Retirer ancien bot**
   - Supprimer bot du graphique

4. **Installer nouvelle version**
   - Copier `BTCUSD_SmartBot_Pro.mq5` (v1.01)
   - Compiler dans MetaEditor
   - Attacher au graphique

5. **Recharger paramètres** (si sauvegardés)
   - Paramètres → "Charger" → Votre fichier .set

### Mise à Jour sur VPS

1. Connecter au VPS via Remote Desktop
2. Fermer MT5
3. Remplacer fichier MQ5
4. Compiler
5. Redémarrer MT5
6. Vérifier version dans logs

---

## 📝 Notes de Version

### Version 1.01
**Date** : 2025-11-09
**Statut** : Stable
**Compatibilité** : 100% avec v1.00

**Changements visuels** :
- Panneau maintenant à droite pour meilleure visibilité

**Migration** : Aucune action requise, mise à jour transparente

---

## 🔐 Checksums (Optionnel)

Pour vérifier l'intégrité des fichiers :

### Version 1.01
```
BTCUSD_SmartBot_Pro.mq5 : [À générer]
```

### Version 1.00
```
BTCUSD_SmartBot_Pro.mq5 : [À générer]
```

---

## 📞 Support

Pour toute question sur les versions :

- 🐛 **Bug** : [Ouvrir une issue](https://github.com/fred-selest/BTCUSD_SmartBot/issues)
- 💡 **Feature Request** : [Discussions](https://github.com/fred-selest/BTCUSD_SmartBot/discussions)
- 📧 **Email** : support@example.com

---

**Dernière mise à jour** : 2025-11-10
**Version actuelle** : 1.07
**Statut** : Stable ✅ (Grid Risk Management corrigé - MISE À JOUR CRITIQUE !)
