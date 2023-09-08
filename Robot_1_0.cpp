#include <Trade\Trade.mqh>

CTrade trade;  // Create an instance of the CTrade class
COrderInfo orderInfo;

input double TakeProfit = 1.0;
input double LotSize = 0.01;
input double LotSizeAdjusted = 0.01;
input double StopLossAdj = 11;
input double StopLoss = -10000;
input double CutOff = 60;

double last_profit_level = 0;
double MA[];


//--- variable for storing the handle of indicators
int handle;


int OnInit() {
  int handle = iMA(Symbol(), PERIOD_CURRENT, 12, 6, MODE_SMA, PRICE_CLOSE);
  return (INIT_SUCCEEDED);
}

//RETURN THE MOVING AVERAGE VALUE
double get_ma()
{
   int handle = iMA(Symbol(), PERIOD_CURRENT, 50, 6, MODE_SMA, PRICE_CLOSE);
    if (CopyBuffer(handle, 0, 0, 100, MA) < 0) {
      Alert("Error copying MA indicator Buffers - error:", GetLastError(),
            "!!");
      return 0;
    }
   return MA[0];
}

bool ThreeBullishCandles()
{
    double close1 = iClose(_Symbol, PERIOD_M5, 1);
    double open1 = iOpen(_Symbol, PERIOD_M5, 1);
    double close2 = iClose(_Symbol, PERIOD_M5, 2);
    double open2 = iOpen(_Symbol, PERIOD_M5, 2);
    double close3 = iClose(_Symbol, PERIOD_M5, 3);
    double open3 = iOpen(_Symbol, PERIOD_M5, 3);

    if (close1 > open1 && close2 > open2 && close3 > open3)
    {
        return true;
    }
    else
    {
        return false;
    }
}

enum DojiType {
    Doji_None,
    Doji_Bullish,
    Doji_Bearish
};

DojiType GetDojiType(int index) {
    double openPrice = iOpen(_Symbol, _Period, index);
    double closePrice = iClose(_Symbol, _Period, index);
    double bodySize = MathAbs(openPrice - closePrice);
    double wickSize = iHigh(_Symbol, _Period, index) - MathMax(openPrice, closePrice);
    double tailSize = MathMin(openPrice, closePrice) - iLow(_Symbol, _Period, index);

    // Define the criteria for a doji candle with 1.5 times the wick size
    if (wickSize >= 1.5 * bodySize) {
        if (openPrice < closePrice && tailSize < bodySize * 0.1) {
            return Doji_Bullish; // Bullish Doji
        }
        else if (openPrice > closePrice && tailSize < bodySize * 0.1) {
            return Doji_Bearish; // Bearish Doji
        }
    }
    
    return Doji_None; // Not a doji
}

bool IsGravestoneDoji()
{
    double open = iOpen(_Symbol, PERIOD_CURRENT, 1);
    double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double low = iLow(_Symbol, PERIOD_CURRENT, 1);
    double close = iClose(_Symbol, PERIOD_CURRENT, 1);

    double body = MathAbs(close - open);
    double upper_shadow = high - MathMax(open, close);
    double lower_shadow = MathMin(open, close) - low;

    if (body < upper_shadow / 2 && body < lower_shadow / 2 && upper_shadow > lower_shadow)
    {
        // Check if the previous candle was a green candle with a large body and closing price lower than the doji's highest price
        double prev_close = iClose(_Symbol, PERIOD_CURRENT, 2);
        double prev_open = iOpen(_Symbol, PERIOD_CURRENT, 2);
        double prev_high = iHigh(_Symbol, PERIOD_CURRENT, 2);
        double prev_low = iLow(_Symbol, PERIOD_CURRENT, 2);

        bool is_prev_green_candle = prev_close > prev_open;
        bool is_prev_large_body_candle = MathAbs(prev_close - prev_open) > ((prev_high - prev_close) + (prev_close - prev_open)) * 0.90;
        bool is_prev_closing_price_lower_than_doji_highest_price = prev_close < high;

        if (is_prev_green_candle && is_prev_large_body_candle && is_prev_closing_price_lower_than_doji_highest_price)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}

bool IsDragonflyDoji()
{
    double open = iOpen(_Symbol, PERIOD_CURRENT, 1);
    double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double low = iLow(_Symbol, PERIOD_CURRENT, 1);
    double close = iClose(_Symbol, PERIOD_CURRENT, 1);

    double body = MathAbs(close - open);
    double upper_shadow = high - MathMax(open, close);
    double lower_shadow = MathMin(open, close) - low;

    if (body < upper_shadow / 2 && body < lower_shadow / 2 && lower_shadow > upper_shadow)
    {
        // Check if the previous candle was a red candle with a large body and closing price not higher than the doji's lowest price
        double prev_close = iClose(_Symbol, PERIOD_CURRENT, 2);
        double prev_open = iOpen(_Symbol, PERIOD_CURRENT, 2);
        double prev_high = iHigh(_Symbol, PERIOD_CURRENT, 2);
        double prev_low = iLow(_Symbol, PERIOD_CURRENT, 2);

        bool is_prev_red_candle = prev_close < prev_open;
        bool is_prev_large_body_candle = MathAbs(prev_close - prev_open) > ((prev_high - prev_open) + (prev_close - prev_low)) * 0.90;
        bool is_prev_closing_price_not_higher_than_doji_lowest_price = prev_close <= low;

        if (is_prev_red_candle && is_prev_large_body_candle && is_prev_closing_price_not_higher_than_doji_lowest_price)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}


void ClosePositionsOpenFor20MinsOrMore()
{
    for (int i = 0; i < PositionsTotal(); i++)
    {
        datetime entryTime = PositionGetInteger(POSITION_TIME);
        datetime currentTime = TimeCurrent();
        int timeDifference = (currentTime - entryTime) / 60;

        if (timeDifference < 10)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            double lotSize = PositionGetDouble(POSITION_VOLUME);
            double profit = PositionGetDouble(POSITION_PROFIT);

            if (lotSize == LotSize && PositionGetDouble(POSITION_PROFIT) < -3)
            {
                
                if (PositionSelectByTicket(ticket)) trade.PositionClose(ticket);
                Print("Position closed successfully: ", ticket);

            }
        }
    }
}

bool ClosePositionsIfEquityBelowPercentOfBalance(double percentThreshold)
{
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    bool result = false;

    if ((accountEquity / accountBalance) * 100 < percentThreshold)
    {
       result = true;
    }

    return result;
}


bool HasPositionMovedByPips(ulong ticket, double pips)
{
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double priceDifference = currentPrice - openPrice;
    bool result;
    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
    {
        priceDifference *= -1;
    }
    result = priceDifference >= (pips * _Point);
    return result;
}




//ON EACH TICK WE ARE EITHER CHECKING IF THERE ARE OPEN ORDERS. 
//IF THERE ARE NO CURENT POSITIONS ON THE PAIR THEN LOOK TO OPEN WITH DOJI
//IF THERE ARE OPEN POSITIONS THEN LOOKS TO ADJUST IF NEEDED
void OnTick() {
  // Check if there are any open positions
  if (PositionsTotal() < 1) {

    MqlTradeRequest request = {};
    MqlTradeResult result;
    ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;  // Set the initial order type to buy
    
    //GETTING PRICES TO CREATE ORDER
    double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    Print("HERE!!!!");
    int doji = GetDojiType(1);
    if(IsDragonflyDoji() || IsGravestoneDoji()){
      //Print("HERE!!!!");
      if(IsDragonflyDoji())
        order_type = ORDER_TYPE_BUY;
       else 
        order_type = ORDER_TYPE_SELL;
      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = LotSize;
      request.type = order_type;
      request.price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      if (order_type == ORDER_TYPE_SELL)
        request.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      request.deviation = 1;
      request.magic = 0;
      request.type_filling = ORDER_FILLING_FOK;

  
      //SEND ORDER ONLY IF WE ARE WITHIN SET HOURS                                     
      datetime currentTime = TimeCurrent();
      MqlDateTime timeStruct;
      TimeToStruct(currentTime, timeStruct);
      int currentHour = timeStruct.hour;
     
      //if(currentHour > 12 && currentHour < 20)
      OrderSend(request, result); //ORDER SEND
    }


  } else {
  //HERE WE ARE CHECKING IF WE ARE TO MAKE ADJUSTMENTS TO THE POSITION
    PositionSelect(Symbol());

    //CALCULATING OVERALL PROFIT
    double overallProfit = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket)) {
        double profit = PositionGetDouble(POSITION_PROFIT);
        overallProfit += profit;
      }
    }
      
    if (overallProfit > 0) {
      //Print("overallProfit: ", overallProfit);
    }
    
    double cut_off = CutOff;
    ClosePositionsOpenFor20MinsOrMore();
    //IF PROFIT FROM ALL POSITIONS IS ABOVE TP THEN LOOP THRU ALL AND CLOSE
    if (overallProfit > TakeProfit || ClosePositionsIfEquityBelowPercentOfBalance(cut_off)) {
      Print("TAKING PROFIT: ", overallProfit);
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket)) trade.PositionClose(ticket);
      }
    }
    
    //IF PRICE CAN LOSE ANOTHER $15 THEN ADD MORE TO POSITION. NEED TO MAKE THIS VALUE INTO AN INPUT
    if (overallProfit <= last_profit_level - StopLossAdj) {
      Print(overallProfit);

      ENUM_ORDER_TYPE order_type = ORDER_TYPE_BUY;  // Set the order type to buy
      if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        order_type = ORDER_TYPE_SELL;  // Set the order type to sell if the
                                       // existing position is a sell position

      double cost = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      if (order_type == ORDER_TYPE_SELL)
        cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);


      //ORDER CREATION AND SENDING
      double lots = LotSizeAdjusted;  // The number of lots to add

      MqlTradeRequest request = {};
      request.action = TRADE_ACTION_DEAL;
      request.symbol = Symbol();
      request.volume = lots;
      request.type = order_type;
      request.price = cost;
      request.deviation = 2;
      request.magic = 0;
      request.type_filling = ORDER_FILLING_FOK;
      //request.tp = take_profit;
      MqlTradeResult result;
      
      //SEND ORDER ONLY IF WE ARE WITHIN SET HOURS                                     
      datetime currentTime = TimeCurrent();
      MqlDateTime timeStruct;
      TimeToStruct(currentTime, timeStruct);
      int currentHour = timeStruct.hour;
     
      //if(currentHour > 12 && currentHour < 20)
      OrderSend(request, result); //ORDER SEND
      Print("POS TOTAL!!!!", PositionsTotal());

      //VARIABLE USED TO KEEP TRACKING OF CHECKS TO ADD TO POSITION
      last_profit_level = overallProfit;  // Update the last profit level
    }
  }
}

void OnDeinit(const int reason) {}
