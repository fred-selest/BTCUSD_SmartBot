# 🤖 BTCUSD SmartBot

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![MT5](https://img.shields.io/badge/MetaTrader-5-blue.svg)](https://www.metatrader5.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

**Intelligent Bitcoin Trading Bot with EMA Strategy and ATR-based Risk Management**

Professional trading bot available in **two versions**: Python (for exchanges via CCXT) and MetaTrader 5 (for MT5 brokers).

---

## 📁 Structure du Projet

```
BTCUSD_SmartBot/
│
├── 📂 Version Python - Pour Exchanges Crypto/
│   ├── btc_smartbot.py          # Bot principal Python
│   ├── config.py                # Configuration Python
│   ├── indicators.py            # Indicateurs techniques
│   ├── risk_manager.py          # Gestion du risque
│   ├── trailing_stop.py         # Trailing stop
│   ├── example_backtest.py      # Exemple backtesting
│   ├── requirements.txt         # Dépendances Python
│   └── README.md                # Guide Python détaillé
│
├── 📂 configuration set/
│   ├── BTCUSD_SmartBot_Pro_Default.set
│   ├── BTCUSD_SmartBot_Pro_Conservative.set
│   ├── BTCUSD_SmartBot_Pro_Aggressive.set
│   ├── BTCUSD_SmartBot_Pro_FxPro.set
│   ├── BTCUSD_SmartBot_Pro_Grid.set
│   ├── BTCUSD_SmartBot_Pro_Martingale.set
│   ├── BTCUSD_SmartBot_Pro_GridMartingale.set
│   └── README.md                # Guide configurations MT5
│
├── 📂 versions/
│   ├── BTCUSD_SmartBot_Pro_v1.04.mq5
│   ├── BTCUSD_SmartBot_Pro_v1.05.mq5
│   └── README.md                # Guide archivage versions
│
├── 🤖 BTCUSD_SmartBot_Pro.mq5   # Bot MT5 (version actuelle: 1.05)
├── 📖 README_MT5.md             # Guide MT5 détaillé
├── 📖 GUIDE_INSTALLATION_MT5.md # Installation MT5
├── 📖 QUICK_START_MT5.md        # Démarrage rapide MT5
├── 📖 README_FXPRO.md           # Guide FxPro broker
├── 📝 CHANGELOG_MT5.md          # Historique versions MT5
└── 📄 LICENSE                   # Licence MIT
```

---

## 📦 Deux Versions Disponibles

### 🐍 Version Python - Pour Exchanges Crypto
**Dossier** : `Version Python - Pour Exchanges Crypto/`
- ✅ Compatible avec **100+ exchanges** (Binance, Kraken, etc.) via CCXT
- ✅ Paper trading et testnet
- ✅ Flexible et personnalisable
- 📖 [**Guide Python Complet**](Version%20Python%20-%20Pour%20Exchanges%20Crypto/README.md)

### 🖥️ Version MetaTrader 5 - Pour Brokers Forex
**Fichiers** : `BTCUSD_SmartBot_Pro.mq5` + dossier `configuration set/`
- ✅ Compatible **VPS Windows Server 2022**
- ✅ **Grid Trading & Martingale** contrôlés (v1.05)
- ✅ Interface graphique intégrée
- ✅ 7 configurations prédéfinies
- ✅ Système d'archivage de versions
- 📖 [**Guide MT5 Complet**](README_MT5.md) | [**Installation**](GUIDE_INSTALLATION_MT5.md)

> **💡 Quelle version choisir ?**
> - **Python** → Si vous tradez sur exchanges crypto (Binance, Coinbase, etc.)
> - **MT5** → Si vous avez un broker MetaTrader 5 et VPS Windows

---

# 🐍 Python Version - For Crypto Exchanges

---

## ✨ Features

### 📊 Trading Strategy
- **EMA Crossover Strategy**: Fast (9) and Slow (21) EMAs on 1-hour timeframe
- **Multi-Timeframe Confirmation**: Higher timeframe (4h) trend validation
- **Dynamic TP/SL**: ATR-based Take Profit (2.5x) and Stop Loss (1.5x)
- **Intelligent Entry Signals**: Precise crossover detection with trend alignment

### 🛡️ Risk Management
- **Fixed Risk Per Trade**: 1% of capital per position (configurable)
- **Dynamic Position Sizing**: Automatically calculated based on account balance and stop loss
- **Risk/Reward Validation**: Ensures favorable risk/reward ratios before entry
- **Maximum Position Limits**: Prevents over-exposure

### 🎯 Advanced Features
- **Intelligent Trailing Stop**: Activates at 1% profit, trails by 0.5%
- **Breakeven Protection**: Moves stop to entry after initial profit target
- **Market Filters**:
  - Spread filter (max $60)
  - Volatility filter (min ATR threshold)
  - Trading hours filter (8:00-20:00 UTC)
- **Paper Trading Mode**: Full simulation without real capital at risk

### 🔌 Exchange Support
- **CCXT Integration**: Works with 100+ exchanges
- **Testnet Support**: Test strategies on exchange sandboxes
- **Rate Limiting**: Built-in API protection
- **Real-time Data**: Live OHLCV data and order execution

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- pip package manager
- Exchange API credentials (for live trading)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/BTCUSD_SmartBot.git
cd BTCUSD_SmartBot
```

2. **Navigate to Python version folder**
```bash
cd "Version Python - Pour Exchanges Crypto"
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your API credentials
```

5. **Run the bot**
```bash
# Paper trading mode (recommended for testing)
python btc_smartbot.py

# Or run the backtest example
python example_backtest.py
```

---

## ⚙️ Configuration

### Basic Configuration (`config.py`)

```python
# Risk Management
RISK_PERCENT = 1.0              # Risk 1% per trade
MAX_POSITIONS = 1               # Maximum concurrent positions

# Strategy Parameters
FAST_EMA = 9                    # Fast EMA period
SLOW_EMA = 21                   # Slow EMA period
ATR_PERIOD = 14                 # ATR calculation period
ATR_MULTIPLIER_TP = 2.5         # Take Profit multiplier
ATR_MULTIPLIER_SL = 1.5         # Stop Loss multiplier

# Trading Filters
MAX_SPREAD_USD = 60             # Maximum acceptable spread
START_HOUR = 8                  # Start trading at 8:00 UTC
END_HOUR = 20                   # Stop trading at 20:00 UTC

# Trailing Stop
USE_TRAILING = True             # Enable trailing stop
TRAIL_START_PERCENT = 1.0       # Activate at 1% profit
TRAIL_STEP_PERCENT = 0.5        # Trail by 0.5%
```

### Environment Variables (`.env`)

```bash
# Exchange API Credentials
EXCHANGE_API_KEY=your_api_key_here
EXCHANGE_API_SECRET=your_api_secret_here

# Trading Mode
USE_TESTNET=True                # Use exchange testnet
DRY_RUN=True                    # Paper trading mode

# Optional: Telegram Notifications
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
```

---

## 📚 Version Python - Structure des Fichiers

Tous les fichiers Python se trouvent dans le dossier `Version Python - Pour Exchanges Crypto/` :

```
Version Python - Pour Exchanges Crypto/
│
├── btc_smartbot.py          # Main trading bot
├── config.py                 # Configuration settings
├── indicators.py             # Technical indicators (EMA, ATR)
├── risk_manager.py           # Risk management & position sizing
├── trailing_stop.py          # Trailing stop logic
├── example_backtest.py       # Backtesting example
│
├── requirements.txt          # Python dependencies
├── .env.example             # Environment template
└── README.md                # Guide détaillé version Python
```

---

## 🎓 How It Works

### Trading Logic Flow

1. **New Candle Detection**
   - Bot waits for new 1-hour candle formation
   - Fetches latest OHLCV data from exchange

2. **Filter Checks**
   - ✅ Trading hours (8:00-20:00 UTC)
   - ✅ Spread within limits (< $60)
   - ✅ Sufficient volatility (ATR > minimum)

3. **Indicator Calculation**
   - Calculate Fast EMA (9) and Slow EMA (21)
   - Calculate ATR (14) for volatility
   - Detect EMA crossovers

4. **Multi-Timeframe Confirmation**
   - Check 4-hour trend alignment
   - Only trade in direction of higher timeframe

5. **Signal Generation**
   - **Buy Signal**: Fast EMA crosses above Slow EMA
   - **Sell Signal**: Fast EMA crosses below Slow EMA

6. **Risk Calculation**
   - Calculate dynamic Stop Loss (ATR × 1.5)
   - Calculate dynamic Take Profit (ATR × 2.5)
   - Size position based on 1% risk

7. **Order Execution**
   - Validate trade parameters
   - Execute market order
   - Set stop loss and take profit

8. **Position Management**
   - Monitor position profit
   - Activate trailing stop at 1% profit
   - Trail stop by 0.5% as price moves favorably

---

## 📊 Strategy Performance

### Expected Characteristics

- **Win Rate**: 40-55% (crossover strategies typically)
- **Risk/Reward**: 1.67:1 (2.5 TP / 1.5 SL)
- **Holding Period**: Hours to days
- **Best Market**: Trending markets with moderate volatility

### Optimization Tips

1. **Adjust EMA Periods**: Test 8/21, 9/21, 12/26 combinations
2. **Modify ATR Multipliers**: Balance between tight and loose stops
3. **Filter Trading Hours**: Focus on high-volume periods
4. **Add Confirmation**: Consider RSI, MACD, or volume filters

---

## 🧪 Testing

### Backtesting Example

Run the included backtest simulation:

```bash
python example_backtest.py
```

Sample output:
```
BTCUSD SmartBot - Backtest Simulation
============================================================
📊 Generating sample data...
✅ Data loaded: 720 candles
📅 Period: 2024-10-10 to 2024-11-09
💰 Starting balance: $10000.00

🟢 Open BUY: $45123.45 | Size: 0.002215 BTC
🔄 Close BUY: $45567.89 → P&L: $98.32

============================================================
BACKTEST RESULTS
============================================================
📊 Performance:
   Total Trades: 15
   Winning Trades: 8
   Losing Trades: 7
   Win Rate: 53.3%

💰 Financial:
   Starting Balance: $10000.00
   Final Balance: $10432.18
   Total P&L: +$432.18
   ROI: +4.32%
```

### Paper Trading

Test with real market data without risking capital:

```python
# In config.py
DRY_RUN = True  # Enable paper trading
USE_TESTNET = True  # Use exchange testnet
```

---

## 🔒 Security Best Practices

### API Key Security

1. **Never commit API keys** to version control
2. **Use environment variables** for credentials
3. **Enable IP whitelisting** on exchange
4. **Use read + trade permissions only** (not withdrawal)
5. **Test on testnet first** before live trading

### Risk Management

1. **Start with paper trading** to validate strategy
2. **Use small capital** for initial live testing
3. **Monitor positions regularly**
4. **Set account-level stop loss** on exchange
5. **Never risk more than 1-2%** per trade

---

## 🐛 Troubleshooting

### Common Issues

**Q: Bot not executing trades**
- Check if within trading hours (8:00-20:00 UTC)
- Verify spread is below maximum ($60)
- Ensure ATR is above minimum threshold
- Check H4 trend confirmation is met

**Q: "Insufficient balance" error**
- Verify account balance is sufficient
- Check minimum order size (0.001 BTC)
- Ensure position sizing calculation is correct

**Q: Connection errors**
- Verify API credentials are correct
- Check exchange API status
- Ensure rate limiting is enabled
- Try testnet mode first

**Q: Indicators showing NaN**
- Ensure sufficient historical data (100+ candles)
- Check for missing OHLCV values
- Verify data fetch is successful

---

## 🛠️ Advanced Usage

### Custom Indicators

Add custom indicators in `indicators.py`:

```python
@staticmethod
def calculate_rsi(data: pd.DataFrame, period: int = 14) -> pd.Series:
    """Calculate RSI indicator"""
    delta = data['close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    rsi = 100 - (100 / (1 + rs))
    return rsi
```

### Telegram Notifications

Add notification support:

```python
import telegram

def send_telegram_alert(message: str):
    bot = telegram.Bot(token=TELEGRAM_BOT_TOKEN)
    bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=message)
```

### Database Logging

Store trades in database:

```python
import sqlite3

def log_trade_to_db(trade_data: dict):
    conn = sqlite3.connect('trades.db')
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO trades VALUES (?, ?, ?, ?, ?)",
        (trade_data['timestamp'], trade_data['type'],
         trade_data['entry'], trade_data['size'], trade_data['pnl'])
    )
    conn.commit()
    conn.close()
```

---

## 📈 Performance Tracking

### Key Metrics to Monitor

- **Win Rate**: Percentage of profitable trades
- **Average Win/Loss**: Mean profit and loss amounts
- **Maximum Drawdown**: Largest peak-to-trough decline
- **Sharpe Ratio**: Risk-adjusted return metric
- **Profit Factor**: Gross profit / Gross loss

### Logging

Enable detailed logging:

```python
# In config.py
LOG_LEVEL = 'DEBUG'  # DEBUG, INFO, WARNING, ERROR
```

View logs:
```bash
tail -f bot.log
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## ⚠️ Disclaimer

**IMPORTANT**: This software is for educational purposes only.

- Trading cryptocurrencies involves substantial risk of loss
- Past performance does not guarantee future results
- Never trade with money you cannot afford to lose
- The authors are not responsible for any financial losses
- Always test thoroughly before live trading
- Consult a financial advisor before trading

**Use at your own risk!**

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by **BTCUSD_SmartBot_v2.mq5** for MetaTrader 5
- Built with [CCXT](https://github.com/ccxt/ccxt) library
- Technical indicators using pandas and numpy

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/BTCUSD_SmartBot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/BTCUSD_SmartBot/discussions)
- **Email**: support@example.com

---

## 🗺️ Roadmap

- [ ] Add more technical indicators (RSI, MACD, Bollinger Bands)
- [ ] Implement multi-symbol support
- [ ] Add ML-based signal filtering
- [ ] Create web dashboard for monitoring
- [ ] Add Telegram bot integration
- [ ] Implement advanced backtesting with optimization
- [ ] Support for multiple exchanges simultaneously
- [ ] Add cloud deployment guides (AWS, GCP, Azure)

---

**Happy Trading! 🚀📈**

*Remember: The best trade is the one you don't take when conditions aren't right.*
