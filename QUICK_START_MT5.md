# ⚡ Quick Start - BTCUSD SmartBot Pro MT5

**Guide rapide pour installation sur VPS Windows Server 2022**

---

## 🎯 En 5 Minutes

### 1️⃣ Télécharger le Bot

```
Fichiers nécessaires:
✅ BTCUSD_SmartBot_Pro.mq5
✅ BTCUSD_SmartBot_Pro_Default.set (optionnel)
```

### 2️⃣ Installer dans MT5

1. Ouvrir MT5 → **Fichier → Ouvrir le dossier de données**
2. Aller dans `MQL5 → Experts`
3. Copier `BTCUSD_SmartBot_Pro.mq5`
4. Retour MT5 → **Navigateur (Ctrl+N) → Expert Advisors → Actualiser**

### 3️⃣ Compiler

1. **MetaEditor (F4)**
2. Ouvrir `BTCUSD_SmartBot_Pro.mq5`
3. **Compiler (F7)**
4. Vérifier : "0 erreur(s)"

### 4️⃣ Lancer

1. Ouvrir graphique **BTCUSD H1**
2. Glisser le bot sur le graphique
3. Cocher **"Autoriser le trading en direct"**
4. Cliquer **OK**
5. Activer **AutoTrading** (bouton barre d'outils)

### 5️⃣ Vérifier

✅ Smiley vert 😊 sur le graphique
✅ Panneau d'info visible en haut à gauche
✅ Logs dans onglet "Experts" : "Initialisé avec succès"

---

## ⚙️ Paramètres Recommandés (Débutant)

**Ouvrir paramètres du bot** :

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

═══ TRAILING STOP ═══
Activer Trailing         : true
Activation               : 1.0%
Distance                 : 0.5%
Activer Breakeven        : true
Trigger Breakeven        : 0.5%

═══ AUTRES ═══
Confirmation H4          : true
Afficher panneau         : true
```

**OU charger directement** : `BTCUSD_SmartBot_Pro_Default.set`

---

## 🖥️ Configuration VPS (Windows Server 2022)

### Connexion Bureau à Distance

```
1. Win + R → mstsc
2. Entrer IP du VPS
3. Connecter avec credentials
```

### Installation MT5 sur VPS

```
1. Télécharger MT5 depuis site broker
2. Installer sur VPS
3. Se connecter au compte
```

### Démarrage Automatique

**Pour que le bot tourne 24/7** :

1. Dans MT5 : **Fichier → Options → Serveur**
   - ✅ Cocher "Se connecter au démarrage"

2. Ouvrir graphique BTCUSD H1 avec bot attaché

3. **Fichier → Profils → Enregistrer sous** : "BTCUSD_Bot"

4. Créer raccourci MT5 dans dossier **Démarrage Windows** :
   ```
   C:\Users\[User]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
   ```

5. Modifier raccourci : Ajouter `/profile:BTCUSD_Bot` dans "Cible"

**Au redémarrage du VPS**, MT5 démarre automatiquement avec le bot actif.

---

## 🧪 Test OBLIGATOIRE

### ⚠️ NE JAMAIS lancer en LIVE sans tester !

**Phase 1 : Démo (2 semaines)**
```
✅ Compte démo 10,000 USD
✅ Laisser tourner 24/7
✅ Noter performances quotidiennement
✅ Vérifier win rate, drawdown
```

**Phase 2 : Micro-Live (optionnel)**
```
✅ 500-1000 USD
✅ Risque 0.5%
✅ 1-2 semaines
```

**Phase 3 : Live Normal**
```
✅ Après validation complète
✅ Capital minimum 1000 USD
✅ Risque 1-2% max
```

---

## 📊 Panneau d'Information

Le bot affiche en temps réel :

```
🤖 BTCUSD SmartBot Pro
💰 Balance: 10000.00 USD
💎 Equity: 10150.00 USD
📊 Positions: 1/1
📡 Spread: 25 pts [🟢 = OK]
📈 ATR: 127.45 USD [🟢 = Suffisant]
🎯 Tendance: HAUSSIERE [🟢 = Buy OK]
```

**Couleurs** :
- 🟢 Vert = OK
- 🟡 Jaune = Position ouverte
- 🟠 Orange = Attention
- 🔴 Rouge = Problème

---

## 🐛 Problèmes Courants

### ❌ Bot pas actif (croix rouge)

**Solution** :
```
1. Cliquer bouton AutoTrading (Alt+A)
2. Paramètres bot → Onglet "Commun"
   → Cocher "Autoriser trading en direct"
3. Outils → Options → Expert Advisors
   → Tout cocher
```

### 📭 Pas d'ordres

**Vérifier** :
```
• Spread > 100 ? → Attendre
• ATR < 50 ? → Manque volatilité
• Pas de signal ? → Attendre croisement EMA
• Position déjà ouverte ? → Max 1 par défaut
• Logs "Experts" → Lire les messages
```

### ⚠️ Erreur "Invalid stops"

**Solution** :
```
Augmenter Multiplicateur SL à 2.0
```

---

## 📞 Aide

**Documentation complète** :
- 📖 [Guide Installation Détaillé](GUIDE_INSTALLATION_MT5.md)
- 📘 [README MT5 Complet](README_MT5.md)

**Support** :
- 🐛 [GitHub Issues](https://github.com/fred-selest/BTCUSD_SmartBot/issues)

---

## ✅ Checklist Avant LIVE

- [ ] Testé 2+ semaines en DÉMO
- [ ] Win rate > 40%
- [ ] Drawdown < 20%
- [ ] VPS configuré et stable
- [ ] Capital minimum 1000 USD
- [ ] Risque 1% configuré
- [ ] Tous paramètres compris
- [ ] Plan monitoring quotidien
- [ ] Risques acceptés ⚠️

---

## ⚠️ DISCLAIMER

```
⚠️  Le trading comporte des RISQUES ÉLEVÉS
    Ne tradez qu'avec argent "à risque"
    Testez TOUJOURS en DEMO d'abord
    Pas de garantie de profits
    Utilisez à VOS PROPRES RISQUES
```

---

**C'est parti ! 🚀**

*Patience, Discipline et Risk Management sont les clés du succès.*
