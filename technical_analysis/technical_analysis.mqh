//+------------------------------------------------------------------+
//|                                           technical_analysis.mqh |
//|                                                          Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Mornach"
#property link      "https://techmornach.vercel.app"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 includes                                                     |
//+------------------------------------------------------------------+
#include "./candle_stick_analysis.mqh"
#include "./hot_market.mqh"
#include "./swing.mqh"
#include "../Telegram/Telegram.mqh"
//+------------------------------------------------------------------+

string InpChannelName="1945135712";//Channel Name
string InpToken="6575227379:AAFqGrQG3KWyGTkK1JSAuiN49ZW-W0gdbv4";
long InpChannelId = 1945135712;
string indicatorAnalysis;
string imageId;
string imagePath = "chart.png";

CCustomBot bot;



string technical_analysis( string pSymbol)
{
    bool checked;
    bot.Token(InpToken);
    ChartScreenShot(0, "chart.png", 640, 480 );
    if(StringLen(InpChannelName)==0)
      {
         Print("Error: Channel name is empty");
         Sleep(10000);
         return false;
      }

    int result=bot.GetMe();
    if(result==0) checked =  true;
    string hotmarket = GetTradingDecisionHotMarket(pSymbol, _Period, indicatorAnalysis);
    string swing = GetTradingDecisionSwing(pSymbol, _Period, indicatorAnalysis);
    string buyMessage = StringFormat("Omni Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nPrice: %s\nTechnical Analysis: %s\nDecision: Buy📈",
                                 pSymbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(pSymbol,SYMBOL_ASK),_Digits), indicatorAnalysis);
    string sellMessage = StringFormat("Omni Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nPrice: %s\nTechnical Analysis: %s\nDecision: Sell📉",
                                 pSymbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(pSymbol,SYMBOL_BID),_Digits), indicatorAnalysis);
/*     if(swing == "buy")
    {
            SendNotification(buyMessage);
            Comment(buyMessage);
            int res = bot.SendPhoto(imageId, InpChannelId, imagePath, buyMessage);
            if(res!=0)
            Print("Telegram Bot Error: ",GetErrorDescription(res));
        return("buy");
    }
    else if(swing == "sell")
    {
            SendNotification(sellMessage);
            Comment(sellMessage);
            int res = bot.SendPhoto(imageId, InpChannelId, imagePath, sellMessage);
            if(res!=0)
            Print("Telegram Bot Error: ",GetErrorDescription(res));
        return("sell");
    }
    else  */if(hotmarket == "buy")
    {
            SendNotification(buyMessage);


            Comment(buyMessage);
            int res = bot.SendPhoto(imageId, InpChannelId, imagePath, buyMessage);
            if(res!=0)
            Print("Telegram Bot Error: ",GetErrorDescription(res));
        return("buy");
    }
    else if(hotmarket == "sell")
    {
            SendNotification(sellMessage);
            Comment(sellMessage);
            int res = bot.SendPhoto(imageId, InpChannelId, imagePath, sellMessage);
            if(res!=0)
            Print("Telegram Bot Error: ",GetErrorDescription(res));
        return("sell");
    }
    else
    {
        return("uncertain");
    }
}