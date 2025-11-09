//+------------------------------------------------------------------+
//|                            BTCUSD_SmartBot_Pro.mq5                |
//|                   Bot Intelligent BTCUSD - Version Professionnelle |
//|                       Compatible MetaTrader 5 - Windows Server     |
//+------------------------------------------------------------------+
#property copyright "BTCUSD SmartBot Pro"
#property link      "https://github.com/fred-selest/BTCUSD_SmartBot"
#property version   "1.05"
#property description "Bot BTCUSD avec stratégie EMA, ATR, Trailing Stop intelligent"
#property description "Grid Lot Multiplier Fix - VPS Windows Server 2022"

//--- Includes
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| Paramètres d'entrée                                              |
//+------------------------------------------------------------------+

//--- Risk Management
input group "=== GESTION DU RISQUE ==="
input double   InpRiskPercent       = 1.0;        // Risque par trade (% du capital)
input double   InpMaxPositions      = 1;          // Nombre max de positions
input double   InpMinBalance        = 100;        // Balance minimum (USD)

//--- Strategy Parameters
input group "=== PARAMETRES STRATEGIE ==="
input int      InpFastEMA           = 9;          // EMA Rapide (période)
input int      InpSlowEMA           = 21;         // EMA Lente (période)
input int      InpATRPeriod         = 14;         // Période ATR
input double   InpATR_MultiplierTP  = 2.5;        // Multiplicateur TP (ATR x)
input double   InpATR_MultiplierSL  = 1.5;        // Multiplicateur SL (ATR x)

//--- Filters
input group "=== FILTRES DE TRADING ==="
input double   InpMinATR            = 50.0;       // ATR minimum (USD)
input int      InpMaxSpread         = 100;        // Spread maximum (points)
input int      InpStartHour         = 0;          // Heure début (0 = désactivé)
input int      InpEndHour           = 23;         // Heure fin (23 = 24h/24)

//--- Trailing Stop
input group "=== TRAILING STOP ==="
input bool     InpUseTrailing       = true;       // Activer Trailing Stop
input double   InpTrailActivation   = 1.0;        // Activation (% de profit)
input double   InpTrailDistance     = 0.5;        // Distance de trailing (%)
input bool     InpUseBreakeven      = true;       // Activer Breakeven
input double   InpBreakevenTrigger  = 0.5;        // Trigger Breakeven (% profit)

//--- Grid & Martingale
input group "=== GRID TRADING & MARTINGALE ==="
input bool     InpUseGrid           = false;      // Activer Grid Trading
input int      InpMaxGridLevels     = 3;          // Niveaux max de Grid (1-5)
input double   InpGridStepATR       = 1.0;        // Distance grille (x ATR)
input double   InpGridLotMultiplier = 1.0;        // Multiplicateur de lot (1.0-2.0)
input bool     InpUseMartingale     = false;      // Activer Martingale
input double   InpMartingaleMulti   = 1.5;        // Multiplicateur Martingale (1.2-2.0)
input int      InpMaxMartingale     = 3;          // Niveaux max Martingale (1-5)
input double   InpMaxDrawdownPct    = 20.0;       // Drawdown max % (sécurité)

//--- Advanced Settings
input group "=== PARAMETRES AVANCES ==="
input bool     InpUseH4Confirmation = true;       // Confirmation H4
input int      InpMagicNumber       = 202511;     // Magic Number
input int      InpSlippage          = 10;         // Slippage maximum
input string   InpTradeComment      = "BTC_Smart";// Commentaire des trades
input bool     InpShowPanel         = true;       // Afficher panneau info

//+------------------------------------------------------------------+
//| Variables globales                                                |
//+------------------------------------------------------------------+
CTrade         trade;
CPositionInfo  positionInfo;
CAccountInfo   accountInfo;
CSymbolInfo    symbolInfo;

int            handleEMAFast;
int            handleEMASlow;
int            handleATR;
int            handleEMAFast_H4;
int            handleEMASlow_H4;

double         emaFastBuffer[];
double         emaSlowBuffer[];
double         atrBuffer[];
double         emaFastBuffer_H4[];
double         emaSlowBuffer_H4[];

datetime       lastBarTime = 0;
bool           trailingActive[];
bool           breakevenSet[];

//--- Grid & Martingale variables
struct GridLevel
{
   double   price;           // Prix du niveau
   double   lotSize;         // Taille du lot
   ulong    ticket;          // Ticket de l'ordre
   int      level;           // Numéro du niveau (0, 1, 2...)
   bool     isActive;        // Niveau actif
};

GridLevel      gridLevelsBuy[];    // Niveaux de grille BUY
GridLevel      gridLevelsSell[];   // Niveaux de grille SELL
int            currentGridLevel = 0;
int            consecutiveLosses = 0;
double         initialLotSize = 0;
double         highestEquity = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Configuration du trade
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetAsyncMode(false);

   //--- Configuration du symbole
   if(!symbolInfo.Name(_Symbol))
   {
      Print("❌ Erreur: Impossible de charger le symbole ", _Symbol);
      return(INIT_FAILED);
   }
   symbolInfo.Refresh();

   //--- Vérification du symbole
   if(_Symbol != "BTCUSD" && _Symbol != "BTCUSD.m" && StringFind(_Symbol, "BTC") == -1)
   {
      Print("⚠️ Attention: Ce bot est optimisé pour BTCUSD. Symbole actuel: ", _Symbol);
   }

   //--- Initialisation des indicateurs H1
   handleEMAFast = iMA(_Symbol, PERIOD_H1, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleEMASlow = iMA(_Symbol, PERIOD_H1, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   handleATR = iATR(_Symbol, PERIOD_H1, InpATRPeriod);

   if(handleEMAFast == INVALID_HANDLE || handleEMASlow == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("❌ Erreur: Impossible de créer les indicateurs H1");
      return(INIT_FAILED);
   }

   //--- Initialisation des indicateurs H4
   if(InpUseH4Confirmation)
   {
      handleEMAFast_H4 = iMA(_Symbol, PERIOD_H4, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
      handleEMASlow_H4 = iMA(_Symbol, PERIOD_H4, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);

      if(handleEMAFast_H4 == INVALID_HANDLE || handleEMASlow_H4 == INVALID_HANDLE)
      {
         Print("❌ Erreur: Impossible de créer les indicateurs H4");
         return(INIT_FAILED);
      }
   }

   //--- Configuration des buffers
   ArraySetAsSeries(emaFastBuffer, true);
   ArraySetAsSeries(emaSlowBuffer, true);
   ArraySetAsSeries(atrBuffer, true);
   ArraySetAsSeries(emaFastBuffer_H4, true);
   ArraySetAsSeries(emaSlowBuffer_H4, true);

   //--- Initialisation des tableaux de tracking
   ArrayResize(trailingActive, 100);
   ArrayResize(breakevenSet, 100);
   ArrayInitialize(trailingActive, false);
   ArrayInitialize(breakevenSet, false);

   //--- Initialiser les grilles
   if(InpUseGrid)
   {
      ArrayResize(gridLevelsBuy, InpMaxGridLevels);
      ArrayResize(gridLevelsSell, InpMaxGridLevels);
   }

   //--- Affichage des informations
   Print("═══════════════════════════════════════════════════════");
   Print("🤖 BTCUSD SmartBot Pro v1.05 - Initialisé avec succès");
   Print("═══════════════════════════════════════════════════════");
   Print("📊 Symbole: ", _Symbol);
   Print("💰 Balance: ", DoubleToString(accountInfo.Balance(), 2), " ", accountInfo.Currency());
   Print("🎯 Risque par trade: ", DoubleToString(InpRiskPercent, 2), "%");
   Print("📈 EMA: ", InpFastEMA, "/", InpSlowEMA);
   Print("📊 ATR: ", InpATRPeriod, " | TP: x", InpATR_MultiplierTP, " | SL: x", InpATR_MultiplierSL);
   Print("🎯 Trailing: ", (InpUseTrailing ? "ON" : "OFF"), " | Activation: ", InpTrailActivation, "%");
   Print("🔄 Confirmation H4: ", (InpUseH4Confirmation ? "ON" : "OFF"));

   if(InpUseGrid || InpUseMartingale)
   {
      Print("--- GRID & MARTINGALE ---");
      if(InpUseGrid)
         Print("📊 Grid: ON | Niveaux: ", InpMaxGridLevels, " | Step: ", InpGridStepATR, " ATR | Multi: x", InpGridLotMultiplier);
      if(InpUseMartingale)
         Print("🎲 Martingale: ON | Multi: x", InpMartingaleMulti, " | Max: ", InpMaxMartingale);
      Print("⚠️ Drawdown Max: ", InpMaxDrawdownPct, "%");
   }

   Print("═══════════════════════════════════════════════════════");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Libération des indicateurs
   if(handleEMAFast != INVALID_HANDLE) IndicatorRelease(handleEMAFast);
   if(handleEMASlow != INVALID_HANDLE) IndicatorRelease(handleEMASlow);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   if(handleEMAFast_H4 != INVALID_HANDLE) IndicatorRelease(handleEMAFast_H4);
   if(handleEMASlow_H4 != INVALID_HANDLE) IndicatorRelease(handleEMASlow_H4);

   //--- Suppression des objets graphiques
   ObjectsDeleteAll(0, "SmartBot_");

   Print("🛑 BTCUSD SmartBot Pro - Arrêté (Raison: ", GetDeinitReasonText(reason), ")");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Vérifier nouvelle barre
   if(!IsNewBar()) return;

   //--- Mettre à jour les informations
   symbolInfo.Refresh();
   symbolInfo.RefreshRates();

   //--- Copier les données des indicateurs AVANT les vérifications
   if(CopyBuffer(handleEMAFast, 0, 0, 3, emaFastBuffer) < 3) return;
   if(CopyBuffer(handleEMASlow, 0, 0, 3, emaSlowBuffer) < 3) return;
   if(CopyBuffer(handleATR, 0, 0, 2, atrBuffer) < 2) return;

   //--- Afficher panneau d'informations
   if(InpShowPanel)
      ShowInfoPanel();

   //--- Vérifier les filtres
   if(!CheckTradingFilters()) return;

   //--- Vérifier confirmation H4
   if(InpUseH4Confirmation)
   {
      if(!CheckH4Confirmation()) return;
   }

   //--- Gérer les positions existantes
   ManageOpenPositions();

   //--- Vérifier le nombre de positions
   if(CountPositions() >= InpMaxPositions)
      return;

   //--- Analyser les signaux d'entrée
   AnalyzeAndTrade();
}

//+------------------------------------------------------------------+
//| Vérifie si nouvelle barre                                        |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, PERIOD_H1, 0);

   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Vérifie les filtres de trading                                   |
//+------------------------------------------------------------------+
bool CheckTradingFilters()
{
   //--- Vérifier la balance minimum
   if(accountInfo.Balance() < InpMinBalance)
   {
      Comment("⚠️ Balance insuffisante: ", accountInfo.Balance(), " < ", InpMinBalance);
      return false;
   }

   //--- Vérifier les heures de trading
   if(InpStartHour > 0 && InpEndHour > 0)
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);

      if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
      {
         return false;
      }
   }

   //--- Vérifier le spread
   int spread = (int)symbolInfo.Spread();
   if(spread > InpMaxSpread)
   {
      // Ne pas afficher constamment si le spread est toujours élevé
      static datetime lastSpreadWarning = 0;
      if(TimeCurrent() - lastSpreadWarning > 3600) // 1x par heure
      {
         Print("⚠️ Spread trop élevé: ", spread, " > ", InpMaxSpread);
         lastSpreadWarning = TimeCurrent();
      }
      return false;
   }

   //--- Vérifier l'ATR (avec sécurité sur le tableau)
   if(ArraySize(atrBuffer) < 1)
   {
      return false; // Données ATR non disponibles
   }

   double currentATR = atrBuffer[0];
   if(currentATR < InpMinATR)
   {
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Vérifie la confirmation H4                                       |
//+------------------------------------------------------------------+
bool CheckH4Confirmation()
{
   if(CopyBuffer(handleEMAFast_H4, 0, 0, 2, emaFastBuffer_H4) < 2) return false;
   if(CopyBuffer(handleEMASlow_H4, 0, 0, 2, emaSlowBuffer_H4) < 2) return false;

   //--- Tendance haussière sur H4
   return (emaFastBuffer_H4[0] > emaSlowBuffer_H4[0]);
}

//+------------------------------------------------------------------+
//| Analyse et exécute les trades                                    |
//+------------------------------------------------------------------+
void AnalyzeAndTrade()
{
   //--- Détecter les croisements
   bool bullishCross = (emaFastBuffer[1] <= emaSlowBuffer[1]) && (emaFastBuffer[0] > emaSlowBuffer[0]);
   bool bearishCross = (emaFastBuffer[1] >= emaSlowBuffer[1]) && (emaFastBuffer[0] < emaSlowBuffer[0]);

   if(!bullishCross && !bearishCross)
      return;

   //--- Vérifier drawdown si Grid/Martingale activé
   if((InpUseGrid || InpUseMartingale) && !CheckDrawdownLimit())
   {
      Print("⚠️ Drawdown trop élevé - Trading désactivé");
      return;
   }

   //--- Calculer les paramètres du trade
   double atr = atrBuffer[0];

   //--- Trade BUY
   if(bullishCross)
   {
      double ask = symbolInfo.Ask();

      Print("🟢 Signal BUY détecté");
      Print("   Entry: ", ask, " | ATR: ", DoubleToString(atr, 2));

      // Utiliser Grid/Martingale si activé, sinon trade classique
      if(InpUseGrid || InpUseMartingale)
      {
         // Ouvrir premier niveau de grid
         if(OpenGridLevel("BUY", ask, atr, 0))
         {
            // Placer les niveaux suivants si Grid activé
            if(InpUseGrid)
               PlaceGridOrders("BUY", ask, atr);
         }
      }
      else
      {
         // Trade classique sans Grid/Martingale
         double slDistance = atr * InpATR_MultiplierSL;
         double tpDistance = atr * InpATR_MultiplierTP;
         double sl = NormalizeDouble(ask - slDistance, _Digits);
         double tp = NormalizeDouble(ask + tpDistance, _Digits);

         double lotSize = CalculateLotSize(ask, sl);

         if(lotSize > 0)
         {
            Print("   Lot: ", lotSize, " | SL: ", sl, " | TP: ", tp);

            if(trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
            {
               Print("✅ Ordre BUY exécuté - Ticket: ", trade.ResultOrder());
            }
            else
            {
               Print("❌ Erreur BUY: ", trade.ResultRetcodeDescription());
            }
         }
      }
   }

   //--- Trade SELL
   else if(bearishCross)
   {
      double bid = symbolInfo.Bid();

      Print("🔴 Signal SELL détecté");
      Print("   Entry: ", bid, " | ATR: ", DoubleToString(atr, 2));

      // Utiliser Grid/Martingale si activé, sinon trade classique
      if(InpUseGrid || InpUseMartingale)
      {
         // Ouvrir premier niveau de grid
         if(OpenGridLevel("SELL", bid, atr, 0))
         {
            // Placer les niveaux suivants si Grid activé
            if(InpUseGrid)
               PlaceGridOrders("SELL", bid, atr);
         }
      }
      else
      {
         // Trade classique sans Grid/Martingale
         double slDistance = atr * InpATR_MultiplierSL;
         double tpDistance = atr * InpATR_MultiplierTP;
         double sl = NormalizeDouble(bid + slDistance, _Digits);
         double tp = NormalizeDouble(bid - tpDistance, _Digits);

         double lotSize = CalculateLotSize(bid, sl);

         if(lotSize > 0)
         {
            Print("   Lot: ", lotSize, " | SL: ", sl, " | TP: ", tp);

            if(trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
            {
               Print("✅ Ordre SELL exécuté - Ticket: ", trade.ResultOrder());
            }
            else
            {
               Print("❌ Erreur SELL: ", trade.ResultRetcodeDescription());
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calcule la taille du lot                                         |
//+------------------------------------------------------------------+
double CalculateLotSize(double entryPrice, double stopLoss)
{
   double balance = accountInfo.Balance();
   double riskMoney = balance * InpRiskPercent / 100.0;

   double slDistance = MathAbs(entryPrice - stopLoss);
   if(slDistance == 0) return 0;

   double tickValue = symbolInfo.TickValue();
   double tickSize = symbolInfo.TickSize();

   double lotSize = riskMoney / (slDistance / tickSize * tickValue);

   //--- Normaliser le lot
   double minLot = symbolInfo.LotsMin();
   double maxLot = symbolInfo.LotsMax();
   double lotStep = symbolInfo.LotsStep();

   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);

   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Gère les positions ouvertes                                      |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i)) continue;
      if(positionInfo.Symbol() != _Symbol) continue;
      if(positionInfo.Magic() != InpMagicNumber) continue;

      ulong ticket = positionInfo.Ticket();
      double openPrice = positionInfo.PriceOpen();
      double currentSL = positionInfo.StopLoss();
      double currentTP = positionInfo.TakeProfit();
      ENUM_POSITION_TYPE posType = positionInfo.PositionType();

      //--- Calculer le profit en pourcentage
      double currentPrice = (posType == POSITION_TYPE_BUY) ? symbolInfo.Bid() : symbolInfo.Ask();
      double profitPercent = 0;

      if(posType == POSITION_TYPE_BUY)
         profitPercent = (currentPrice - openPrice) / openPrice * 100;
      else
         profitPercent = (openPrice - currentPrice) / openPrice * 100;

      //--- Breakeven
      if(InpUseBreakeven && !breakevenSet[i] && profitPercent >= InpBreakevenTrigger)
      {
         double newSL = NormalizeDouble(openPrice, _Digits);

         if(trade.PositionModify(ticket, newSL, currentTP))
         {
            breakevenSet[i] = true;
            Print("🎯 Breakeven activé pour #", ticket, " | SL: ", newSL);
         }
      }

      //--- Trailing Stop
      if(InpUseTrailing && profitPercent >= InpTrailActivation)
      {
         trailingActive[i] = true;

         double trailDistance = currentPrice * InpTrailDistance / 100.0;
         double newSL = 0;

         if(posType == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(currentPrice - trailDistance, _Digits);
            if(newSL > currentSL && newSL < currentPrice)
            {
               if(trade.PositionModify(ticket, newSL, currentTP))
               {
                  Print("📈 Trailing BUY #", ticket, " | Nouveau SL: ", newSL, " | Profit: ", DoubleToString(profitPercent, 2), "%");
               }
            }
         }
         else // SELL
         {
            newSL = NormalizeDouble(currentPrice + trailDistance, _Digits);
            if((newSL < currentSL || currentSL == 0) && newSL > currentPrice)
            {
               if(trade.PositionModify(ticket, newSL, currentTP))
               {
                  Print("📉 Trailing SELL #", ticket, " | Nouveau SL: ", newSL, " | Profit: ", DoubleToString(profitPercent, 2), "%");
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Compte les positions                                             |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i)) continue;
      if(positionInfo.Symbol() != _Symbol) continue;
      if(positionInfo.Magic() != InpMagicNumber) continue;

      count++;
   }

   return count;
}

//+------------------------------------------------------------------+
//| Affiche le panneau d'informations                                |
//+------------------------------------------------------------------+
void ShowInfoPanel()
{
   int yPos = 20;
   int xPos = 20;
   int lineHeight = 18;

   //--- Créer le panneau
   CreateLabel("SmartBot_Title", xPos, yPos, "🤖 BTCUSD SmartBot Pro", clrWhite, 10, "Arial Bold");
   yPos += lineHeight + 5;

   //--- Balance et Equity
   string balanceText = "💰 Balance: " + DoubleToString(accountInfo.Balance(), 2) + " " + accountInfo.Currency();
   CreateLabel("SmartBot_Balance", xPos, yPos, balanceText, clrLime, 9);
   yPos += lineHeight;

   string equityText = "💎 Equity: " + DoubleToString(accountInfo.Equity(), 2) + " " + accountInfo.Currency();
   CreateLabel("SmartBot_Equity", xPos, yPos, equityText, clrAqua, 9);
   yPos += lineHeight;

   //--- Positions
   int posCount = CountPositions();
   string posText = "📊 Positions: " + IntegerToString(posCount) + "/" + IntegerToString((int)InpMaxPositions);
   color posColor = (posCount > 0) ? clrYellow : clrGray;
   CreateLabel("SmartBot_Positions", xPos, yPos, posText, posColor, 9);
   yPos += lineHeight;

   //--- Spread
   int spread = (int)symbolInfo.Spread();
   string spreadText = "📡 Spread: " + IntegerToString(spread) + " pts";
   color spreadColor = (spread < InpMaxSpread) ? clrLime : clrRed;
   CreateLabel("SmartBot_Spread", xPos, yPos, spreadText, spreadColor, 9);
   yPos += lineHeight;

   //--- ATR
   double atr = (ArraySize(atrBuffer) > 0) ? atrBuffer[0] : 0;
   string atrText = "📈 ATR: " + DoubleToString(atr, 2) + " USD";
   color atrColor = (atr >= InpMinATR) ? clrLime : clrOrange;
   CreateLabel("SmartBot_ATR", xPos, yPos, atrText, atrColor, 9);
   yPos += lineHeight;

   //--- Tendance
   string trendText = "🎯 Tendance: ";
   color trendColor = clrGray;

   if(ArraySize(emaFastBuffer) > 0 && ArraySize(emaSlowBuffer) > 0)
   {
      if(emaFastBuffer[0] > emaSlowBuffer[0])
      {
         trendText += "HAUSSIERE";
         trendColor = clrLime;
      }
      else if(emaFastBuffer[0] < emaSlowBuffer[0])
      {
         trendText += "BAISSIERE";
         trendColor = clrRed;
      }
      else
      {
         trendText += "NEUTRE";
         trendColor = clrGray;
      }
   }

   CreateLabel("SmartBot_Trend", xPos, yPos, trendText, trendColor, 9);
}

//+------------------------------------------------------------------+
//| Crée un label                                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int fontSize = 8, string font = "Arial")
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, font);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

//+------------------------------------------------------------------+
//| Retourne le texte de la raison de désinitialisation              |
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason)
{
   switch(reason)
   {
      case REASON_PROGRAM:     return "Programme terminé";
      case REASON_REMOVE:      return "Expert supprimé du graphique";
      case REASON_RECOMPILE:   return "Expert recompilé";
      case REASON_CHARTCHANGE: return "Changement de symbole/période";
      case REASON_CHARTCLOSE:  return "Graphique fermé";
      case REASON_PARAMETERS:  return "Paramètres modifiés";
      case REASON_ACCOUNT:     return "Compte changé";
      case REASON_TEMPLATE:    return "Template appliqué";
      case REASON_INITFAILED:  return "Initialisation échouée";
      case REASON_CLOSE:       return "Terminal fermé";
      default:                 return "Raison inconnue";
   }
}

//+------------------------------------------------------------------+
//| GRID TRADING & MARTINGALE FUNCTIONS                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Vérifie le drawdown pour sécurité                                |
//+------------------------------------------------------------------+
bool CheckDrawdownLimit()
{
   double balance = accountInfo.Balance();
   double equity = accountInfo.Equity();

   if(highestEquity < equity)
      highestEquity = equity;

   if(highestEquity == 0)
      highestEquity = balance;

   double drawdownPct = ((highestEquity - equity) / highestEquity) * 100;

   if(drawdownPct >= InpMaxDrawdownPct)
   {
      Print("🛑 DRAWDOWN MAX ATTEINT: ", DoubleToString(drawdownPct, 2), "% >= ", InpMaxDrawdownPct, "%");
      Print("⚠️ ARRET DU TRADING - Fermer toutes les positions manuellement");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Calcule le lot avec Martingale                                   |
//+------------------------------------------------------------------+
double CalculateMartingaleLot(double baseLot, int lossCount)
{
   if(!InpUseMartingale || lossCount == 0)
      return baseLot;

   // Limiter le nombre de niveaux
   if(lossCount > InpMaxMartingale)
      lossCount = InpMaxMartingale;

   double lot = baseLot * MathPow(InpMartingaleMulti, lossCount);

   // Limites de sécurité
   double maxLot = symbolInfo.LotsMax();
   double minLot = symbolInfo.LotsMin();

   lot = MathMin(lot, maxLot);
   lot = MathMax(lot, minLot);

   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Calcule le lot pour le Grid                                      |
//+------------------------------------------------------------------+
double CalculateGridLot(double baseLot, int gridLevel)
{
   if(!InpUseGrid || gridLevel == 0)
      return baseLot;

   double lot = baseLot * MathPow(InpGridLotMultiplier, gridLevel);

   // Limites
   double maxLot = symbolInfo.LotsMax();
   double minLot = symbolInfo.LotsMin();

   lot = MathMin(lot, maxLot);
   lot = MathMax(lot, minLot);

   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Compte les positions de type Grid                                |
//+------------------------------------------------------------------+
int CountGridPositions(string direction)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!positionInfo.SelectByIndex(i)) continue;
      if(positionInfo.Symbol() != _Symbol) continue;
      if(positionInfo.Magic() != InpMagicNumber) continue;

      string comment = positionInfo.Comment();

      if(direction == "BUY" && positionInfo.PositionType() == POSITION_TYPE_BUY)
      {
         if(StringFind(comment, "Grid") >= 0 || StringFind(comment, InpTradeComment) >= 0)
            count++;
      }
      else if(direction == "SELL" && positionInfo.PositionType() == POSITION_TYPE_SELL)
      {
         if(StringFind(comment, "Grid") >= 0 || StringFind(comment, InpTradeComment) >= 0)
            count++;
      }
   }

   return count;
}

//+------------------------------------------------------------------+
//| Ouvre un niveau de Grid                                          |
//+------------------------------------------------------------------+
bool OpenGridLevel(string direction, double price, double atr, int gridLevel)
{
   // Vérifier drawdown
   if(!CheckDrawdownLimit())
      return false;

   // Vérifier nombre max de niveaux
   int currentLevels = CountGridPositions(direction);
   if(currentLevels >= InpMaxGridLevels)
   {
      Print("⚠️ Nombre max de niveaux Grid atteint: ", currentLevels);
      return false;
   }

   // Calculer les stops
   double slDistance = atr * InpATR_MultiplierSL;
   double tpDistance = atr * InpATR_MultiplierTP;

   // Calculer le lot (avec grid multiplier et martingale si activée)
   double baseLot = 0;

   if(gridLevel == 0)
   {
      // Premier niveau : calculer le lot basé sur le risque
      baseLot = CalculateLotSize(price,
                                 direction == "BUY" ? price - slDistance : price + slDistance);

      // Sauvegarder pour les niveaux suivants
      if(initialLotSize == 0)
         initialLotSize = baseLot;
   }
   else
   {
      // Niveaux 1+ : utiliser le lot initial du niveau 0
      baseLot = initialLotSize;
   }

   double gridLot = CalculateGridLot(baseLot, gridLevel);
   double finalLot = CalculateMartingaleLot(gridLot, consecutiveLosses);

   // Préparer l'ordre
   double sl = 0, tp = 0;
   string comment = InpTradeComment;

   if(InpUseGrid)
      comment = comment + "_Grid" + IntegerToString(gridLevel);

   if(InpUseMartingale && consecutiveLosses > 0)
      comment = comment + "_M" + IntegerToString(consecutiveLosses);

   // Normaliser le prix
   price = NormalizeDouble(price, _Digits);

   // Exécuter l'ordre
   bool success = false;
   ulong ticket = 0;

   if(direction == "BUY")
   {
      sl = NormalizeDouble(price - slDistance, _Digits);
      tp = NormalizeDouble(price + tpDistance, _Digits);

      // Level 0 : Ordre au marché
      // Level 1+ : Ordre limite (BuyLimit) sous le prix actuel
      if(gridLevel == 0)
      {
         success = trade.Buy(finalLot, _Symbol, 0, sl, tp, comment);
      }
      else
      {
         // BuyLimit : ordre d'achat en dessous du prix de marché
         success = trade.BuyLimit(finalLot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment);
      }

      ticket = trade.ResultOrder();

      if(success)
      {
         string orderType = (gridLevel == 0) ? "MARKET" : "LIMIT";
         Print("🟢 Grid BUY Level ", gridLevel, " (", orderType, ") | Lot: ", finalLot,
               " | Entry: ", price, " | SL: ", sl, " | TP: ", tp, " | M-Level: ", consecutiveLosses);
      }
   }
   else // SELL
   {
      sl = NormalizeDouble(price + slDistance, _Digits);
      tp = NormalizeDouble(price - tpDistance, _Digits);

      // Level 0 : Ordre au marché
      // Level 1+ : Ordre limite (SellLimit) au-dessus du prix actuel
      if(gridLevel == 0)
      {
         success = trade.Sell(finalLot, _Symbol, 0, sl, tp, comment);
      }
      else
      {
         // SellLimit : ordre de vente au-dessus du prix de marché
         success = trade.SellLimit(finalLot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment);
      }

      ticket = trade.ResultOrder();

      if(success)
      {
         string orderType = (gridLevel == 0) ? "MARKET" : "LIMIT";
         Print("🔴 Grid SELL Level ", gridLevel, " (", orderType, ") | Lot: ", finalLot,
               " | Entry: ", price, " | SL: ", sl, " | TP: ", tp, " | M-Level: ", consecutiveLosses);
      }
   }

   if(!success)
   {
      Print("❌ Erreur création Grid Level ", gridLevel, ": ", trade.ResultRetcodeDescription());
   }

   return success;
}

//+------------------------------------------------------------------+
//| Place les ordres Grid additionnels                               |
//+------------------------------------------------------------------+
void PlaceGridOrders(string direction, double entryPrice, double atr)
{
   if(!InpUseGrid)
      return;

   double gridStep = atr * InpGridStepATR;

   // Placer les niveaux de grille (ordres pending)
   for(int level = 1; level < InpMaxGridLevels; level++)
   {
      double gridPrice = 0;

      if(direction == "BUY")
      {
         // Pour les achats, placer des BuyLimit en dessous du prix d'entrée
         gridPrice = entryPrice - (gridStep * level);
      }
      else // SELL
      {
         // Pour les ventes, placer des SellLimit au-dessus du prix d'entrée
         gridPrice = entryPrice + (gridStep * level);
      }

      // Vérifier si un ordre existe déjà à ce niveau
      int existingLevels = CountGridPositions(direction);
      if(existingLevels >= level + 1)
         continue;

      // Créer l'ordre pending pour ce niveau de grid
      bool success = OpenGridLevel(direction, gridPrice, atr, level);

      if(success)
      {
         Print("📊 Grid Level ", level, " créé à ", DoubleToString(gridPrice, _Digits));
      }
      else
      {
         Print("⚠️ Échec création Grid Level ", level);
      }
   }
}

//+------------------------------------------------------------------+
//| Gère la fermeture et reset de la Martingale                      |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   // Détecter la fermeture d'une position
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(HistoryDealSelect(trans.deal))
      {
         long dealEntry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);

         // Si c'est une sortie (fermeture)
         if(dealEntry == DEAL_ENTRY_OUT)
         {
            double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);

            if(profit > 0)
            {
               // Reset martingale sur gain
               consecutiveLosses = 0;
               Print("✅ Trade gagnant - Reset Martingale");
            }
            else if(profit < 0)
            {
               // Incrémenter compteur de pertes
               if(InpUseMartingale)
               {
                  consecutiveLosses++;
                  if(consecutiveLosses > InpMaxMartingale)
                     consecutiveLosses = InpMaxMartingale;

                  Print("❌ Trade perdant - Martingale Level: ", consecutiveLosses);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
