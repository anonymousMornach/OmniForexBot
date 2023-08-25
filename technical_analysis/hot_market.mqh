//+------------------------------------------------------------------+
//|                                     Copyright 2023, Tech Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tech Mornach"
#property link      "https://techmornach.vercel.app"
#property version   "1.00"

input int cciPeriod = 14;
input int cci2Period = 6;

string GetTradingDecisionHotMarket(string pSymbol, ENUM_TIMEFRAMES _Period, string &_Indicator_Analysis)
{
    string decision = "";
    int bars = Bars(pSymbol, _Period);

    // CCI
    int cciHandle = iCCI(pSymbol, _Period, cciPeriod, PRICE_CLOSE);
    int cci2Handle = iCCI(pSymbol, _Period, cci2Period, PRICE_CLOSE);
    double cciBuffer[];
    double cci2Buffer[];
    CopyBuffer(cciHandle, 0, 0, bars, cciBuffer);
    CopyBuffer(cci2Handle, 0, 0, bars, cci2Buffer);

    // Candlestick Pattern Detection
    double candleCloseTime = iClose(pSymbol, _Period, bars - 1);
    double candleOpenTime = iOpen(pSymbol, _Period, bars - 1);
    double candleHigh = iHigh(pSymbol, _Period, bars - 1);
    double candleLow = iLow(pSymbol, _Period, bars - 1);
    double candleBody = MathAbs(candleCloseTime - candleOpenTime);

    // Determine if the chart crosses the zero line
    bool chartCrossesZeroLine = false;
    if ((cciBuffer[bars - 2] < 0 && cciBuffer[bars - 1] > 0) || (cciBuffer[bars - 2] > 0 && cciBuffer[bars - 1] < 0))
    {
        chartCrossesZeroLine = true;
    }

    // Trend Reversal Candlestick Pattern Detection
    bool isTrendReversalPattern = false;
    if (candleCloseTime < candleOpenTime && cciBuffer[bars - 2] < 0)
    {
        isTrendReversalPattern = true;
    }

    // Trading decision
    if (chartCrossesZeroLine && isTrendReversalPattern)
    {
        if (cciBuffer[bars - 1] > 0 && cci2Buffer[bars - 1] > 0)
        {
            _Indicator_Analysis = "CCI conditions and trend reversal pattern met";
            decision = "buy";
        }
        else if (cciBuffer[bars - 1] < 0 && cci2Buffer[bars - 1] < 0)
        {
            _Indicator_Analysis = "CCI conditions and trend reversal pattern met";
            decision = "sell";
        }
        else
        {
            _Indicator_Analysis = "No clear trading signal";
            decision = "uncertain";
        }
    }
    else
    {
        _Indicator_Analysis = "No clear trading signal";
        decision = "uncertain";
    }

    return decision;
}
