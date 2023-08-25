//+------------------------------------------------------------------+
//|                                     Copyright 2023, Tech Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tech Mornach"
#property link      "https://techmornach.vercel.app"
#property version   "1.00"

//+------------------------------------------------------------------+
//|  include                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "../libraries/errror_description.mqh"
#include "../technical_analysis/technical_analysis.mqh"


//+------------------------------------------------------------------+
//|  define                                                          |
//+------------------------------------------------------------------+
#define MAX_RISK_PERCENT 10

//+------------------------------------------------------------------+
//|  Class Declaration                                               |
//+------------------------------------------------------------------+
class CExpert : public CTrade
{
private:
    double LotSize;
    double AccountBalance;
    double TickSize;
    double StopLoss;
    string MailSubject;

    void SetTickSize(string pSymbol);
    void SetLotSize(string pSymbol, int pStopPoints, double pFixedVolume, double pPercent);
    void SetAccountBalance();
    double VerifyVolume(string pSymbol, double pVolume);
    double SetStopLoss(string position, int pStopPoints);

public:
    CExpert(void);
    ~CExpert(void);
    bool CreateOrder(string pSymbol, int pStopPoints, double pFixedVolume, double pPercent);
    bool ModifyOrder(string pSymbol, double pProfit);
};

//+------------------------------------------------------------------+
//|  Class Functions                                                 |
//+------------------------------------------------------------------+

CExpert::CExpert()
{
    MailSubject = "Trading Alert";
}
CExpert::~CExpert()
{
    // Destructor cleanup code, if needed
}
void CExpert::SetTickSize(string pSymbol)
{
    TickSize = SymbolInfoDouble(pSymbol, SYMBOL_TRADE_TICK_SIZE);
}

void CExpert::SetAccountBalance()
{
    AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
}

void CExpert::SetLotSize(string pSymbol, int pStopPoints, double pFixedVolume, double pPercent)
{
    double tradeSize;
    SetAccountBalance();
    SetTickSize(pSymbol);

    if (pPercent >= MAX_RISK_PERCENT)
    {
        pPercent = MAX_RISK_PERCENT;
    }

    if (pPercent > 0 && pStopPoints > 0)
    {
        double margin = AccountBalance * pPercent / 100;
        tradeSize = (margin / pStopPoints) / TickSize;
        tradeSize = VerifyVolume(pSymbol, tradeSize);
        LotSize = tradeSize;
    }
    else
    {
        tradeSize = pFixedVolume;
        tradeSize = VerifyVolume(pSymbol, tradeSize);
        LotSize = tradeSize;
    }
}

double CExpert::VerifyVolume(string pSymbol, double pVolume)
{
    double minVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MIN);
    double maxVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
    double stepVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_STEP);
    double tradeSize;

    if (pVolume < minVolume)
        tradeSize = minVolume;
    else if (pVolume > maxVolume)
        tradeSize = maxVolume;
    else
        tradeSize = MathRound(pVolume / stepVolume) * stepVolume;

    if (stepVolume >= 0.1)
        tradeSize = NormalizeDouble(tradeSize, 1);
    else
        tradeSize = NormalizeDouble(tradeSize, 2);

    return (tradeSize);
}

double CExpert::SetStopLoss(string position, int pStopPoints)
{
    double StopLoss;

    if (position == "buy")
    {
        StopLoss = SymbolInfoDouble(Symbol(), SYMBOL_BID) - (pStopPoints * _Point);
    }
    else if (position == "sell")
    {
        StopLoss = SymbolInfoDouble(Symbol(), SYMBOL_ASK) + (pStopPoints * _Point);
    }

    return StopLoss;
}

bool CExpert::CreateOrder(string pSymbol, int pStopPoints, double pFixedVolume, double pPercent)
{
    SetLotSize(pSymbol, pStopPoints, pFixedVolume, pPercent);
    string technical_analysis = technical_analysis(pSymbol);
    if (technical_analysis == "buy") // Add your buy condition here
    {
        double StopLoss = SetStopLoss("buy", pStopPoints);
        if (Buy(LotSize, pSymbol, SYMBOL_ASK, StopLoss) == 0)
        {
            Comment("Buy order executed for " + LotSize + " of " + _Symbol + " at " + SYMBOL_ASK  + ", for $" + ResultPrice() + ", Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            SendMail(MailSubject, "Buy order executed for " + DoubleToString(LotSize, 2) + " lots of " + _Symbol + " at " + DoubleToString(SYMBOL_ASK, _Digits) + ", Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            SendNotification("Buy order executed for " + DoubleToString(LotSize, 2) + " lots of " + _Symbol + " at " + DoubleToString(SYMBOL_ASK, _Digits) + ", Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            return true;
        }
        else
        {
            Alert("Error placing buy order: " + ResultRetcodeDescription());
            SendMail(MailSubject, "Error placing buy order: " + ResultRetcodeDescription());
        }
    }
    else if (technical_analysis == "sell") // Add your sell condition here
    {
        double StopLoss = SetStopLoss("sell", pStopPoints);
        if (Sell(LotSize, pSymbol, SYMBOL_BID, StopLoss) == 0)
        {
            Comment("Sell order executed for " + LotSize + " of " + _Symbol + " at " + SYMBOL_BID + ", for $" + ResultPrice()+ ",Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            SendMail(MailSubject, "Sell order executed for " + DoubleToString(LotSize, 2) + " lots of " + _Symbol + " at " + DoubleToString(SYMBOL_BID, _Digits) + ", Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            SendNotification("Sell order executed for " + DoubleToString(LotSize, 2) + " lots of " + _Symbol + " at " + DoubleToString(SYMBOL_ASK, _Digits) + ", Code " + ResultRetcode() + " - " + ResultRetcodeDescription());
            return true;
        }
        else
        {
            Alert("Error placing sell order: " + ResultRetcodeDescription());
            SendMail(MailSubject, "Error placing sell order: " + ResultRetcodeDescription());
        }
    }
    else
    {
        Comment("Market is Uncertain");
        return false;
    }

    return false;
}
bool CExpert::ModifyOrder(string pSymbol, double pProfit)
{
    long posType = PositionGetInteger(POSITION_TYPE);
    double currentStop = PositionGetDouble(POSITION_SL); 
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);

    double trailStop = 1500  * _Point;

    double trailStopPrice;
    double currentProfit;
    double takeProfitPrice;

    Print("The Position is", PositionGetInteger(POSITION_TYPE));

    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
    {
        Print("buy");
        Print(_Point);
        takeProfitPrice = (pProfit * _Point); // profit target
        trailStopPrice = SymbolInfoDouble(pSymbol, SYMBOL_BID) - trailStop;
        trailStopPrice = AdjustBelowStopLevel(pSymbol, trailStopPrice);
        currentProfit = SymbolInfoDouble(pSymbol, SYMBOL_BID) - openPrice;

        Print(currentProfit, " ", takeProfitPrice);

        //Print(currentProfit, " - ", takeProfitPrice, " - ", trailStopPrice , "buy");

        if (currentProfit >= takeProfitPrice)
        {
            if (PositionClose(pSymbol) == true)
            {
                Comment("Buy order closed at profit target - " + CheckResultProfit());
                SendMail(MailSubject, "Buy order closed at profit target - " + CheckResultProfit());
                SendNotification("Buy order closed at profit target - " + CheckResultProfit());
                return true;
            }
            else
            {
                Alert("Error closing buy order: " + ErrorDescription(GetLastError()));
                SendMail(MailSubject, "Error closing buy order: " + ErrorDescription(GetLastError()));
                SendNotification("Error closing buy order: " + ErrorDescription(GetLastError()));
                return false;
            }
        }

        if(trailStopPrice > currentStop)
        {
            if (PositionModify(pSymbol, trailStopPrice, takeProfitPrice) == true)
            {
                Comment("Stop Loss Modified");
                return true;
            }
            else
            {
                Alert("Error Modifying Stop Loss: " + trailStopPrice + ErrorDescription(GetLastError()));
                return false;
            }
        }
    }
    else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
    {
        Print("sell");
        takeProfitPrice = (pProfit * _Point); // profit target
        trailStopPrice = SymbolInfoDouble(pSymbol, SYMBOL_ASK) + trailStop;
        trailStopPrice = AdjustAboveStopLevel(pSymbol, trailStopPrice);
        currentProfit = openPrice - SymbolInfoDouble(pSymbol, SYMBOL_ASK);

        if (currentProfit >= takeProfitPrice)
        {
            if (PositionClose(pSymbol) == true)
            {
                Comment("Sell order closed at profit target - " + CheckResultProfit());
                SendMail(MailSubject, "Sell order closed at profit target - " + CheckResultProfit());
                SendNotification("Sell order closed at profit target - " + CheckResultProfit());
                return true;
            }
            else
            {
                Alert("Error closing sell order: " + ErrorDescription(GetLastError()));
                SendMail(MailSubject, "Error closing sell order: " + ErrorDescription(GetLastError()));
                SendNotification("Error closing sell order: " + ErrorDescription(GetLastError()));
                return false;
            }
        }
        if(trailStopPrice < currentStop) 
        {
            if (PositionModify(pSymbol, trailStopPrice, takeProfitPrice) == true)
            {
                Comment("Stop Loss Modified");
                return true;
            }
            else
            {
                Alert("Error closing sell order: " + ErrorDescription(GetLastError()));
                return false;
            }
        }
    }
    return false;
}

double AdjustBelowStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
    double currPrice = SymbolInfoDouble(pSymbol, SYMBOL_BID);
    double point = SymbolInfoDouble(pSymbol, SYMBOL_POINT);
    double stopLevel = SymbolInfoInteger(pSymbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
    double stopPrice = currPrice - stopLevel;
    double subtractPoints = pPoints * point;
    
    if (pPrice > (stopPrice - subtractPoints))
    {
        double newPrice = stopPrice - subtractPoints;
        Print("Price adjusted below stop level to ", DoubleToString(newPrice));
        return newPrice;
    }
    
    return pPrice;
}

double AdjustAboveStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
    double currPrice = SymbolInfoDouble(pSymbol, SYMBOL_ASK);
    double point = SymbolInfoDouble(pSymbol, SYMBOL_POINT);
    double stopLevel = SymbolInfoInteger(pSymbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
    double stopPrice = currPrice + stopLevel; // Adjusted for above-level stop
    double addPoints = pPoints * point;
    
    if (pPrice < (stopPrice + addPoints))
    {
        double newPrice = stopPrice + addPoints;
        Print("Price adjusted above stop level to ", DoubleToString(newPrice));
        return newPrice;
    }
    
    return pPrice;
}


