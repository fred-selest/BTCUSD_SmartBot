"""
Configuration file for BTCUSD SmartBot
Inspired by BTCUSD_SmartBot_v2.mq5 - Optimized for Python trading
"""

class TradingConfig:
    """Trading strategy configuration"""

    # Risk Management
    RISK_PERCENT = 1.0              # Risk % of capital per trade
    MAX_POSITIONS = 1                # Maximum concurrent positions

    # EMA Strategy Parameters
    FAST_EMA = 9                     # Fast EMA period (H1)
    SLOW_EMA = 21                    # Slow EMA period (H1)

    # ATR Parameters
    ATR_PERIOD = 14                  # ATR calculation period
    ATR_MULTIPLIER_TP = 2.5          # Take Profit = ATR * Multiplier
    ATR_MULTIPLIER_SL = 1.5          # Stop Loss = ATR * Multiplier
    MIN_ATR_USD = 50                 # Minimum volatility in USD

    # Trading Filters
    MAX_SPREAD_USD = 60              # Maximum spread in USD
    START_HOUR = 8                   # Trading start hour (UTC)
    END_HOUR = 20                    # Trading end hour (UTC)

    # Trailing Stop
    USE_TRAILING = True              # Enable trailing stop
    TRAIL_START_PERCENT = 1.0        # % profit to activate trailing
    TRAIL_STEP_PERCENT = 0.5         # % trailing step

    # Timeframes
    PRIMARY_TIMEFRAME = '1h'         # Primary trading timeframe
    CONFIRMATION_TIMEFRAME = '4h'    # Higher timeframe for confirmation

    # Exchange Settings
    SYMBOL = 'BTC/USD'               # Trading pair
    MIN_ORDER_SIZE = 0.001           # Minimum order size in BTC
    SLIPPAGE_PERCENT = 0.1           # Maximum slippage %

    # Bot Settings
    MAGIC_NUMBER = 202511            # Unique identifier for bot trades
    DRY_RUN = True                   # Paper trading mode (set False for live)
    LOG_LEVEL = 'INFO'               # Logging level: DEBUG, INFO, WARNING, ERROR


class ExchangeConfig:
    """Exchange API configuration"""

    # Exchange selection: 'binance', 'kraken', 'coinbase', 'ftx', etc.
    EXCHANGE_NAME = 'binance'

    # API Credentials (use environment variables in production!)
    API_KEY = ''                     # Set via environment variable
    API_SECRET = ''                  # Set via environment variable

    # Testnet/Sandbox mode
    USE_TESTNET = True               # Use testnet for testing

    # Rate limiting
    ENABLE_RATE_LIMIT = True

    @classmethod
    def from_env(cls):
        """Load configuration from environment variables"""
        import os
        cls.API_KEY = os.getenv('EXCHANGE_API_KEY', cls.API_KEY)
        cls.API_SECRET = os.getenv('EXCHANGE_API_SECRET', cls.API_SECRET)
        cls.USE_TESTNET = os.getenv('USE_TESTNET', 'True').lower() == 'true'
        return cls


# Initialize configuration from environment
ExchangeConfig.from_env()
