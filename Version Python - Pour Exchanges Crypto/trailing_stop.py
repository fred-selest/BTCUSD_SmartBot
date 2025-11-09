"""
Trailing Stop Manager for BTCUSD SmartBot
Implements intelligent trailing stop logic
"""

import logging
from typing import Optional, Dict
from datetime import datetime
from indicators import MarketAnalyzer
from risk_manager import RiskManager
from config import TradingConfig

logger = logging.getLogger(__name__)


class TrailingStopManager:
    """Manages trailing stops for open positions"""

    def __init__(
        self,
        config: TradingConfig = TradingConfig,
        risk_manager: Optional[RiskManager] = None
    ):
        self.config = config
        self.risk_manager = risk_manager or RiskManager(config)
        self.trailing_active = {}  # Track which positions have trailing active

    def should_activate_trailing(
        self,
        position_id: str,
        entry_price: float,
        current_price: float,
        position_type: str
    ) -> bool:
        """
        Check if trailing stop should be activated for a position

        Args:
            position_id: Position identifier
            entry_price: Entry price
            current_price: Current market price
            position_type: 'buy' or 'sell'

        Returns:
            True if trailing should be activated
        """
        if not self.config.USE_TRAILING:
            return False

        # Check if already active
        if self.trailing_active.get(position_id, False):
            return True

        # Calculate current profit percentage
        profit_pct = MarketAnalyzer.calculate_position_profit(
            entry_price, current_price, position_type
        )

        # Activate if profit threshold reached
        if profit_pct >= self.config.TRAIL_START_PERCENT:
            self.trailing_active[position_id] = True
            logger.info(
                f"Trailing stop activated for {position_id} "
                f"at {profit_pct:.2f}% profit"
            )
            return True

        return False

    def calculate_new_stop(
        self,
        position_id: str,
        entry_price: float,
        current_price: float,
        current_stop: float,
        position_type: str
    ) -> Optional[float]:
        """
        Calculate new trailing stop price

        Args:
            position_id: Position identifier
            entry_price: Entry price
            current_price: Current market price
            current_stop: Current stop loss
            position_type: 'buy' or 'sell'

        Returns:
            New stop price or None if no update needed
        """
        # Check if trailing should be active
        if not self.should_activate_trailing(
            position_id, entry_price, current_price, position_type
        ):
            return None

        # Calculate new stop using risk manager
        new_stop = self.risk_manager.calculate_trailing_stop(
            entry_price, current_price, current_stop, position_type
        )

        if new_stop:
            logger.info(
                f"New trailing stop calculated for {position_id}: "
                f"{current_stop:.2f} -> {new_stop:.2f}"
            )

        return new_stop

    def update_position_stop(
        self,
        position_id: str,
        entry_price: float,
        current_price: float,
        current_stop: float,
        position_type: str,
        exchange_update_callback=None
    ) -> bool:
        """
        Update position stop loss with trailing logic

        Args:
            position_id: Position identifier
            entry_price: Entry price
            current_price: Current market price
            current_stop: Current stop loss
            position_type: 'buy' or 'sell'
            exchange_update_callback: Function to update stop on exchange

        Returns:
            True if stop was updated
        """
        new_stop = self.calculate_new_stop(
            position_id, entry_price, current_price, current_stop, position_type
        )

        if new_stop is None:
            return False

        # Validate new stop is beneficial
        if not self._validate_stop_update(new_stop, current_stop, position_type):
            return False

        # Update on exchange if callback provided
        if exchange_update_callback:
            try:
                success = exchange_update_callback(position_id, new_stop)
                if success:
                    logger.info(f"Stop loss updated on exchange: {new_stop:.2f}")
                    return True
                else:
                    logger.error("Failed to update stop loss on exchange")
                    return False
            except Exception as e:
                logger.error(f"Error updating stop on exchange: {e}")
                return False

        return True

    def _validate_stop_update(
        self,
        new_stop: float,
        current_stop: float,
        position_type: str
    ) -> bool:
        """
        Validate that new stop is beneficial

        Args:
            new_stop: Proposed new stop
            current_stop: Current stop
            position_type: 'buy' or 'sell'

        Returns:
            True if update is valid
        """
        if position_type.lower() == 'buy':
            # For long positions, new stop should be higher
            if current_stop > 0 and new_stop <= current_stop:
                return False
        elif position_type.lower() == 'sell':
            # For short positions, new stop should be lower
            if current_stop > 0 and new_stop >= current_stop:
                return False

        return True

    def reset_trailing(self, position_id: str):
        """Reset trailing stop activation for a position"""
        if position_id in self.trailing_active:
            del self.trailing_active[position_id]
            logger.info(f"Trailing stop reset for {position_id}")

    def get_trailing_status(self, position_id: str) -> bool:
        """Check if trailing is active for a position"""
        return self.trailing_active.get(position_id, False)

    def get_all_trailing_positions(self) -> Dict[str, bool]:
        """Get all positions with trailing active"""
        return self.trailing_active.copy()


class BreakevenManager:
    """Manages breakeven stop loss adjustments"""

    def __init__(self, breakeven_trigger_pct: float = 0.5):
        """
        Args:
            breakeven_trigger_pct: Profit % to trigger breakeven move
        """
        self.breakeven_trigger_pct = breakeven_trigger_pct
        self.breakeven_set = {}

    def should_move_to_breakeven(
        self,
        position_id: str,
        entry_price: float,
        current_price: float,
        position_type: str
    ) -> bool:
        """
        Check if stop should be moved to breakeven

        Args:
            position_id: Position identifier
            entry_price: Entry price
            current_price: Current market price
            position_type: 'buy' or 'sell'

        Returns:
            True if should move to breakeven
        """
        # Already at breakeven
        if self.breakeven_set.get(position_id, False):
            return False

        # Calculate profit
        profit_pct = MarketAnalyzer.calculate_position_profit(
            entry_price, current_price, position_type
        )

        # Trigger breakeven
        if profit_pct >= self.breakeven_trigger_pct:
            self.breakeven_set[position_id] = True
            logger.info(
                f"Breakeven triggered for {position_id} "
                f"at {profit_pct:.2f}% profit"
            )
            return True

        return False

    def get_breakeven_price(
        self,
        entry_price: float,
        commission_pct: float = 0.1
    ) -> float:
        """
        Calculate breakeven price including commissions

        Args:
            entry_price: Entry price
            commission_pct: Total commission percentage (buy + sell)

        Returns:
            Breakeven price
        """
        # Add small buffer for commissions
        buffer = entry_price * (commission_pct / 100.0)
        return entry_price + buffer

    def reset_breakeven(self, position_id: str):
        """Reset breakeven status for a position"""
        if position_id in self.breakeven_set:
            del self.breakeven_set[position_id]
