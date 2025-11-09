"""
Example script to test BTCUSD SmartBot with historical data
Simple backtesting simulation
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta

from indicators import TechnicalIndicators, MarketAnalyzer
from risk_manager import RiskManager
from config import TradingConfig


def generate_sample_data(days: int = 30) -> pd.DataFrame:
    """
    Generate sample OHLCV data for testing

    Args:
        days: Number of days of data

    Returns:
        DataFrame with OHLCV data
    """
    periods = days * 24  # Hourly data
    dates = pd.date_range(end=datetime.now(), periods=periods, freq='1h')

    # Generate realistic BTC price movement
    base_price = 45000
    prices = []
    current = base_price

    for _ in range(periods):
        change = np.random.normal(0, 200)  # Random walk
        current = current + change
        current = max(current, 20000)  # Floor price
        prices.append(current)

    # Create OHLCV
    df = pd.DataFrame()
    df['timestamp'] = dates
    df['close'] = prices

    # Generate OHLC from close with some randomness
    df['open'] = df['close'].shift(1).fillna(df['close'])
    df['high'] = df[['open', 'close']].max(axis=1) + np.random.uniform(0, 100, len(df))
    df['low'] = df[['open', 'close']].min(axis=1) - np.random.uniform(0, 100, len(df))
    df['volume'] = np.random.uniform(100, 1000, len(df))

    df.set_index('timestamp', inplace=True)

    return df


def simple_backtest():
    """Run a simple backtest simulation"""

    print("=" * 60)
    print("BTCUSD SmartBot - Backtest Simulation")
    print("=" * 60)

    # Configuration
    config = TradingConfig()
    initial_balance = 10000  # $10,000 starting capital
    balance = initial_balance

    # Generate sample data
    print("\n📊 Generating sample data...")
    df = generate_sample_data(days=30)

    # Add indicators
    df = TechnicalIndicators.add_all_indicators(
        df,
        config.FAST_EMA,
        config.SLOW_EMA,
        config.ATR_PERIOD
    )

    # Drop NaN values
    df = df.dropna()

    print(f"✅ Data loaded: {len(df)} candles")
    print(f"📅 Period: {df.index[0]} to {df.index[-1]}")
    print(f"💰 Starting balance: ${balance:.2f}\n")

    # Trading simulation
    position = None
    trades = []
    risk_manager = RiskManager(config)

    for i in range(2, len(df)):
        current_bar = df.iloc[:i+1]

        # Check for signals
        bullish, bearish = TechnicalIndicators.detect_ema_crossover(
            current_bar['ema_fast'],
            current_bar['ema_slow']
        )

        current_price = current_bar['close'].iloc[-1]
        current_atr = current_bar['atr'].iloc[-1]

        # Close position if signal reverses
        if position:
            if (position['type'] == 'buy' and bearish) or \
               (position['type'] == 'sell' and bullish):

                # Close position
                if position['type'] == 'buy':
                    pnl = (current_price - position['entry']) * position['size']
                else:
                    pnl = (position['entry'] - current_price) * position['size']

                balance += pnl
                trades.append({
                    'type': position['type'],
                    'entry': position['entry'],
                    'exit': current_price,
                    'pnl': pnl,
                    'balance': balance
                })

                print(f"🔄 Close {position['type'].upper()}: "
                      f"${position['entry']:.2f} → ${current_price:.2f} | "
                      f"P&L: ${pnl:+.2f} | Balance: ${balance:.2f}")

                position = None

        # Open new position
        if position is None and balance > 0:
            if bullish or bearish:
                signal = 'buy' if bullish else 'sell'

                # Calculate stops
                stop_loss, take_profit = TechnicalIndicators.calculate_dynamic_stops(
                    current_atr,
                    config.ATR_MULTIPLIER_SL,
                    config.ATR_MULTIPLIER_TP,
                    current_price,
                    signal
                )

                # Calculate position size
                position_size = risk_manager.calculate_position_size(
                    balance,
                    current_price,
                    stop_loss
                )

                position = {
                    'type': signal,
                    'entry': current_price,
                    'stop_loss': stop_loss,
                    'take_profit': take_profit,
                    'size': position_size
                }

                print(f"{'🟢' if signal == 'buy' else '🔴'} Open {signal.upper()}: "
                      f"${current_price:.2f} | "
                      f"Size: {position_size:.6f} BTC | "
                      f"SL: ${stop_loss:.2f} | TP: ${take_profit:.2f}")

    # Final results
    print("\n" + "=" * 60)
    print("BACKTEST RESULTS")
    print("=" * 60)

    if trades:
        df_trades = pd.DataFrame(trades)
        winning_trades = len(df_trades[df_trades['pnl'] > 0])
        losing_trades = len(df_trades[df_trades['pnl'] < 0])
        win_rate = (winning_trades / len(trades)) * 100 if trades else 0

        total_pnl = balance - initial_balance
        roi = (total_pnl / initial_balance) * 100

        print(f"\n📊 Performance:")
        print(f"   Total Trades: {len(trades)}")
        print(f"   Winning Trades: {winning_trades}")
        print(f"   Losing Trades: {losing_trades}")
        print(f"   Win Rate: {win_rate:.1f}%")
        print(f"\n💰 Financial:")
        print(f"   Starting Balance: ${initial_balance:.2f}")
        print(f"   Final Balance: ${balance:.2f}")
        print(f"   Total P&L: ${total_pnl:+.2f}")
        print(f"   ROI: {roi:+.2f}%")

        if len(trades) > 0:
            avg_win = df_trades[df_trades['pnl'] > 0]['pnl'].mean() if winning_trades > 0 else 0
            avg_loss = df_trades[df_trades['pnl'] < 0]['pnl'].mean() if losing_trades > 0 else 0

            print(f"\n📈 Trade Analysis:")
            print(f"   Average Win: ${avg_win:.2f}")
            print(f"   Average Loss: ${avg_loss:.2f}")
            print(f"   Best Trade: ${df_trades['pnl'].max():.2f}")
            print(f"   Worst Trade: ${df_trades['pnl'].min():.2f}")
    else:
        print("\n⚠️  No trades were executed")

    print("\n" + "=" * 60)


if __name__ == "__main__":
    simple_backtest()
