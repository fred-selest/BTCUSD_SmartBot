"""
Technical Indicators for BTCUSD SmartBot
Implements EMA and ATR calculations
"""

import pandas as pd
import numpy as np
from typing import Tuple, Optional


class TechnicalIndicators:
    """Technical analysis indicators for trading strategy"""

    @staticmethod
    def calculate_ema(data: pd.DataFrame, period: int, column: str = 'close') -> pd.Series:
        """
        Calculate Exponential Moving Average

        Args:
            data: DataFrame with OHLCV data
            period: EMA period
            column: Column to calculate EMA on (default: 'close')

        Returns:
            Series with EMA values
        """
        return data[column].ewm(span=period, adjust=False).mean()

    @staticmethod
    def calculate_atr(data: pd.DataFrame, period: int = 14) -> pd.Series:
        """
        Calculate Average True Range (ATR)

        Args:
            data: DataFrame with OHLCV data (high, low, close)
            period: ATR period

        Returns:
            Series with ATR values
        """
        high = data['high']
        low = data['low']
        close = data['close']

        # True Range calculation
        tr1 = high - low
        tr2 = abs(high - close.shift())
        tr3 = abs(low - close.shift())

        tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)

        # ATR is the moving average of True Range
        atr = tr.rolling(window=period).mean()

        return atr

    @staticmethod
    def detect_ema_crossover(fast_ema: pd.Series, slow_ema: pd.Series) -> Tuple[bool, bool]:
        """
        Detect EMA crossover signals

        Args:
            fast_ema: Fast EMA series
            slow_ema: Slow EMA series

        Returns:
            Tuple (bullish_cross, bearish_cross)
            - bullish_cross: Fast EMA crosses above Slow EMA
            - bearish_cross: Fast EMA crosses below Slow EMA
        """
        if len(fast_ema) < 2 or len(slow_ema) < 2:
            return False, False

        # Current and previous values
        fast_curr = fast_ema.iloc[-1]
        fast_prev = fast_ema.iloc[-2]
        slow_curr = slow_ema.iloc[-1]
        slow_prev = slow_ema.iloc[-2]

        # Bullish crossover: fast crosses above slow
        bullish_cross = (fast_prev <= slow_prev) and (fast_curr > slow_curr)

        # Bearish crossover: fast crosses below slow
        bearish_cross = (fast_prev >= slow_prev) and (fast_curr < slow_curr)

        return bullish_cross, bearish_cross

    @staticmethod
    def check_trend_alignment(fast_ema: pd.Series, slow_ema: pd.Series) -> str:
        """
        Check current trend alignment based on EMA positions

        Args:
            fast_ema: Fast EMA series
            slow_ema: Slow EMA series

        Returns:
            'bullish', 'bearish', or 'neutral'
        """
        if len(fast_ema) == 0 or len(slow_ema) == 0:
            return 'neutral'

        fast_curr = fast_ema.iloc[-1]
        slow_curr = slow_ema.iloc[-1]

        if fast_curr > slow_curr:
            return 'bullish'
        elif fast_curr < slow_curr:
            return 'bearish'
        else:
            return 'neutral'

    @staticmethod
    def calculate_dynamic_stops(
        atr: float,
        atr_multiplier_sl: float,
        atr_multiplier_tp: float,
        entry_price: float,
        direction: str
    ) -> Tuple[float, float]:
        """
        Calculate dynamic Stop Loss and Take Profit based on ATR

        Args:
            atr: Current ATR value
            atr_multiplier_sl: Multiplier for Stop Loss
            atr_multiplier_tp: Multiplier for Take Profit
            entry_price: Entry price
            direction: 'buy' or 'sell'

        Returns:
            Tuple (stop_loss, take_profit)
        """
        sl_distance = atr * atr_multiplier_sl
        tp_distance = atr * atr_multiplier_tp

        if direction.lower() == 'buy':
            stop_loss = entry_price - sl_distance
            take_profit = entry_price + tp_distance
        elif direction.lower() == 'sell':
            stop_loss = entry_price + sl_distance
            take_profit = entry_price - tp_distance
        else:
            raise ValueError(f"Invalid direction: {direction}")

        return stop_loss, take_profit

    @staticmethod
    def add_all_indicators(
        data: pd.DataFrame,
        fast_ema_period: int = 9,
        slow_ema_period: int = 21,
        atr_period: int = 14
    ) -> pd.DataFrame:
        """
        Add all indicators to the dataframe

        Args:
            data: DataFrame with OHLCV data
            fast_ema_period: Fast EMA period
            slow_ema_period: Slow EMA period
            atr_period: ATR period

        Returns:
            DataFrame with added indicator columns
        """
        df = data.copy()

        # Calculate EMAs
        df['ema_fast'] = TechnicalIndicators.calculate_ema(df, fast_ema_period)
        df['ema_slow'] = TechnicalIndicators.calculate_ema(df, slow_ema_period)

        # Calculate ATR
        df['atr'] = TechnicalIndicators.calculate_atr(df, atr_period)

        return df


class MarketAnalyzer:
    """Analyzes market conditions for trading decisions"""

    @staticmethod
    def check_volatility(atr: float, min_atr: float) -> bool:
        """
        Check if market volatility is sufficient for trading

        Args:
            atr: Current ATR value
            min_atr: Minimum required ATR

        Returns:
            True if volatility is sufficient
        """
        return atr >= min_atr

    @staticmethod
    def check_spread(bid: float, ask: float, max_spread: float) -> bool:
        """
        Check if spread is acceptable

        Args:
            bid: Bid price
            ask: Ask price
            max_spread: Maximum acceptable spread

        Returns:
            True if spread is acceptable
        """
        spread = abs(ask - bid)
        return spread <= max_spread

    @staticmethod
    def is_trading_hours(current_hour: int, start_hour: int, end_hour: int) -> bool:
        """
        Check if current time is within trading hours

        Args:
            current_hour: Current hour (0-23)
            start_hour: Start hour (0-23)
            end_hour: End hour (0-23)

        Returns:
            True if within trading hours
        """
        if start_hour <= end_hour:
            return start_hour <= current_hour < end_hour
        else:
            # Handle overnight periods (e.g., 22:00 to 02:00)
            return current_hour >= start_hour or current_hour < end_hour

    @staticmethod
    def calculate_position_profit(
        entry_price: float,
        current_price: float,
        position_type: str
    ) -> float:
        """
        Calculate current position profit percentage

        Args:
            entry_price: Entry price
            current_price: Current market price
            position_type: 'buy' or 'sell'

        Returns:
            Profit percentage (can be negative)
        """
        if position_type.lower() == 'buy':
            profit_pct = ((current_price - entry_price) / entry_price) * 100
        elif position_type.lower() == 'sell':
            profit_pct = ((entry_price - current_price) / entry_price) * 100
        else:
            return 0.0

        return profit_pct
