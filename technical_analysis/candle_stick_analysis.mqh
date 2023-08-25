//+------------------------------------------------------------------+
//|                                     Copyright 2023, Tech Mornach |
//|                                   https://techmornach.vercel.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Tech Mornach"
#property link      "https://techmornach.vercel.app"
#property version   "1.00"

#include <Trade\Trade.mqh>

enum CandlePattern {
    NO_PATTERN,
    BULLISH_ENGULFING,
    BEARISH_ENGULFING,
    DOJI,
    HAMMER,
    SHOOTING_STAR,
    BULLISH_HARAMI,
    BEARISH_HARAMI,
    BULLISH_MARUBOZU,
    BEARISH_MARUBOZU,
    MORNING_STAR,
    EVENING_STAR,
    BULLISH_PIERCING,
    BEARISH_DARK_CLOUD,
    BULLISH_KICKING,
    BEARISH_KICKING,
    BULLISH_INVERTED_HAMMER,
    BEARISH_INVERTED_HAMMER,
    BULLISH_HAMMER,
    BEARISH_HANGING_MAN,
    // Add more patterns here...
};

CandlePattern IdentifyCandlePattern(double open, double close, double high, double low) {
    double bodySize = MathAbs(close - open);
    double shadowSize = MathMin(MathAbs(open - low), MathAbs(close - low));
    double realBodyTop = MathMax(open, close);
    double realBodyBottom = MathMin(open, close);

    double candleRange = high - low;
    double upperShadow = high - realBodyTop;
    double lowerShadow = realBodyBottom - low;

    double bodyToRangeRatio = bodySize / candleRange;
    double shadowToRangeRatio = shadowSize / candleRange;

    if (bodyToRangeRatio < 0.01) {
        if (shadowToRangeRatio > 0.95) {
            return DOJI;
        }
    } else if (bodyToRangeRatio < 0.3) {
        if (open < close && lowerShadow > bodySize * 3 && upperShadow <= bodySize * 0.5) {
            return HAMMER;
        } else if (open > close && upperShadow > bodySize * 3 && lowerShadow <= bodySize * 0.5) {
            return SHOOTING_STAR;
        }
    } else if (bodyToRangeRatio < 0.5) {
        if (open < close) {
            if (realBodyBottom > low && realBodyTop > high) {
                return BULLISH_ENGULFING;
            } else if (realBodyTop < high && realBodyBottom > low) {
                return BULLISH_HARAMI;
            }
        } else if (open > close) {
            if (realBodyTop < high && realBodyBottom > low) {
                return BEARISH_ENGULFING;
            } else if (realBodyBottom < low && realBodyTop > high) {
                return BEARISH_HARAMI;
            }
        }
    } else if (bodyToRangeRatio > 0.95) {
        if (open < close && lowerShadow < bodySize * 0.2 && upperShadow < bodySize * 0.2) {
            return BULLISH_MARUBOZU;
        } else if (open > close && lowerShadow < bodySize * 0.2 && upperShadow < bodySize * 0.2) {
            return BEARISH_MARUBOZU;
        }
    } else if (bodyToRangeRatio < 0.2) {
        if (open < close) {
            if (realBodyBottom > low && realBodyTop > high) {
                if (MathAbs(open - close) < bodySize * 0.2 && realBodyBottom > close) {
                    return MORNING_STAR;
                } else if (MathAbs(open - close) < bodySize * 0.2 && realBodyTop > close) {
                    return BULLISH_INVERTED_HAMMER;
                } else if (MathAbs(open - close) < bodySize * 0.2 && realBodyBottom <= close) {
                    return BULLISH_HAMMER;
                }
            }
        } else if (open > close) {
            if (realBodyTop < high && realBodyBottom > low) {
                if (MathAbs(open - close) < bodySize * 0.2 && realBodyTop > close) {
                    return EVENING_STAR;
                } else if (MathAbs(open - close) < bodySize * 0.2 && realBodyBottom > close) {
                    return BEARISH_HANGING_MAN;
                } else if (MathAbs(open - close) < bodySize * 0.2 && realBodyTop <= close) {
                    return BEARISH_INVERTED_HAMMER;
                }
            }
        }
    } else if (bodyToRangeRatio < 0.3) {
        if (open < close && close - open > bodySize * 0.7) {
            if (open > low && close <= (open + close) / 2) {
                return BULLISH_PIERCING;
            }
        } else if (open > close && open - close > bodySize * 0.7) {
            if (close > low && open <= (open + close) / 2) {
                return BEARISH_DARK_CLOUD;
            }
        }
    } else if (bodyToRangeRatio < 0.2) {
        if (open < close && open - low <= bodySize * 0.1 && high - close > bodySize * 2) {
            return BULLISH_KICKING;
        } else if (open > close && high - open <= bodySize * 0.1 && close - low > bodySize * 2) {
            return BEARISH_KICKING;
        }
    }

    return NO_PATTERN;
}

string GetPatternName(CandlePattern pattern) {
    switch (pattern) {
        case BULLISH_ENGULFING:
            return "Bullish Engulfing Pattern Detected";
        case BEARISH_ENGULFING:
            return "Bearish Engulfing Pattern Detected";
        case DOJI:
            return "Doji Pattern Detected";
        case HAMMER:
            return "Hammer Pattern Detected";
        case SHOOTING_STAR:
            return "Shooting Star Pattern Detected";
        case BULLISH_HARAMI:
            return "Bullish Harami Pattern Detected";
        case BEARISH_HARAMI:
            return "Bearish Harami Pattern Detected";
        case BULLISH_MARUBOZU:
            return "Bullish Marubozu Pattern Detected";
        case BEARISH_MARUBOZU:
            return "Bearish Marubozu Pattern Detected";
        case MORNING_STAR:
            return "Morning Star Pattern Detected";
        case EVENING_STAR:
            return "Evening Star Pattern Detected";
        case BULLISH_PIERCING:
            return "Bullish Piercing Pattern Detected";
        case BEARISH_DARK_CLOUD:
            return "Bearish Dark Cloud Pattern Detected";
        case BULLISH_KICKING:
            return "Bullish Kicking Pattern Detected";
        case BEARISH_KICKING:
            return "Bearish Kicking Pattern Detected";
        case BULLISH_INVERTED_HAMMER:
            return "Bullish Inverted Hammer Pattern Detected";
        case BEARISH_INVERTED_HAMMER:
            return "Bearish Inverted Hammer Pattern Detected";
        case BULLISH_HAMMER:
            return "Bullish Hammer Pattern Detected";
        case BEARISH_HANGING_MAN:
            return "Bearish Hanging Man Pattern Detected";
        // Add more pattern names here...
        default:
            return "No Pattern";
    }
}

string AnalyzeCandlestickPatterns(string _Symbol, ENUM_TIMEFRAMES PERIOD, string &_CandleAnalysis) {
    int limit = 100;
    double openPrices[], closePrices[], highPrices[], lowPrices[];
    ArraySetAsSeries(openPrices, true);
    ArraySetAsSeries(closePrices, true);
    ArraySetAsSeries(highPrices, true);
    ArraySetAsSeries(lowPrices, true);

    int copied = CopyOpen(_Symbol, PERIOD, 0, limit, openPrices);
    copied = CopyClose(_Symbol, PERIOD, 0, limit, closePrices);
    copied = CopyHigh(_Symbol, PERIOD, 0, limit, highPrices);
    copied = CopyLow(_Symbol, PERIOD, 0, limit, lowPrices);

    if (copied <= 0) {
        Print("Error fetching historical data.");
        return "error";
    }

    CandlePattern lastPattern = IdentifyCandlePattern(openPrices[limit - 1], closePrices[limit - 1], highPrices[limit - 1], lowPrices[limit - 1]);

    if (lastPattern == BULLISH_ENGULFING || lastPattern == BULLISH_HARAMI || lastPattern == BULLISH_MARUBOZU || lastPattern == MORNING_STAR ||
        lastPattern == BULLISH_PIERCING || lastPattern == BULLISH_KICKING || lastPattern == BULLISH_INVERTED_HAMMER || lastPattern == BULLISH_HAMMER) {
        _CandleAnalysis = GetPatternName(lastPattern);
        return "buy"; // Suggest a buy signal for certain bullish patterns
    } else if (lastPattern == BEARISH_ENGULFING || lastPattern == BEARISH_HARAMI || lastPattern == BEARISH_MARUBOZU || lastPattern == EVENING_STAR ||
               lastPattern == BEARISH_DARK_CLOUD || lastPattern == BEARISH_KICKING || lastPattern == BEARISH_INVERTED_HAMMER || lastPattern == BEARISH_HANGING_MAN) {
        _CandleAnalysis = GetPatternName(lastPattern);
        return "sell"; // Suggest a sell signal for certain bearish patterns
    } else if (lastPattern == DOJI) {
        return "uncertain"; // Signal uncertainty for Doji pattern
    } else {
        return "no signal"; // No recognizable pattern
    }
}
