# 📘 Guide d'Installation - BTCUSD SmartBot Pro pour MetaTrader 5

## 🖥️ Configuration Requise

- **Système d'exploitation** : Windows Server 2022 (ou Windows 10/11)
- **MetaTrader 5** : Version Build 3801 ou supérieure
- **VPS/Serveur** :
  - RAM : 2 GB minimum (4 GB recommandé)
  - Processeur : 2 CPU cores minimum
  - Connexion Internet stable avec latence < 50ms
- **Broker** : Compte compatible avec BTCUSD
- **Capital minimum** : 500 USD recommandé

---

## 📥 Installation du Bot sur MetaTrader 5

### Étape 1 : Télécharger le fichier

1. Téléchargez le fichier **`BTCUSD_SmartBot_Pro.mq5`** depuis ce repository
2. Sauvegardez-le dans un dossier temporaire

### Étape 2 : Copier dans MetaTrader 5

**Méthode 1 - Via l'interface MT5 (Recommandé)**

1. Ouvrez MetaTrader 5
2. Cliquez sur **Fichier → Ouvrir le dossier de données**
3. Naviguez vers : `MQL5 → Experts`
4. Copiez le fichier `BTCUSD_SmartBot_Pro.mq5` dans ce dossier
5. Retournez dans MT5
6. Dans le **Navigateur** (Ctrl+N), cliquez-droit sur **Expert Advisors**
7. Sélectionnez **Actualiser**

**Méthode 2 - Chemin direct**

Copiez le fichier vers :
```
C:\Users\[VotreNom]\AppData\Roaming\MetaQuotes\Terminal\[ID_Terminal]\MQL5\Experts\
```

### Étape 3 : Compiler le Bot

1. Dans MetaTrader 5, ouvrez **MetaEditor** (F4)
2. Dans le **Navigateur**, ouvrez `Experts → BTCUSD_SmartBot_Pro.mq5`
3. Cliquez sur **Compiler** (F7) ou bouton "Compiler"
4. Vérifiez qu'il n'y a pas d'erreurs dans l'onglet **"Erreurs"**
5. Un message "0 erreur(s), 0 avertissement(s)" doit apparaître

✅ **Le fichier .ex5 est maintenant créé et prêt à l'emploi**

---

## 🚀 Configuration et Lancement

### Étape 1 : Préparer le Graphique

1. Ouvrez un graphique **BTCUSD**
2. Changez la période en **H1** (1 heure)
   - Clic droit sur le graphique → Période → H1
   - Ou utilisez le raccourci dans la barre d'outils
3. Assurez-vous que le graphique affiche au moins **200 bougies** d'historique

### Étape 2 : Attacher le Bot

1. Dans le **Navigateur** (Ctrl+N), trouvez **Expert Advisors**
2. Localisez **BTCUSD_SmartBot_Pro**
3. **Double-cliquez** sur le bot OU **glissez-déposez** sur le graphique
4. Une fenêtre de paramètres s'ouvre

### Étape 3 : Configurer les Paramètres

#### ⚙️ Paramètres Recommandés pour Débuter

**🛡️ GESTION DU RISQUE**
```
Risque par trade (% du capital)  : 1.0    (1% de risque par trade)
Nombre max de positions          : 1      (une seule position à la fois)
Balance minimum (USD)            : 100    (arrêt si balance < 100 USD)
```

**📊 PARAMETRES STRATEGIE**
```
EMA Rapide (période)            : 9       (EMA courte)
EMA Lente (période)             : 21      (EMA longue)
Période ATR                     : 14      (volatilité)
Multiplicateur TP (ATR x)       : 2.5     (Take Profit)
Multiplicateur SL (ATR x)       : 1.5     (Stop Loss)
```

**🔍 FILTRES DE TRADING**
```
ATR minimum (USD)               : 50.0    (volatilité minimum)
Spread maximum (points)         : 100     (spread max acceptable)
Heure début                     : 0       (0 = trading 24h/24)
Heure fin                       : 23      (23 = trading 24h/24)
```

**🎯 TRAILING STOP**
```
Activer Trailing Stop           : true    (recommandé)
Activation (% de profit)        : 1.0     (active à 1% de profit)
Distance de trailing (%)        : 0.5     (suit de 0.5%)
Activer Breakeven               : true    (recommandé)
Trigger Breakeven (% profit)    : 0.5     (breakeven à 0.5% profit)
```

**⚙️ PARAMETRES AVANCES**
```
Confirmation H4                 : true    (confirmation multi-timeframe)
Magic Number                    : 202511  (identifiant unique)
Slippage maximum                : 10      (glissement max)
Commentaire des trades          : BTC_Smart
Afficher panneau info           : true    (panneau d'information)
```

#### ✅ Onglet "Commun"

1. ✅ Cochez **"Autoriser le trading en direct"**
2. ✅ Cochez **"Autoriser l'import de DLL"** (si nécessaire)
3. ✅ Cochez **"Autoriser le trading automatique"**
4. ❌ Décochez **"Autoriser le trading lorsque le signal est reçu"**

### Étape 4 : Activer le Bot

1. Cliquez sur **OK** pour fermer la fenêtre
2. Vérifiez que dans le coin **supérieur droit** du graphique :
   - Un **smiley vert** 😊 apparaît (bot actif)
   - Si c'est une **croix rouge** ❌ : le trading automatique est désactivé
3. Pour activer le trading auto :
   - Cliquez sur le bouton **"AutoTrading"** dans la barre d'outils (raccourci : Alt+A)
   - Le bouton doit être **vert** et **enfoncé**

### Étape 5 : Vérification

1. Ouvrez l'onglet **"Experts"** en bas de MT5
2. Vous devriez voir les messages :
```
═══════════════════════════════════════════════════════
🤖 BTCUSD SmartBot Pro - Initialisé avec succès
═══════════════════════════════════════════════════════
📊 Symbole: BTCUSD
💰 Balance: 10000.00 USD
🎯 Risque par trade: 1.00%
...
```

3. Un **panneau d'information** apparaît en haut à gauche du graphique avec :
   - Balance et Equity en temps réel
   - Nombre de positions
   - Spread actuel
   - ATR et tendance

---

## 🧪 Test en Mode Démo (OBLIGATOIRE)

### ⚠️ AVANT LE TRADING LIVE

**NE JAMAIS lancer le bot directement en mode LIVE sans tests !**

1. **Ouvrez un compte démo** chez votre broker
2. **Installez le bot** comme décrit ci-dessus
3. **Laissez tourner pendant au moins 1-2 semaines**
4. **Surveillez les performances** :
   - Win rate (taux de réussite)
   - Drawdown maximum
   - Comportement du trailing stop
   - Réaction aux signaux

### Stratégie de Test Recommandée

**Semaine 1-2 : Test Démo**
- Capital démo : 10 000 USD
- Risque : 1%
- Surveiller quotidiennement

**Semaine 3-4 : Test Micro-Lot Live (optionnel)**
- Capital live minimal : 500 USD
- Risque : 0.5%
- Lots minimum

**À partir de la semaine 5 : Trading Normal**
- Une fois les performances validées
- Augmenter progressivement le risque
- Maximum 2% par trade recommandé

---

## 📊 Comprendre le Panneau d'Information

Le bot affiche en temps réel sur le graphique :

```
🤖 BTCUSD SmartBot Pro
💰 Balance: 10000.00 USD       ← Votre capital
💎 Equity: 10150.00 USD        ← Capital + P&L positions ouvertes
📊 Positions: 1/1              ← Positions actuelles / maximum
📡 Spread: 25 pts              ← Spread actuel (vert = OK, rouge = trop élevé)
📈 ATR: 127.45 USD             ← Volatilité actuelle
🎯 Tendance: HAUSSIERE         ← Direction EMA (vert = hausse, rouge = baisse)
```

### Codes Couleur

- 🟢 **Vert** : Conditions normales / favorables
- 🟡 **Jaune** : Attention / position ouverte
- 🟠 **Orange** : Avertissement
- 🔴 **Rouge** : Problème / conditions défavorables
- ⚪ **Gris** : Neutre / inactif

---

## 📈 Fonctionnement du Bot

### Logique de Trading

1. **Détection de Signal**
   - Le bot attend une **nouvelle bougie H1**
   - Il calcule les **EMA 9 et 21**
   - Il détecte un **croisement** :
     - **Signal BUY** : EMA rapide croise au-dessus de l'EMA lente
     - **Signal SELL** : EMA rapide croise en-dessous de l'EMA lente

2. **Filtres**
   - ✅ Spread < 100 points
   - ✅ ATR > 50 USD (volatilité suffisante)
   - ✅ Heures de trading (si configuré)
   - ✅ Confirmation H4 (tendance haussière sur H4)

3. **Calcul de Position**
   - **Stop Loss** = ATR × 1.5
   - **Take Profit** = ATR × 2.5
   - **Taille de lot** = (Balance × 1%) / Distance SL
   - Ratio Risk/Reward : **1.67:1** (favorable)

4. **Gestion de Position**
   - **Breakeven** : SL déplacé au prix d'entrée à +0.5% profit
   - **Trailing Stop** : Activé à +1% profit, suit de 0.5%
   - Monitoring en temps réel

### Exemple de Trade

```
🟢 Signal BUY détecté
   Entry: 45000.00
   SL: 44800.00 (ATR × 1.5 = 200 USD)
   TP: 45500.00 (ATR × 2.5 = 500 USD)
   Lot: 0.05 BTC
   ATR: 133.33

✅ Ordre BUY exécuté - Ticket: 123456789

[Profit atteint +0.5%]
🎯 Breakeven activé pour #123456789 | SL: 45000.00

[Profit atteint +1%]
📈 Trailing BUY #123456789 | Nouveau SL: 45225.00 | Profit: 1.00%

[Prix continue de monter]
📈 Trailing BUY #123456789 | Nouveau SL: 45270.00 | Profit: 1.25%

[TP atteint ou trailing stop touché]
✅ Position fermée avec profit
```

---

## 🔧 Optimisation des Paramètres

### Pour Marchés Volatils (ATR élevé)

```
ATR minimum            : 75.0   (augmenter)
Multiplicateur TP      : 3.0    (augmenter pour capturer plus)
Multiplicateur SL      : 2.0    (augmenter pour éviter les faux stops)
Distance trailing      : 0.7    (augmenter)
```

### Pour Marchés Calmes (ATR faible)

```
ATR minimum            : 30.0   (diminuer)
Multiplicateur TP      : 2.0    (diminuer)
Multiplicateur SL      : 1.2    (diminuer)
Distance trailing      : 0.3    (diminuer)
```

### Pour Trading Agressif (⚠️ Plus de risque)

```
Risque par trade       : 2.0    (augmenter prudemment)
Nombre max positions   : 2      (permettre plusieurs positions)
Confirmation H4        : false  (désactiver pour plus de signaux)
```

### Pour Trading Conservateur (Recommandé)

```
Risque par trade       : 0.5    (diminuer)
Nombre max positions   : 1      (une seule position)
Confirmation H4        : true   (garder la sécurité)
Multiplicateur SL      : 2.0    (SL plus large)
```

---

## 🛡️ Bonnes Pratiques de Sécurité

### Sur le VPS

1. **Redémarrage automatique**
   - Configurez MT5 pour démarrer automatiquement au boot du VPS
   - Ouvrez le graphique BTCUSD H1 avec le bot attaché
   - Sauvegardez le profil : Fichier → Profils → Enregistrer sous

2. **Surveillance**
   - Vérifiez le VPS **quotidiennement**
   - Contrôlez que MT5 est toujours connecté (coin inférieur droit)
   - Vérifiez les logs dans l'onglet "Experts"

3. **Connexion Internet**
   - Testez la stabilité de connexion du VPS
   - Ping vers le serveur du broker < 50ms recommandé
   - Évitez les VPS avec des coupures fréquentes

### Gestion du Risque

1. **Capital**
   - Ne tradez jamais avec de l'argent dont vous avez besoin
   - Capital minimum recommandé : **1000 USD** pour un compte live
   - Risque maximum : **2% par trade** (1% recommandé)

2. **Stop Loss Global**
   - Définissez un **drawdown maximum** (ex: -20% du capital)
   - Si atteint → **ARRÊTER le bot** et analyser
   - Ne jamais désactiver les stop loss du bot

3. **Monitoring**
   - **Vérifiez les trades** quotidiennement
   - Notez les **win rate, profit moyen, perte moyenne**
   - Ajustez les paramètres si performances dégradées

---

## 🐛 Dépannage

### Le bot ne s'active pas (croix rouge)

**Solution** :
1. Vérifiez que **AutoTrading** est activé (bouton vert dans la barre d'outils)
2. Dans les paramètres du bot, onglet **"Commun"** → Cochez "Autoriser le trading en direct"
3. Vérifiez dans **Outils → Options → Expert Advisors** :
   - ✅ Autoriser le trading automatique
   - ✅ Autoriser la modification des signaux

### Le bot ne passe pas d'ordres

**Vérifications** :
1. **Spread trop élevé** : Regardez le panneau, si spread > 100 pts → attendez
2. **ATR trop faible** : Si ATR < 50 USD → pas assez de volatilité
3. **Pas de signal** : Attendez un croisement EMA
4. **Position déjà ouverte** : Max 1 position par défaut
5. **Confirmation H4** : Si tendance H4 baissière et bot attend haussière

**Onglet Experts** :
- Lisez les messages pour comprendre pourquoi le bot ne trade pas
- Recherchez : "Spread trop élevé", "Balance insuffisante", etc.

### Erreur "Requête invalide"

**Solution** :
1. Vérifiez que le **symbole BTCUSD** existe chez votre broker
2. Certains brokers utilisent **BTCUSD.m** ou **BTCUSD.fx** → attachez le bot sur le bon symbole
3. Vérifiez que vous avez les **droits de trading** sur le compte

### Le Trailing Stop ne fonctionne pas

**Vérifications** :
1. Paramètre **"Activer Trailing Stop"** = true
2. Le profit doit atteindre **1%** avant activation (paramètre par défaut)
3. Le bot doit être **actif** sur le graphique pour modifier le SL
4. Vérifiez l'onglet "Experts" pour voir les messages de trailing

### Erreurs de compilation

**Erreur : "CTrade not defined"**
- Assurez-vous d'utiliser **MetaTrader 5** (pas MT4)
- MT5 Build 3801+ requis

**Erreur : "Cannot open file"**
- Le fichier doit être dans : `MQL5\Experts\`
- Pas dans un sous-dossier

---

## 📊 Interprétation des Logs

### Messages Normaux

```
🤖 BTCUSD SmartBot Pro - Initialisé avec succès
✅ Ordre BUY exécuté - Ticket: 123456
🎯 Breakeven activé pour #123456
📈 Trailing BUY #123456 | Nouveau SL: 45270.00
```

### Messages d'Information

```
⚠️ Spread trop élevé: 125 > 100          → Attendez que le spread diminue
⚠️ Balance insuffisante: 80 < 100        → Rechargez le compte
📡 Spread: 25 pts                        → OK, spread acceptable
🎯 Tendance: NEUTRE                      → Pas de signal clair
```

### Messages d'Erreur

```
❌ Erreur BUY: Invalid stops               → SL/TP trop proche du prix actuel
❌ Erreur: Impossible de créer les        → Problème d'indicateurs
    indicateurs H1
❌ Erreur: Impossible de charger le       → Symbole incorrect
    symbole BTCUSD
```

---

## 📞 Support et Aide

### Logs et Diagnostics

Pour obtenir de l'aide, fournissez :

1. **Logs complets** :
   - Onglet "Experts" → Clic droit → "Ouvrir"
   - Copiez les 50 dernières lignes

2. **Paramètres** :
   - Screenshot de la fenêtre de paramètres du bot

3. **Informations broker** :
   - Nom du broker
   - Symbole exact (BTCUSD, BTCUSD.m, etc.)
   - Type de compte (standard, ECN, etc.)

4. **Système** :
   - Windows Server version
   - MT5 Build number (Aide → À propos)

### Resources

- **GitHub Issues** : [Ouvrir un ticket](https://github.com/fred-selest/BTCUSD_SmartBot/issues)
- **Documentation** : README.md dans le repository
- **Code source** : BTCUSD_SmartBot_Pro.mq5

---

## ⚠️ Avertissements Importants

### Disclaimer

```
⚠️  AVERTISSEMENT IMPORTANT

- Le trading de crypto-monnaies comporte des RISQUES ÉLEVÉS
- Les performances passées ne garantissent PAS les résultats futurs
- Ne tradez JAMAIS avec de l'argent dont vous avez besoin
- Utilisez TOUJOURS un compte démo avant le trading live
- Les auteurs ne sont PAS responsables des pertes financières
- Ce bot est fourni "tel quel" sans garantie

UTILISEZ À VOS PROPRES RISQUES !
```

### Limitations

- Le bot fonctionne uniquement sur **graphiques H1**
- Optimisé pour **BTCUSD** (peut fonctionner sur d'autres paires)
- Nécessite une **connexion stable** (VPS recommandé)
- Les **slippages** peuvent affecter les performances
- Les **coûts de spread** impactent la rentabilité
- Nécessite une **supervision régulière**

---

## 🚀 Checklist de Démarrage

Avant de lancer le bot en LIVE :

- [ ] ✅ Bot testé en **DEMO pendant au moins 2 semaines**
- [ ] ✅ Performances validées (win rate > 40%, drawdown < 20%)
- [ ] ✅ **VPS configuré** avec démarrage automatique
- [ ] ✅ **Connexion stable** testée (ping < 50ms)
- [ ] ✅ **Capital suffisant** (minimum 1000 USD)
- [ ] ✅ **Risque configuré à 1%** maximum
- [ ] ✅ **Paramètres optimisés** pour votre broker
- [ ] ✅ **Panneau d'information** visible et correct
- [ ] ✅ **Logs vérifiés** (pas d'erreurs)
- [ ] ✅ **Trailing stop testé** en démo
- [ ] ✅ **Plan de monitoring** défini (quotidien)
- [ ] ✅ **Drawdown maximum** décidé (ex: -20%)
- [ ] ✅ **Vous comprenez** tous les paramètres
- [ ] ✅ **Vous acceptez** les risques

---

## 📅 Maintenance et Mises à Jour

### Vérifications Hebdomadaires

1. **Performances** :
   - Win rate
   - Profit Factor
   - Maximum Drawdown

2. **Système** :
   - VPS uptime
   - Connexion MT5 stable
   - Pas d'erreurs dans les logs

3. **Marché** :
   - Volatilité actuelle (ATR)
   - Conditions de marché
   - Ajustements nécessaires

### Mises à Jour du Bot

Consultez régulièrement le repository GitHub pour :
- Nouvelles versions
- Correctifs de bugs
- Améliorations de stratégie

---

**Bonne chance avec votre trading automatisé ! 🚀📈**

*N'oubliez pas : La patience et la discipline sont les clés du succès en trading.*
