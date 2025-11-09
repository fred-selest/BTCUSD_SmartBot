"""
BTCUSD SmartBot - Main Trading Bot
Intelligent Bitcoin trading bot with EMA strategy and ATR-based risk management

Inspired by BTCUSD_SmartBot_v2.mq5
Author: Claude AI
Version: 1.0.0
"""

import ccxt
import pandas as pd
import logging
import time
from datetime import datetime, timezone
from typing import Optional, Dict, List, Tuple

from config import TradingConfig, ExchangeConfig
from indicators import TechnicalIndicators, MarketAnalyzer
from risk_manager import RiskManager, PositionTracker
from trailing_stop import TrailingStopManager


# Setup logging
logging.basicConfig(
    level=getattr(logging, TradingConfig.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BTCSmartBot:
    """Main trading bot class"""

    def __init__(
        self,
        config: TradingConfig = TradingConfig,
        exchange_config: ExchangeConfig = ExchangeConfig
    ):
        self.config = config
        self.exchange_config = exchange_config

        # Initialize components
        self.exchange = self._initialize_exchange()
        self.risk_manager = RiskManager(config)
        self.position_tracker = PositionTracker()
        self.trailing_manager = TrailingStopManager(config, self.risk_manager)

        # State
        self.is_running = False
        self.last_bar_time = None
        self.balance = 0.0

        logger.info("=== BTCUSD SmartBot v1.0 Initialized ===")
        logger.info(f"Mode: {'PAPER TRADING' if config.DRY_RUN else 'LIVE TRADING'}")
        logger.info(f"Symbol: {config.SYMBOL}")
        logger.info(f"Timeframe: {config.PRIMARY_TIMEFRAME}")
        logger.info(f"Risk per trade: {config.RISK_PERCENT}%")

    def _initialize_exchange(self) -> ccxt.Exchange:
        """Initialize exchange connection"""
        exchange_class = getattr(ccxt, self.exchange_config.EXCHANGE_NAME)

        exchange_params = {
            'apiKey': self.exchange_config.API_KEY,
            'secret': self.exchange_config.API_SECRET,
            'enableRateLimit': self.exchange_config.ENABLE_RATE_LIMIT,
        }

        if self.exchange_config.USE_TESTNET:
            exchange_params['options'] = {'defaultType': 'future'}
            if hasattr(exchange_class, 'set_sandbox_mode'):
                exchange_params['sandbox'] = True

        exchange = exchange_class(exchange_params)

        logger.info(
            f"Connected to {self.exchange_config.EXCHANGE_NAME} "
            f"({'testnet' if self.exchange_config.USE_TESTNET else 'live'})"
        )

        return exchange

    def fetch_ohlcv(
        self,
        timeframe: str,
        limit: int = 100
    ) -> pd.DataFrame:
        """
        Fetch OHLCV data from exchange

        Args:
            timeframe: Candle timeframe (e.g., '1h', '4h')
            limit: Number of candles to fetch

        Returns:
            DataFrame with OHLCV data
        """
        try:
            ohlcv = self.exchange.fetch_ohlcv(
                self.config.SYMBOL,
                timeframe=timeframe,
                limit=limit
            )

            df = pd.DataFrame(
                ohlcv,
                columns=['timestamp', 'open', 'high', 'low', 'close', 'volume']
            )
            df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
            df.set_index('timestamp', inplace=True)

            return df

        except Exception as e:
            logger.error(f"Error fetching OHLCV data: {e}")
            return pd.DataFrame()

    def get_current_price(self) -> Tuple[float, float]:
        """
        Get current bid/ask prices

        Returns:
            Tuple (bid, ask)
        """
        try:
            ticker = self.exchange.fetch_ticker(self.config.SYMBOL)
            bid = ticker.get('bid', 0)
            ask = ticker.get('ask', 0)
            return bid, ask
        except Exception as e:
            logger.error(f"Error fetching ticker: {e}")
            return 0.0, 0.0

    def update_balance(self):
        """Update account balance"""
        try:
            balance = self.exchange.fetch_balance()
            # Get USD or USDT balance
            for currency in ['USD', 'USDT', 'BUSD']:
                if currency in balance['free']:
                    self.balance = balance['free'][currency]
                    logger.debug(f"Balance updated: ${self.balance:.2f}")
                    return

            logger.warning("Could not find USD balance")
        except Exception as e:
            logger.error(f"Error fetching balance: {e}")

    def is_new_bar(self, current_time: datetime) -> bool:
        """
        Check if a new candle has formed

        Args:
            current_time: Current timestamp

        Returns:
            True if new bar detected
        """
        # Get timeframe in minutes
        tf_map = {'1m': 1, '5m': 5, '15m': 15, '1h': 60, '4h': 240, '1d': 1440}
        tf_minutes = tf_map.get(self.config.PRIMARY_TIMEFRAME, 60)

        # Round to timeframe
        bar_time = current_time.replace(
            minute=(current_time.minute // tf_minutes) * tf_minutes,
            second=0,
            microsecond=0
        )

        if self.last_bar_time is None or bar_time > self.last_bar_time:
            self.last_bar_time = bar_time
            return True

        return False

    def check_trading_filters(self) -> bool:
        """
        Check all trading filters (time, spread, volatility)

        Returns:
            True if all filters pass
        """
        # Check trading hours
        current_hour = datetime.now(timezone.utc).hour
        if not MarketAnalyzer.is_trading_hours(
            current_hour,
            self.config.START_HOUR,
            self.config.END_HOUR
        ):
            logger.debug(f"Outside trading hours ({current_hour}h UTC)")
            return False

        # Check spread
        bid, ask = self.get_current_price()
        if not MarketAnalyzer.check_spread(bid, ask, self.config.MAX_SPREAD_USD):
            spread = abs(ask - bid)
            logger.warning(f"Spread too high: ${spread:.2f}")
            return False

        return True

    def check_higher_timeframe_confirmation(self) -> bool:
        """
        Check trend confirmation on higher timeframe (H4)

        Returns:
            True if higher timeframe confirms trend
        """
        df_h4 = self.fetch_ohlcv(self.config.CONFIRMATION_TIMEFRAME, limit=50)

        if df_h4.empty:
            logger.warning("Could not fetch H4 data for confirmation")
            return False

        # Calculate EMAs on H4
        df_h4 = TechnicalIndicators.add_all_indicators(
            df_h4,
            self.config.FAST_EMA,
            self.config.SLOW_EMA,
            self.config.ATR_PERIOD
        )

        # Check trend alignment
        trend = TechnicalIndicators.check_trend_alignment(
            df_h4['ema_fast'],
            df_h4['ema_slow']
        )

        logger.debug(f"H4 trend: {trend}")

        # Only trade in bullish H4 trend (can be modified for both directions)
        return trend == 'bullish'

    def analyze_entry_signal(self, df: pd.DataFrame) -> Optional[str]:
        """
        Analyze entry signals based on EMA crossover

        Args:
            df: DataFrame with indicators

        Returns:
            'buy', 'sell', or None
        """
        if len(df) < 2:
            return None

        # Detect EMA crossover
        bullish_cross, bearish_cross = TechnicalIndicators.detect_ema_crossover(
            df['ema_fast'],
            df['ema_slow']
        )

        # Check ATR volatility
        current_atr = df['atr'].iloc[-1]
        if not MarketAnalyzer.check_volatility(current_atr, self.config.MIN_ATR_USD):
            logger.debug(f"Volatility too low: ATR={current_atr:.2f}")
            return None

        # Return signal
        if bullish_cross:
            logger.info("🔼 Bullish EMA crossover detected!")
            return 'buy'
        elif bearish_cross:
            logger.info("🔽 Bearish EMA crossover detected!")
            return 'sell'

        return None

    def execute_trade(self, signal: str, current_price: float, atr: float):
        """
        Execute trade based on signal

        Args:
            signal: 'buy' or 'sell'
            current_price: Current market price
            atr: Current ATR value
        """
        # Check max positions
        if self.position_tracker.is_max_positions_reached(self.config.MAX_POSITIONS):
            logger.warning("Maximum positions reached, skipping trade")
            return

        # Calculate stops
        stop_loss, take_profit = TechnicalIndicators.calculate_dynamic_stops(
            atr,
            self.config.ATR_MULTIPLIER_SL,
            self.config.ATR_MULTIPLIER_TP,
            current_price,
            signal
        )

        # Calculate position size
        position_size = self.risk_manager.calculate_position_size(
            self.balance,
            current_price,
            stop_loss
        )

        # Validate trade
        is_valid, message = self.risk_manager.validate_trade(
            self.balance,
            position_size,
            current_price
        )

        if not is_valid:
            logger.error(f"Trade validation failed: {message}")
            return

        # Calculate risk/reward
        rr_ratio = self.risk_manager.calculate_risk_reward_ratio(
            current_price,
            stop_loss,
            take_profit
        )

        logger.info(f"📊 Trade Setup:")
        logger.info(f"   Direction: {signal.upper()}")
        logger.info(f"   Entry: ${current_price:.2f}")
        logger.info(f"   Size: {position_size:.6f} BTC")
        logger.info(f"   Stop Loss: ${stop_loss:.2f}")
        logger.info(f"   Take Profit: ${take_profit:.2f}")
        logger.info(f"   Risk/Reward: {rr_ratio:.2f}:1")

        # Execute order
        if self.config.DRY_RUN:
            logger.info("📝 PAPER TRADE - Order not sent to exchange")
            position_id = f"paper_{int(time.time())}"
        else:
            try:
                order = self._place_market_order(signal, position_size)
                position_id = str(order['id'])
                logger.info(f"✅ Order executed: {position_id}")
            except Exception as e:
                logger.error(f"❌ Order execution failed: {e}")
                return

        # Track position
        self.position_tracker.add_position(
            position_id,
            self.config.SYMBOL,
            signal,
            current_price,
            position_size,
            stop_loss,
            take_profit
        )

    def _place_market_order(self, side: str, amount: float) -> dict:
        """Place market order on exchange"""
        return self.exchange.create_market_order(
            self.config.SYMBOL,
            side,
            amount
        )

    def manage_open_positions(self):
        """Manage open positions (trailing stops, monitoring)"""
        positions = self.position_tracker.get_all_positions()

        if not positions:
            return

        bid, ask = self.get_current_price()
        current_price = (bid + ask) / 2

        for pos_id, position in list(positions.items()):
            # Calculate current P&L
            pnl = self.position_tracker.calculate_position_pnl(pos_id, current_price)

            if pnl is not None:
                pnl_pct = (pnl / (position['entry_price'] * position['size'])) * 100
                logger.debug(
                    f"Position {pos_id}: P&L ${pnl:.2f} ({pnl_pct:+.2f}%)"
                )

                # Update trailing stop
                if self.config.USE_TRAILING:
                    self.trailing_manager.update_position_stop(
                        pos_id,
                        position['entry_price'],
                        current_price,
                        position['stop_loss'],
                        position['type']
                    )

    def run(self, iterations: Optional[int] = None):
        """
        Main bot loop

        Args:
            iterations: Number of iterations (None for infinite)
        """
        self.is_running = True
        iteration = 0

        logger.info("🚀 Bot started!")

        try:
            while self.is_running:
                iteration += 1

                if iterations and iteration > iterations:
                    logger.info("Maximum iterations reached")
                    break

                # Update balance
                self.update_balance()

                # Check if new bar
                if not self.is_new_bar(datetime.now(timezone.utc)):
                    time.sleep(10)
                    continue

                logger.info(f"📊 New bar detected - Analyzing...")

                # Check trading filters
                if not self.check_trading_filters():
                    time.sleep(10)
                    continue

                # Fetch primary timeframe data
                df = self.fetch_ohlcv(self.config.PRIMARY_TIMEFRAME, limit=100)

                if df.empty:
                    logger.warning("No data available")
                    time.sleep(10)
                    continue

                # Add indicators
                df = TechnicalIndicators.add_all_indicators(
                    df,
                    self.config.FAST_EMA,
                    self.config.SLOW_EMA,
                    self.config.ATR_PERIOD
                )

                # Check higher timeframe confirmation
                if not self.check_higher_timeframe_confirmation():
                    logger.debug("No H4 confirmation")
                    time.sleep(10)
                    continue

                # Manage existing positions
                self.manage_open_positions()

                # Check for entry signals
                signal = self.analyze_entry_signal(df)

                if signal:
                    bid, ask = self.get_current_price()
                    entry_price = ask if signal == 'buy' else bid
                    current_atr = df['atr'].iloc[-1]

                    self.execute_trade(signal, entry_price, current_atr)

                # Sleep before next iteration
                time.sleep(10)

        except KeyboardInterrupt:
            logger.info("🛑 Bot stopped by user")
        except Exception as e:
            logger.error(f"❌ Bot error: {e}", exc_info=True)
        finally:
            self.is_running = False
            logger.info("Bot shutdown complete")

    def stop(self):
        """Stop the bot"""
        logger.info("Stopping bot...")
        self.is_running = False


def main():
    """Main entry point"""
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()

    # Initialize bot
    bot = BTCSmartBot()

    # Run bot
    try:
        bot.run()
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)


if __name__ == "__main__":
    main()
