//+------------------------------------------------------------------+
//|                            BTCUSD_SmartBot_Pro.mq5                |
//|                   Bot Intelligent BTCUSD - Version Professionnelle |
//|                       Compatible MetaTrader 5 - Windows Server     |
//+------------------------------------------------------------------+
#property copyright "BTCUSD SmartBot Pro"
#property link      "https://github.com/fred-selest/BTCUSD_SmartBot"
#property version   "1.01"
#property description "Bot BTCUSD avec stratégie EMA, ATR, Trailing Stop intelligent"
#property description "Optimisé pour VPS Windows Server 2022"

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

   //--- Affichage des informations
   Print("═══════════════════════════════════════════════════════");
   Print("🤖 BTCUSD SmartBot Pro - Initialisé avec succès");
   Print("═══════════════════════════════════════════════════════");
   Print("📊 Symbole: ", _Symbol);
   Print("💰 Balance: ", DoubleToString(accountInfo.Balance(), 2), " ", accountInfo.Currency());
   Print("🎯 Risque par trade: ", DoubleToString(InpRiskPercent, 2), "%");
   Print("📈 EMA: ", InpFastEMA, "/", InpSlowEMA);
   Print("📊 ATR: ", InpATRPeriod, " | TP: x", InpATR_MultiplierTP, " | SL: x", InpATR_MultiplierSL);
   Print("🎯 Trailing: ", (InpUseTrailing ? "ON" : "OFF"), " | Activation: ", InpTrailActivation, "%");
   Print("🔄 Confirmation H4: ", (InpUseH4Confirmation ? "ON" : "OFF"));
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

   //--- Afficher panneau d'informations
   if(InpShowPanel)
      ShowInfoPanel();

   //--- Vérifier les filtres
   if(!CheckTradingFilters()) return;

   //--- Copier les données des indicateurs
   if(CopyBuffer(handleEMAFast, 0, 0, 3, emaFastBuffer) < 3) return;
   if(CopyBuffer(handleEMASlow, 0, 0, 3, emaSlowBuffer) < 3) return;
   if(CopyBuffer(handleATR, 0, 0, 2, atrBuffer) < 2) return;

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
      Print("⚠️ Spread trop élevé: ", spread, " > ", InpMaxSpread);
      return false;
   }

   //--- Vérifier l'ATR
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

   //--- Calculer les paramètres du trade
   double atr = atrBuffer[0];
   double slDistance = atr * InpATR_MultiplierSL;
   double tpDistance = atr * InpATR_MultiplierTP;

   //--- Trade BUY
   if(bullishCross)
   {
      double ask = symbolInfo.Ask();
      double sl = NormalizeDouble(ask - slDistance, _Digits);
      double tp = NormalizeDouble(ask + tpDistance, _Digits);

      double lotSize = CalculateLotSize(ask, sl);

      if(lotSize > 0)
      {
         Print("🟢 Signal BUY détecté");
         Print("   Entry: ", ask, " | SL: ", sl, " | TP: ", tp);
         Print("   Lot: ", lotSize, " | ATR: ", DoubleToString(atr, 2));

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

   //--- Trade SELL
   else if(bearishCross)
   {
      double bid = symbolInfo.Bid();
      double sl = NormalizeDouble(bid + slDistance, _Digits);
      double tp = NormalizeDouble(bid - tpDistance, _Digits);

      double lotSize = CalculateLotSize(bid, sl);

      if(lotSize > 0)
      {
         Print("🔴 Signal SELL détecté");
         Print("   Entry: ", bid, " | SL: ", sl, " | TP: ", tp);
         Print("   Lot: ", lotSize, " | ATR: ", DoubleToString(atr, 2));

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
