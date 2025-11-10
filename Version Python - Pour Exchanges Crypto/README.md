# 🐍 BTCUSD SmartBot - Version Python pour Exchanges Crypto

Cette version Python du bot est conçue pour trader sur les **exchanges de cryptomonnaies** (Binance, Bybit, etc.) via leurs APIs.

> **Note** : Cette version est **différente** de la version MetaTrader 5 (MQL5) située dans le dossier principal.

---

## 📋 Contenu du Dossier

### Fichiers Principaux

| Fichier | Description |
|---------|-------------|
| `btc_smartbot.py` | Bot principal avec logique de trading |
| `config.py` | Configuration et paramètres |
| `indicators.py` | Calculs d'indicateurs techniques (EMA, ATR) |
| `risk_manager.py` | Gestion du risque et position sizing |
| `trailing_stop.py` | Gestion du trailing stop et breakeven |
| `example_backtest.py` | Exemple de backtesting |
| `requirements.txt` | Dépendances Python |
| `.env.example` | Template pour clés API |

---

## 🎯 Stratégie de Trading

### Identique à la version MT5 :
- **EMA 9/21 Crossover** sur H1
- **ATR Dynamique** pour TP/SL
- **Trailing Stop** intelligent
- **Multi-timeframe** H4 confirmation

### Compatible avec :
- ✅ Binance (Spot & Futures)
- ✅ Bybit
- ✅ Kraken
- ✅ Coinbase Pro
- ✅ Autres exchanges avec API CCXT

---

## 🚀 Installation

### Prérequis
- Python 3.8+
- Compte sur un exchange crypto
- Clés API (avec permissions Trading)

### Étapes

1. **Installer les dépendances** :
   ```bash
   pip install -r requirements.txt
   ```

2. **Configurer les clés API** :
   - Copier `.env.example` → `.env`
   - Ajouter vos clés API :
   ```
   EXCHANGE_NAME=binance
   API_KEY=votre_cle_api
   API_SECRET=votre_secret
   ```

3. **Tester la connexion** :
   ```bash
   python btc_smartbot.py --test
   ```

4. **Lancer en mode démo** :
   ```bash
   python btc_smartbot.py --demo
   ```

5. **Lancer en mode live** (après tests !) :
   ```bash
   python btc_smartbot.py --live
   ```

---

## ⚙️ Configuration

### Fichier `config.py`

Paramètres principaux à ajuster :

```python
# Trading
SYMBOL = "BTC/USDT"
TIMEFRAME = "1h"
RISK_PERCENT = 1.0  # Risque par trade

# Stratégie
FAST_EMA = 9
SLOW_EMA = 21
ATR_PERIOD = 14
ATR_TP_MULTIPLIER = 3.0
ATR_SL_MULTIPLIER = 1.5

# Protection
USE_TRAILING_STOP = True
USE_BREAKEVEN = True
MAX_POSITIONS = 1
```

---

## 📊 Exemples d'Utilisation

### Backtest Simple

```python
from example_backtest import run_backtest

# Backtest sur 6 mois
run_backtest(
    start_date="2024-05-01",
    end_date="2024-11-01",
    initial_capital=1000
)
```

### Trading Live (Binance)

```python
from btc_smartbot import BTCSmartBot

bot = BTCSmartBot(
    exchange="binance",
    symbol="BTC/USDT",
    risk_percent=1.0,
    demo_mode=False  # ⚠️ Mode LIVE
)

bot.start()
```

### Mode Démo (Paper Trading)

```python
bot = BTCSmartBot(
    exchange="binance",
    symbol="BTC/USDT",
    demo_mode=True  # ✅ Mode DEMO
)

bot.start()
```

---

## 🛡️ Gestion du Risque

### Risk Manager (`risk_manager.py`)

Calcule automatiquement :
- **Taille de position** basée sur % risque
- **Stop Loss** dynamique (ATR)
- **Take Profit** dynamique (ATR)
- **Limite de positions** simultanées

Exemple :
```python
from risk_manager import RiskManager

rm = RiskManager(
    balance=1000,
    risk_percent=1.0
)

position_size = rm.calculate_position_size(
    entry_price=70000,
    stop_loss=69000
)
# Retourne la taille en BTC
```

---

## 📈 Indicateurs Techniques

### Module `indicators.py`

Fonctions disponibles :
- `calculate_ema(prices, period)` - EMA
- `calculate_atr(high, low, close, period)` - ATR
- `detect_crossover(fast_ema, slow_ema)` - Détection croisement

Exemple :
```python
from indicators import calculate_ema, calculate_atr

# Calculer EMA 9
ema9 = calculate_ema(close_prices, 9)

# Calculer ATR 14
atr = calculate_atr(high_prices, low_prices, close_prices, 14)
```

---

## 🎯 Trailing Stop & Breakeven

### Module `trailing_stop.py`

Gère automatiquement :
- **Breakeven** : SL → entry quand +0.5% profit
- **Trailing Stop** : SL suit le prix à distance fixe

Paramètres :
```python
TRAILING_ACTIVATION = 0.7  # Active à +0.7%
TRAILING_DISTANCE = 0.3    # Distance de 0.3%
BREAKEVEN_TRIGGER = 0.5    # Breakeven à +0.5%
```

---

## ⚠️ Différences avec Version MT5

| Aspect | Version Python | Version MT5 |
|--------|----------------|-------------|
| Plateforme | Exchanges crypto | MetaTrader 5 |
| Langage | Python 3.8+ | MQL5 |
| Assets | BTC/USDT, ETH/USDT, etc. | BTCUSD (CFD) |
| Frais | Maker/Taker exchange | Spread broker |
| Exécution | API REST/WebSocket | Direct broker |
| Grid/Martingale | ❌ Non implémenté | ✅ Disponible |
| Backtesting | Python/pandas | MT5 Strategy Tester |

---

## 🔧 Développement & Extension

### Ajouter un nouvel exchange

```python
# Dans btc_smartbot.py
import ccxt

exchange = ccxt.kucoin({
    'apiKey': API_KEY,
    'secret': API_SECRET
})
```

### Ajouter un indicateur

```python
# Dans indicators.py
def calculate_rsi(prices, period=14):
    # Votre code RSI
    pass
```

### Modifier la stratégie

```python
# Dans btc_smartbot.py, méthode analyze_market()
def analyze_market(self):
    # Ajoutez vos conditions
    if self.custom_condition():
        return "BUY"
```

---

## 📊 Performance & Monitoring

### Logs

Le bot génère des logs détaillés :
```
2025-11-09 10:00:00 - INFO - Bot démarré (DEMO mode)
2025-11-09 10:15:00 - INFO - Signal BUY détecté - EMA9 > EMA21
2025-11-09 10:15:05 - INFO - Position ouverte - Entry: 70000, SL: 69000, TP: 73000
2025-11-09 11:30:00 - INFO - Trailing stop activé - Profit: +0.8%
```

### Metrics

Suivez les performances :
- Win rate
- Profit factor
- Max drawdown
- Sharpe ratio

---

## ⚠️ Avertissements Importants

### Sécurité

1. **NE JAMAIS** commiter le fichier `.env` avec vos clés API
2. **Utiliser des clés** avec permissions limitées
3. **Activer 2FA** sur votre exchange
4. **Limiter le montant** autorisé par l'API

### Trading

1. **TOUJOURS** tester en mode DEMO d'abord
2. **Commencer petit** (50-100 USD)
3. **Surveiller régulièrement** le bot
4. **Comprendre les risques** du trading automatique

### Technique

1. **Serveur stable** requis (VPS recommandé)
2. **Connexion internet** fiable
3. **Monitoring actif** des erreurs
4. **Backup régulier** de la configuration

---

## 🆚 Quelle Version Utiliser ?

### Utilisez la **Version Python** si :
- ✅ Vous tradez sur Binance, Bybit, etc.
- ✅ Vous voulez trader des **vraies cryptos** (pas CFD)
- ✅ Vous êtes à l'aise avec Python
- ✅ Vous voulez personnaliser facilement le code

### Utilisez la **Version MT5** si :
- ✅ Vous avez un compte MetaTrader 5
- ✅ Vous tradez des **CFD Bitcoin**
- ✅ Vous voulez le **Grid Trading** et **Martingale**
- ✅ Vous préférez une interface graphique (MT5)

---

## 📚 Documentation Complémentaire

- **CCXT Documentation** : https://docs.ccxt.com/
- **Binance API** : https://binance-docs.github.io/apidocs/
- **Pandas TA** : https://github.com/twopirllc/pandas-ta

---

## 🐛 Dépannage

### Erreur "Invalid API Key"
→ Vérifier `.env`, régénérer les clés

### Erreur "Insufficient funds"
→ Vérifier la balance, réduire `RISK_PERCENT`

### Bot ne trade pas
→ Vérifier que les conditions EMA crossover sont remplies

### Erreur de connexion
→ Vérifier firewall, VPN, status de l'exchange

---

## 📞 Support

Pour questions sur la version Python :
- Issues GitHub
- Documentation CCXT
- Forums Python trading

Pour questions sur la stratégie :
- Consulter README_MT5.md (stratégie identique)
- CHANGELOG_MT5.md pour évolutions

---

## 🔄 Versions

**Version actuelle** : 1.00 (Python)
**Basée sur** : BTCUSD SmartBot Pro v1.05 (MT5)

**Différences** :
- Pas de Grid/Martingale (peut être ajouté)
- Backtesting différent
- APIs exchanges au lieu de broker

---

**Dernière mise à jour** : 2025-11-09
**Statut** : Beta - Tester en DEMO uniquement
