"""
Risk Management Module for BTCUSD SmartBot
Handles position sizing, risk calculation, and capital management
"""

import logging
from typing import Tuple, Optional
from config import TradingConfig

logger = logging.getLogger(__name__)


class RiskManager:
    """Manages trading risk and position sizing"""

    def __init__(self, config: TradingConfig = TradingConfig):
        self.config = config
        self.risk_percent = config.RISK_PERCENT
        self.min_order_size = config.MIN_ORDER_SIZE

    def calculate_position_size(
        self,
        balance: float,
        entry_price: float,
        stop_loss: float,
        leverage: float = 1.0
    ) -> float:
        """
        Calculate position size based on risk percentage

        Formula: Position Size = (Account Balance × Risk %) / (Entry Price - Stop Loss)

        Args:
            balance: Account balance in USD
            entry_price: Planned entry price
            stop_loss: Stop loss price
            leverage: Trading leverage (default: 1.0)

        Returns:
            Position size in BTC
        """
        # Risk amount in USD
        risk_amount = balance * (self.risk_percent / 100.0)

        # Distance from entry to stop loss
        price_distance = abs(entry_price - stop_loss)

        if price_distance == 0:
            logger.warning("Price distance is zero, using minimum position size")
            return self.min_order_size

        # Calculate position size
        position_size = (risk_amount / price_distance) * leverage

        # Round to appropriate precision
        position_size = round(position_size, 6)

        # Ensure minimum size
        if position_size < self.min_order_size:
            logger.warning(
                f"Calculated position size {position_size} below minimum "
                f"{self.min_order_size}, adjusting"
            )
            position_size = self.min_order_size

        logger.info(
            f"Position size calculated: {position_size} BTC "
            f"(Risk: ${risk_amount:.2f}, Distance: ${price_distance:.2f})"
        )

        return position_size

    def calculate_position_value(self, position_size: float, price: float) -> float:
        """
        Calculate position value in USD

        Args:
            position_size: Position size in BTC
            price: Current BTC price

        Returns:
            Position value in USD
        """
        return position_size * price

    def validate_trade(
        self,
        balance: float,
        position_size: float,
        entry_price: float,
        leverage: float = 1.0
    ) -> Tuple[bool, str]:
        """
        Validate if trade is acceptable based on risk rules

        Args:
            balance: Account balance in USD
            position_size: Proposed position size in BTC
            entry_price: Entry price
            leverage: Trading leverage

        Returns:
            Tuple (is_valid, message)
        """
        # Calculate position value
        position_value = self.calculate_position_value(position_size, entry_price)

        # Check if position value exceeds balance (considering leverage)
        max_position_value = balance * leverage
        if position_value > max_position_value:
            return False, f"Position value ${position_value:.2f} exceeds maximum ${max_position_value:.2f}"

        # Check minimum position size
        if position_size < self.min_order_size:
            return False, f"Position size {position_size} below minimum {self.min_order_size}"

        # Check risk percentage
        max_risk = balance * (self.risk_percent / 100.0)
        if position_value > balance * 0.5:  # Safety check: never risk more than 50% of balance
            return False, f"Position value too high relative to balance"

        return True, "Trade validation passed"

    def calculate_risk_reward_ratio(
        self,
        entry_price: float,
        stop_loss: float,
        take_profit: float
    ) -> float:
        """
        Calculate risk/reward ratio

        Args:
            entry_price: Entry price
            stop_loss: Stop loss price
            take_profit: Take profit price

        Returns:
            Risk/reward ratio (e.g., 2.5 means 2.5:1)
        """
        risk = abs(entry_price - stop_loss)
        reward = abs(take_profit - entry_price)

        if risk == 0:
            return 0.0

        return reward / risk

    def should_trail_stop(self, current_profit_pct: float) -> bool:
        """
        Determine if trailing stop should be activated

        Args:
            current_profit_pct: Current profit percentage

        Returns:
            True if trailing should be activated
        """
        return current_profit_pct >= self.config.TRAIL_START_PERCENT

    def calculate_trailing_stop(
        self,
        entry_price: float,
        current_price: float,
        current_stop: float,
        position_type: str
    ) -> Optional[float]:
        """
        Calculate new trailing stop price

        Args:
            entry_price: Entry price
            current_price: Current market price
            current_stop: Current stop loss
            position_type: 'buy' or 'sell'

        Returns:
            New stop loss price or None if shouldn't update
        """
        trail_distance = current_price * (self.config.TRAIL_STEP_PERCENT / 100.0)

        if position_type.lower() == 'buy':
            new_stop = current_price - trail_distance

            # Only move stop up, never down
            if new_stop > current_stop:
                return round(new_stop, 2)

        elif position_type.lower() == 'sell':
            new_stop = current_price + trail_distance

            # Only move stop down, never up
            if new_stop < current_stop or current_stop == 0:
                return round(new_stop, 2)

        return None


class PositionTracker:
    """Tracks open positions and their performance"""

    def __init__(self):
        self.positions = {}

    def add_position(
        self,
        position_id: str,
        symbol: str,
        position_type: str,
        entry_price: float,
        size: float,
        stop_loss: float,
        take_profit: float
    ):
        """Add a new position to tracker"""
        self.positions[position_id] = {
            'symbol': symbol,
            'type': position_type,
            'entry_price': entry_price,
            'size': size,
            'stop_loss': stop_loss,
            'take_profit': take_profit,
            'highest_profit': 0.0,
            'lowest_profit': 0.0
        }
        logger.info(f"Position {position_id} added: {position_type} {size} @ {entry_price}")

    def remove_position(self, position_id: str):
        """Remove position from tracker"""
        if position_id in self.positions:
            del self.positions[position_id]
            logger.info(f"Position {position_id} removed")

    def update_position_stop(self, position_id: str, new_stop: float):
        """Update stop loss for a position"""
        if position_id in self.positions:
            self.positions[position_id]['stop_loss'] = new_stop
            logger.info(f"Position {position_id} stop updated to {new_stop}")

    def get_position(self, position_id: str) -> Optional[dict]:
        """Get position details"""
        return self.positions.get(position_id)

    def get_all_positions(self) -> dict:
        """Get all tracked positions"""
        return self.positions

    def get_position_count(self) -> int:
        """Get number of open positions"""
        return len(self.positions)

    def calculate_position_pnl(
        self,
        position_id: str,
        current_price: float
    ) -> Optional[float]:
        """
        Calculate current P&L for a position

        Args:
            position_id: Position identifier
            current_price: Current market price

        Returns:
            P&L in USD or None if position not found
        """
        position = self.get_position(position_id)
        if not position:
            return None

        entry_price = position['entry_price']
        size = position['size']
        pos_type = position['type']

        if pos_type.lower() == 'buy':
            pnl = (current_price - entry_price) * size
        elif pos_type.lower() == 'sell':
            pnl = (entry_price - current_price) * size
        else:
            return None

        # Track highest/lowest profit
        if pnl > position['highest_profit']:
            position['highest_profit'] = pnl
        if pnl < position['lowest_profit']:
            position['lowest_profit'] = pnl

        return pnl

    def is_max_positions_reached(self, max_positions: int) -> bool:
        """Check if maximum number of positions is reached"""
        return self.get_position_count() >= max_positions
