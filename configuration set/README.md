# ⚙️ Fichiers de Configuration (.set) - BTCUSD SmartBot Pro

Ce dossier contient les fichiers de configuration prédéfinis pour MetaTrader 5.

## 📁 Configurations Disponibles

### 1. **Default** - Configuration Équilibrée
**Fichier** : `BTCUSD_SmartBot_Pro_Default.set`

Paramètres standards pour démarrer :
- Risque : 1% par trade
- Trailing Stop : Activé
- Grid/Martingale : Désactivé
- ATR TP/SL : 3.0x / 1.5x

**Recommandé pour** : Premier démarrage, trading standard

---

### 2. **Conservative** - Configuration Prudente
**Fichier** : `BTCUSD_SmartBot_Pro_Conservative.set`

Paramètres sécuritaires :
- Risque : 0.5% par trade
- Spread max : 80 points
- ATR minimum : 75 USD
- Protection renforcée

**Recommandé pour** : Comptes petits capitaux, débutants

---

### 3. **Aggressive** - Configuration Performance
**Fichier** : `BTCUSD_SmartBot_Pro_Aggressive.set`

Paramètres pour maximiser les gains :
- Risque : 2% par trade
- Trailing Stop : Plus agressif
- ATR TP : 4.0x
- Spread max : 150 points

**Recommandé pour** : Traders expérimentés, gros capitaux

---

### 4. **FxPro** - Configuration Broker FxPro
**Fichier** : `BTCUSD_SmartBot_Pro_FxPro.set`

Paramètres spéciaux pour FxPro BITCOIN symbol :
- **Spread max : 15000 points** (symbole BITCOIN a spread élevé ~100 USD)
- Risque : 1%
- Optimisé pour spread FxPro

**Recommandé pour** : Uniquement broker FxPro avec symbole BITCOIN

---

### 5. **Grid** - Grid Trading
**Fichier** : `BTCUSD_SmartBot_Pro_Grid.set`

Configuration Grid Trading uniquement :
- Grid : Activé (3 niveaux)
- Martingale : Désactivé
- Distance : 1.0 ATR
- Multiplicateur lot : 1.0 (constant)

**Recommandé pour** : Trading Grid seul, capital 1500+ EUR

---

### 6. **Martingale** - Martingale Contrôlée
**Fichier** : `BTCUSD_SmartBot_Pro_Martingale.set`

Configuration Martingale uniquement :
- Martingale : Activé (3 niveaux max)
- Multiplicateur : 1.5x
- Risque réduit : 0.5%
- Drawdown max : 15%

**Recommandé pour** : Trading Martingale seul, capital 1500+ EUR

---

### 7. **GridMartingale** - Combinaison (Risque Élevé)
**Fichier** : `BTCUSD_SmartBot_Pro_GridMartingale.set`

Configuration Grid + Martingale combinés :
- Grid : 3 niveaux × 1.2 multiplicateur
- Martingale : 1.3x
- Risque : 0.5%
- Drawdown max : 15%

**⚠️ ATTENTION** : Risque TRÈS élevé !
**Recommandé pour** : Traders experts uniquement, capital 2500+ EUR

---

## 🔧 Comment Utiliser ces Fichiers

### Installation dans MT5

1. **Copier le fichier .set** dans le dossier MT5 :
   ```
   C:\Users\VotreNom\AppData\Roaming\MetaQuotes\Terminal\[ID_TERMINAL]\MQL5\Presets\
   ```

2. **Ou charger directement** :
   - Ouvrir MT5
   - Glisser-déposer le bot sur le graphique
   - Dans la fenêtre de paramètres → Clic sur "Charger"
   - Sélectionner le fichier .set

3. **Vérifier les paramètres** avant de cliquer OK

4. **Tester en DEMO** d'abord !

---

## ⚠️ Avertissements Importants

### Capital Minimum Recommandé

| Configuration | Capital Min | Risque |
|---------------|-------------|---------|
| Default | 500 EUR | Moyen |
| Conservative | 300 EUR | Faible |
| Aggressive | 1000 EUR | Élevé |
| FxPro | 500 EUR | Moyen |
| Grid | 1500 EUR | Élevé |
| Martingale | 1500 EUR | Élevé |
| GridMartingale | 2500 EUR | TRÈS ÉLEVÉ |

### Conseils de Sécurité

1. **TOUJOURS tester en DEMO** avant live
2. **Adapter à votre broker** (spreads, symbole)
3. **Surveiller le drawdown** régulièrement
4. **Commencer petit** puis augmenter progressivement
5. **Ne jamais** risquer plus de 2% par trade

---

## 🎯 Quelle Configuration Choisir ?

### Pour Débutants
→ **Conservative** ou **Default**

### Pour Trading Standard
→ **Default** ou **FxPro** (si FxPro)

### Pour Maximiser Performance
→ **Aggressive** (si capital > 1000 EUR)

### Pour Grid Trading
→ **Grid** (tester d'abord, capital > 1500 EUR)

### Pour Martingale
→ **Martingale** (expérience requise, capital > 1500 EUR)

### Pour Experts Seulement
→ **GridMartingale** (capital > 2500 EUR, HAUTE PRUDENCE)

---

## 📊 Personnalisation

Vous pouvez créer votre propre configuration :

1. Charger une config existante
2. Modifier les paramètres
3. Tester en DEMO
4. Sauvegarder : "Sauvegarder" → `MonBot_Custom.set`

---

## 🔄 Mise à Jour

Ces configurations sont compatibles avec **BTCUSD SmartBot Pro v1.05+**

Si vous utilisez une version antérieure, mettez à jour le bot avant de charger ces fichiers.

---

## 📞 Support

Problème avec une configuration ?
- Consulter `CHANGELOG_MT5.md` pour changements récents
- Lire `README_MT5.md` pour documentation complète
- Vérifier `GUIDE_INSTALLATION_MT5.md` pour installation

---

**Dernière mise à jour** : 2025-11-09
**Version compatible** : 1.05+
