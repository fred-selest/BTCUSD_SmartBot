# 📝 CHANGELOG - BTCUSD SmartBot Pro MT5

Historique des versions et modifications

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

**Dernière mise à jour** : 2025-11-09
**Version actuelle** : 1.01
**Statut** : Stable ✅
