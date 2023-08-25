//+------------------------------------------------------------------+
//|                                     Copyright 2023, Tech Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tech Mornach"
#property link      "https://techmornach.vercel.app"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include Files
//+------------------------------------------------------------------+
#include "classes/trader_bot.mqh"
//+------------------------------------------------------------------+
//| Input parameters
//+------------------------------------------------------------------+
input double RiskManagement = 5; // Risk Management in Percentage
input double FixedLot = 0.01; // Fixed Lot Size
input int TrailingStop = 1000; // Trailing Stop in Points
input double PercentProfit = 3000; //Profit to cancel trade in Points

//+------------------------------------------------------------------+
//| Classes                                                          |
//+------------------------------------------------------------------+
CExpert Omni_Trader;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() 
{
   string imageId;
   string Message = StringFormat("Hello Traders😁\nWelcome to our trading session📉📈, We'll be focusing on the %s💹 currency pair on the 1 Minute timeframe🕜\nRemember to set your stoplosses and take profit and remember always trade responsible⛑\nTrading isn't Gambling🚫\nStay Tuned as the Signals Come in🚀", _Symbol);
   string InpToken="6575227379:AAFqGrQG3KWyGTkK1JSAuiN49ZW-W0gdbv4";
   long InpChannelId = 1945135712;
   bot.Token(InpToken);
   int res = bot.SendPhoto(imageId, InpChannelId, "bot.jpg", Message);
   if(res!=0)
   Print("Telegram Bot Error: ",GetErrorDescription(res));
   Comment("Omni Bot is Running now");
   SendNotification("OmniBot is Running now");
   //ChartApplyTemplate(0, "./template/simple.tpl");
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) 
{
   
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() 
{
   if (ACCOUNT_BALANCE < 1)
   {
      do{
         Alert("Account Balance is low");
      }
      while(ACCOUNT_BALANCE < 1);
   }
   
   if(PositionSelect(_Symbol) == false){
      Omni_Trader.CreateOrder(_Symbol, TrailingStop, FixedLot, RiskManagement);
   }
   else{
      if (Omni_Trader.ModifyOrder(_Symbol, PercentProfit))
      {
         Alert("Modification Failed");
      }
   }
}

//+------------------------------------------------------------------+