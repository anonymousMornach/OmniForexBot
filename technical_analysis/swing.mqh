//+------------------------------------------------------------------+
//|                                     Copyright 2023, Tech Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tech Mornach"
#property link      "https://techmornach.vercel.app"
#property version   "1.00"

input int HHLLLookback = 5;  // Lookback period to find HHLL pattern
input double slippage = 3;   // Slippage for order execution

string GetTradingDecisionSwing(string pSymbol, ENUM_TIMEFRAMES _Period, string &_Indicator_Analysis)
{
    string decision = "";
    int bars = Bars(pSymbol, _Period);

    double highBuffer[];
    double lowBuffer[];

    ArraySetAsSeries(highBuffer, true);
    ArraySetAsSeries(lowBuffer, true);

    int highHandle = iHigh(pSymbol, _Period, 0);
    int lowHandle = iLow(pSymbol, _Period, 0);

    CopyBuffer(highHandle, 0, 0, bars, highBuffer);
    CopyBuffer(lowHandle, 0, 0, bars, lowBuffer);

    // Determine market trend
    bool isBullishTrend = true;
    for (int i = 1; i < HHLLLookback; i++) {
        if (highBuffer[i] <= highBuffer[i - 1] || lowBuffer[i] <= lowBuffer[i - 1]) {
            isBullishTrend = false;
            break;
        }
    }

    bool isBearishTrend = true;
    for (int i = 1; i < HHLLLookback; i++) {
        if (highBuffer[i] >= highBuffer[i - 1] || lowBuffer[i] >= lowBuffer[i - 1]) {
            isBearishTrend = false;
            break;
        }
    }

    // Find HHLL pattern
    bool isHHLLLong = false;
    bool isHHLLShort = false;

    for (int i = 0; i < HHLLLookback; i++) {
        if (highBuffer[i] > highBuffer[i+1] && lowBuffer[i] > lowBuffer[i+1]) {
            isHHLLLong = true;
        }
        if (highBuffer[i] < highBuffer[i+1] && lowBuffer[i] < lowBuffer[i+1]) {
            isHHLLShort = true;
        }
    }

    // Trading decision based on HHLL pattern and trend
    if (isBullishTrend && isHHLLLong) {
        _Indicator_Analysis = "Bullish HHLL Long pattern: Buy signal";
        decision = "buy";
    }
    else if (isBearishTrend && isHHLLShort) {
        _Indicator_Analysis = "Bearish HHLL Short pattern: Sell signal";
        decision = "sell";
    }
    else {
        _Indicator_Analysis = "No clear trading signal";
        decision = "uncertain";
    }

    return decision;
}
