#include
 //<Trade\Trade.mqh>

//CTrade trade;  // Create an instance of the CTrade class
//COrderInfo orderInfo;
// Inputs
input ENUM_TIMEFRAMES HigherTimeframe = PERIOD_H1;

input int MA_Period_Short = 50;

input int MA_Period_Medium = 100;

input int MA_Period_Long = 200;

input double LotSize = 0.01;

input double BalanceThreshold = 50;

input double takeProfit = 10;
input int points = 1000;
double tp = takeProfit;

input double size1 = 0.01;
input double size2 = 0.01;
input double size3 = 0.01;
input double size4 = 0.01;
input double size5 = 0.01;
input double size6 = 0.01;
input double size7 = 0.01;
input double size8 = 0.01;

double upper, middle, lower;

double Buythreshold10Pips = 0;

double Buythreshold20Pips = 0;

double Buythreshold30Pips = 0;

double Buythreshold40Pips = 0;

double Buythreshold50Pips = 0;

double Buythreshold60Pips = 0;

double Buythreshold70Pips = 0;

double Buythreshold80Pips = 0;

double Sellthreshold10Pips = 0;

double Sellthreshold20Pips = 0;

double Sellthreshold30Pips = 0;

double Sellthreshold40Pips = 0;

double Sellthreshold50Pips = 0;

double Sellthreshold60Pips = 0;

double Sellthreshold70Pips = 0;

double Sellthreshold80Pips = 0;

input bool BuyA1 = true;
input bool BuyA2 = true;
input bool BuyA3 = true;
input bool BuyA4 = true;
input bool BuyA5 = true;
input bool BuyA6 = true;
input bool BuyA7 = true;
input bool BuyA8 = true;

input bool SellA1 = true;
input bool SellA2 = true;
input bool SellA3 = true;
input bool SellA4 = true;
input bool SellA5 = true;
input bool SellA6 = true;
input bool SellA7 = true;
input bool SellA8 = true;

bool BAdj1 = false;
bool BAdj2 = false;
bool BAdj3 = false;
bool BAdj4 = false;
bool BAdj5 = false;
bool BAdj6 = false;
bool BAdj7 = false;
bool BAdj8 = false;

bool SAdj1 = false;
bool SAdj2 = false;
bool SAdj3 = false;
bool SAdj4 = false;;
bool SAdj5 = false;
bool SAdj6 = false;
bool SAdj7 = false;
bool SAdj8 = false;



bool sell_entry_made = false;
bool buy_entry_made = false;
bool draw_down = false;
double last_sell_bb_price = 0;
double last_buy_bb_price = 0;

int repcount = 0;

//BOLLINGER BANDS COPY AND PASTE FROM DOCS
// ACCESS BANDS VALUES THRU BUFFER ARRAY INDEX (buffer[0])

//--- indicator buffers
double UpperBuffer[100];
double LowerBuffer[100];
double MiddleBuffer[100];

double UpperBand, MiddleBand, LowerBand;
//datetime Time[];
//int handler;

enum Creation {
  Call_iBands, // use iBands
  Call_IndicatorCreate // use IndicatorCreate
};
//--- input parameters
input Creation type = Call_iBands; // type of the function 
input int bands_period = 20; // period of moving average
input int bands_shift = 0; // shift
input double deviation = 2.0; // number of standard deviations 
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE; // type of price
input string symbol = " "; // symbol 
input ENUM_TIMEFRAMES period = PERIOD_CURRENT; // timeframe

//--- variable for storing the handle of the iBands indicator
int handler;
//--- variable for storing
string name = symbol;
//--- name of the indicator on a chart
string short_name;
//--- we will keep the number of values in the Bollinger Bands indicator
int bars_calculated = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void OnInit() {
  //--- assignment of arrays to indicator buffers
  SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, LowerBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, MiddleBuffer, INDICATOR_DATA);
  //--- set shift of each line
  PlotIndexSetInteger(0, PLOT_SHIFT, bands_shift);
  PlotIndexSetInteger(1, PLOT_SHIFT, bands_shift);
  PlotIndexSetInteger(2, PLOT_SHIFT, bands_shift);
  //--- determine the symbol the indicator is drawn for
  name = symbol;
  //--- delete spaces to the right and to the left
  StringTrimRight(name);
  StringTrimLeft(name);
  //--- if it results in zero length of the 'name' string
  if (StringLen(name) == 0) {
    //--- take the symbol of the chart the indicator is attached to
    name = _Symbol;
  }
  //--- create handle of the indicator

  handler = iBands(NULL, 0, period, deviation, bands_shift, applied_price, MODE_SMA, 0);
  //UpperBand =  UpperBuffer[0];
  //MiddleBand =  MiddleBuffer[0];
  //LowerBand =  LowerBuffer[0];

}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
/*int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- number of values copied from the iBands indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=Bars(handler);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iBands indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the size of indicator buffers is greater than the number of values in the iBands indicator for symbol/period, then we don't copy everything 
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
      
     }
//--- fill the array with values of the Bollinger Bands indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffers(MiddleBuffer,UpperBuffer,LowerBuffer,bands_shift,handler,values_to_copy)) return(0);
//--- form the message
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            short_name,
                            values_to_copy);
   
    // Update the current values with the latest values from the indicator buffers
   // Update the current values with the latest values from the indicator buffers


//--- display the service message on the chart
   Comment(comm);
//--- memorize the number of values in the Bollinger Bands indicator
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iBands indicator              |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &base_values[],     // indicator buffer of the middle line of Bollinger Bands
                           double &upper_values[],    // indicator buffer of the upper border
                           double &lower_values[],    // indicator buffer of the lower border
                           int shift,                 // shift
                           int ind_handle,            // handle of the iBands indicator
                           int amount                 // number of copied values
                           )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the MiddleBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,base_values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
 
//--- fill a part of the UpperBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,1,-shift,amount,upper_values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
 
//--- fill a part of the LowerBuffer array with values from the indicator buffer that has index 2
   if(CopyBuffer(ind_handle,2,-shift,amount,lower_values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
      
   return(true);
  }*/
//END OF BB CODE

// Function to check higher timeframe trend

void ClosePositionsIfProfitAbove(double profitThreshold) {
  double overallProfit = AccountInfoDouble(ACCOUNT_PROFIT);
  int slippage = int(2.0 * (Ask - Bid) / _Point);

  if (overallProfit > profitThreshold || ClosePositionsIfEquityBelowPercentOfBalance(BalanceThreshold)) {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), slippage, 0)) {
          // Position closed successfully
        } else {
          // Failed to close position
          Print("Failed to close position: ", GetLastError());
        }
      } else {
        // Failed to select order
        Print("Failed to select order: ", GetLastError());
      }
    }

    Buythreshold10Pips = 0;
    Buythreshold20Pips = 0;
    Buythreshold30Pips = 0;
    Buythreshold40Pips = 0;
    Buythreshold50Pips = 0;
    Buythreshold60Pips = 0;
    Buythreshold70Pips = 0;
    Buythreshold80Pips = 0;

    Sellthreshold10Pips = 0;
    Sellthreshold20Pips = 0;
    Sellthreshold30Pips = 0;
    Sellthreshold40Pips = 0;
    Sellthreshold50Pips = 0;
    Sellthreshold60Pips = 0;
    Sellthreshold70Pips = 0;
    Sellthreshold80Pips = 0;

    BAdj1 = false;
    BAdj2 = false;
    BAdj3 = false;
    BAdj4 = false;

    SAdj1 = false;
    SAdj2 = false;
    SAdj3 = false;
    SAdj4 = false;

    sell_entry_made = false;
    buy_entry_made = false;
  }
}

void CloseBuyPositions(double profitThreshold) {
  double overallProfit = 0;
  int slippage = int(2.0 * (Ask - Bid) / _Point);

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderType() == OP_BUY && OrderSymbol() == _Symbol)
        overallProfit += OrderProfit();
    }
  }

  if (overallProfit > profitThreshold) {
    for (i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderType() == OP_BUY && OrderSymbol() == _Symbol) {
          if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), slippage, 0)) {
            // Position closed successfully
            buy_entry_made = false;

            Buythreshold10Pips = 0;
            Buythreshold20Pips = 0;
            Buythreshold30Pips = 0;
            Buythreshold40Pips = 0;
            Buythreshold50Pips = 0;
            Buythreshold60Pips = 0;
            Buythreshold70Pips = 0;
            Buythreshold80Pips = 0;

            BAdj1 = false;
            BAdj2 = false;
            BAdj3 = false;
            BAdj4 = false;
            BAdj5 = false;
            BAdj6 = false;
            BAdj7 = false;
            BAdj8 = false;
          } else {
            // Failed to close position
            Print("Failed to close position: ", GetLastError());
          }

        }
      }
    }
  }
}

void CloseSellPositions(double profitThreshold) {
  double overallProfit = 0;
  int slippage = int(2.0 * (Ask - Bid) / _Point);

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderType() == OP_SELL && OrderSymbol() == _Symbol)
        overallProfit += OrderProfit();
    }
  }

  if (overallProfit > profitThreshold) {
    for (i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderType() == OP_SELL && OrderSymbol() == _Symbol) {
          if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), slippage, 0)) {
            // Position closed successfully
            sell_entry_made = false;

            Sellthreshold10Pips = 0;
            Sellthreshold20Pips = 0;
            Sellthreshold30Pips = 0;
            Sellthreshold40Pips = 0;
            Sellthreshold50Pips = 0;
            Sellthreshold60Pips = 0;
            Sellthreshold70Pips = 0;
            Sellthreshold80Pips = 0;

            SAdj1 = false;
            SAdj2 = false;
            SAdj3 = false;
            SAdj4 = false;
            SAdj5 = false;
            SAdj6 = false;
            SAdj7 = false;
            SAdj8 = false;
          } else {
            // Failed to close position
            Print("Failed to close position: ", GetLastError());
          }

        }
      }
    }
  }
}

bool ClosePositionsIfEquityBelowPercentOfBalance(double percentThreshold) {
  double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
  bool result = false;

  if ((accountBalance - accountEquity) <percentThreshold) {
    result = true;
  }

  return result;
}

bool inDrawDown(double percentThreshold) {
  double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
  bool result = false;

  if ((accountEquity / accountBalance) * 100 < percentThreshold) {
    result = true;
  }

  return result;
}

/*int GetHigherTimeframeTrend()

{

    int higherTimeframeHandle = iTime(NULL, HigherTimeframe, 0);

    double higherTimeframeClose = iClose(NULL, HigherTimeframe, 0);

 

    double maShort = iMA(NULL, HigherTimeframe, MA_Period_Short, 0, MODE_SMA, PRICE_CLOSE);

    double maMedium = iMA(NULL, HigherTimeframe, MA_Period_Medium, 0, MODE_SMA, PRICE_CLOSE);

    double maLong = iMA(NULL, HigherTimeframe, MA_Period_Long, 0, MODE_SMA, PRICE_CLOSE);
     //int handle = iMA(Symbol(), PERIOD_CURRENT, 12, 6, MODE_SMA, PRICE_CLOSE);

 

    if (higherTimeframeClose > maShort && higherTimeframeClose > maMedium && higherTimeframeClose > maLong)

        return 1; // Uptrend

    else if (higherTimeframeClose < maShort && higherTimeframeClose < maMedium && higherTimeframeClose < maLong)

        return -1; // Downtrend

    else

        return 0; // Sideways

}*/

bool IsBearishEveningStar() {
    double candle1Close = iClose(Symbol(), Period(), 2);
    double candle1Open = iOpen(Symbol(), Period(), 2);
    double candle2Close = iClose(Symbol(), Period(), 1);
    double candle2Open = iOpen(Symbol(), Period(), 1);
    double candle3Close = iClose(Symbol(), Period(), 0);
    double candle3Open = iOpen(Symbol(), Period(), 0);

    double pointSize = _Point;

    if (candle1Close > candle1Open + (50 * pointSize) && // Large bullish candle
        candle2Close > candle2Open && // Small-bodied candle (can be bullish or bearish)
        candle2Close > candle1Close && // Second candle gaps up
        candle3Close < candle3Open - (50 * pointSize) && // Large bearish candle
        candle3Close < candle1Close + (candle1Open - candle1Close) / 2) // Third candle closes below midpoint of first candle
    {
        return true; // Bearish Evening Star pattern is present
    }

    return false; // Bearish Evening Star pattern is not present
}

bool IsBullishMorningStar() {
    double candle1Close = iClose(Symbol(), Period(), 2);
    double candle1Open = iOpen(Symbol(), Period(), 2);
    double candle2Close = iClose(Symbol(), Period(), 1);
    double candle2Open = iOpen(Symbol(), Period(), 1);
    double candle3Close = iClose(Symbol(), Period(), 0);
    double candle3Open = iOpen(Symbol(), Period(), 0);

    double pointSize = _Point;

    if (candle1Close < candle1Open && // Large bearish candle
        candle2Close < candle2Open && // Small-bodied candle (can be bullish or bearish)
        candle2Close < candle1Close && // Second candle gaps down
        candle3Close > candle3Open && // Large bullish candle
        candle3Close > candle1Close + (candle1Close - candle1Open) / 2) // Third candle closes above midpoint of first candle
    {
        return true; // Bullish Morning Star pattern is present
    }

    return false; // Bullish Morning Star pattern is not present
}

bool IsBullishThreeInsideUp() {
  if (iClose(Symbol(), Period(), 2) > iOpen(Symbol(), Period(), 2) && // Bearish candle
    iClose(Symbol(), Period(), 1) < iOpen(Symbol(), Period(), 1) && // Small-bodied candle (can be bullish or bearish)
    iClose(Symbol(), Period(), 1) > iClose(Symbol(), Period(), 2) && // Second candle is engulfed by first candle
    iClose(Symbol(), Period(), 0) > iOpen(Symbol(), Period(), 0) && // Bullish candle
    iClose(Symbol(), Period(), 0) > iHigh(Symbol(), Period(), 1)) // Third candle closes above high of second candle
  {
    return true; // Bullish Three Inside Up pattern is present
  }

  return false; // Bullish Three Inside Up pattern is not present
}

bool IsBearishThreeInsideDown() {
  if (iClose(Symbol(), Period(), 2) < iOpen(Symbol(), Period(), 2) && // Bullish candle
    iClose(Symbol(), Period(), 1) > iOpen(Symbol(), Period(), 1) && // Small-bodied candle (can be bullish or bearish)
    iClose(Symbol(), Period(), 1) < iClose(Symbol(), Period(), 2) && // Second candle is engulfed by first candle
    iClose(Symbol(), Period(), 0) < iOpen(Symbol(), Period(), 0) && // Bearish candle
    iClose(Symbol(), Period(), 0) < iLow(Symbol(), Period(), 1)) // Third candle closes below low of second candle
  {
    return true; // Bearish Three Inside Down pattern is present
  }

  return false; // Bearish Three Inside Down pattern is not present
}

bool IsBullishThreeWhiteSoldiers() {
  if (iClose(Symbol(), Period(), 2) < iOpen(Symbol(), Period(), 2) && // Bearish candle
    iClose(Symbol(), Period(), 1) < iOpen(Symbol(), Period(), 1) && // Bearish candle
    iClose(Symbol(), Period(), 0) > iOpen(Symbol(), Period(), 0) && // Bullish candle
    iClose(Symbol(), Period(), 0) > iClose(Symbol(), Period(), 1) && // Third candle closes above the second candle
    iClose(Symbol(), Period(), 1) > iClose(Symbol(), Period(), 2)) // Second candle closes above the first candle
  {
    return true; // Bullish Three White Soldiers pattern is present
  }

  return false; // Bullish Three White Soldiers pattern is not present
}

bool IsBearishThreeBlackCrows() {
  if (iClose(Symbol(), Period(), 2) > iOpen(Symbol(), Period(), 2) && // Bullish candle
    iClose(Symbol(), Period(), 1) > iOpen(Symbol(), Period(), 1) && // Bullish candle
    iClose(Symbol(), Period(), 0) < iOpen(Symbol(), Period(), 0) && // Bearish candle
    iClose(Symbol(), Period(), 0) < iClose(Symbol(), Period(), 1) && // Third candle closes below the second candle
    iClose(Symbol(), Period(), 1) < iClose(Symbol(), Period(), 2)) // Second candle closes below the first candle
  {
    return true; // Bearish Three Black Crows pattern is present
  }

  return false; // Bearish Three Black Crows pattern is not present
}

void sendBuyOrder(bool initial) {

  double size = LotSize;
  if (BAdj1)
    size = size1;
  if (BAdj2)
    size = size2;
  if (BAdj3)
    size = size3;
  if (BAdj4)
    size = size4;
  if(BAdj5)
   size = size5;
  if(BAdj6)
   size = size6;
  if(BAdj7)
   size = size7;
  if(BAdj8)
   size = size8;

  double cost = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
  //if (order_type == ORDER_TYPE_SELL)
  //cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);

  string magic = " ";
  if (initial)
    magic = "9";

  // SEND ORDER ONLY IF WE ARE WITHIN SET HOURS
  datetime currentTime = TimeCurrent();
  MqlDateTime timeStruct;
  TimeToStruct(currentTime, timeStruct);
  int currentHour = timeStruct.hour;
  int slippage = int(2.0 * (Ask - Bid) / _Point);

  if (currentHour > 0 && currentHour < 24 && initial == true) {
    OrderSend(Symbol(), OP_BUY, size, cost, slippage, 0, 0, magic, 0, 0, clrNONE); // ORDER SEND
    //last_profit_level = cost;    // Update the last profit level

    Buythreshold10Pips = cost - (points * _Point);
    Buythreshold20Pips = cost - (points * 2 * _Point);
    Buythreshold30Pips = cost - (points * 3 * _Point);
    Buythreshold40Pips = cost - (points * 4 * _Point);
    Buythreshold50Pips = cost - (points * 5 * _Point);
    Buythreshold60Pips = cost - (points * 6 * _Point);
    Buythreshold70Pips = cost - (points * 7 * _Point);
    Buythreshold80Pips = cost - (points * 8 * _Point);
    buy_entry_made = true;
    last_buy_bb_price = cost;

    ObjectCreate(0, "My Line1", OBJ_HLINE, 0, 0, Buythreshold10Pips);
    ObjectCreate(0, "My Line2", OBJ_HLINE, 0, 0, Buythreshold20Pips);
    ObjectCreate(0, "My Line3", OBJ_HLINE, 0, 0, Buythreshold30Pips);
    ObjectCreate(0, "My Line3", OBJ_HLINE, 0, 0, Buythreshold40Pips);

  } else if (initial == false) {
    OrderSend(Symbol(), OP_BUY, size, cost, slippage, 0, 0, magic, 0, 0, clrNONE);
  }
}

void sendSellOrder(bool initial) {

  double size = LotSize;
  if (SAdj1)
    size = size1;
  if (SAdj2)
    size = size2;
  if (SAdj3)
    size = size3;
  if (SAdj4)
    size = size4;
  if(SAdj5)
   size = size5;
  if(SAdj6)
   size =size6;
  if(SAdj7)
   size = size7;
  if(SAdj8)
   size = size8;

  double cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  //if (order_type == ORDER_TYPE_SELL)
  //cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);

  string magic = " ";
  if (initial)
    magic = "12";

  // SEND ORDER ONLY IF WE ARE WITHIN SET HOURS
  datetime currentTime = TimeCurrent();
  MqlDateTime timeStruct;
  TimeToStruct(currentTime, timeStruct);
  int currentHour = timeStruct.hour;
  int slippage = int(2.0 * (Ask - Bid) / _Point);
  if (currentHour > 0 && currentHour < 24 && initial == true) {
    OrderSend(Symbol(), OP_SELL, size, cost, slippage, 0, 0, magic, 0, 0, clrNONE); // ORDER SEND
    //last_profit_level = cost;    // Update the last profit level

    Sellthreshold10Pips = cost + (points * _Point);
    Sellthreshold20Pips = cost + (points * 2 * _Point);
    Sellthreshold30Pips = cost + (points * 3 * _Point);
    Sellthreshold40Pips = cost + (points * 4 * _Point);
    Sellthreshold50Pips = cost + (points * 5 * _Point);
    Sellthreshold60Pips = cost + (points * 6 * _Point);
    Sellthreshold70Pips = cost + (points * 7 * _Point);
    Sellthreshold80Pips = cost + (points * 8 * _Point);
    sell_entry_made = true;
    last_sell_bb_price = cost;

    ObjectCreate(0, "My Line1", OBJ_HLINE, 0, 0, Sellthreshold10Pips);
    ObjectCreate(0, "My Line2", OBJ_HLINE, 0, 0, Sellthreshold20Pips);
    ObjectCreate(0, "My Line3", OBJ_HLINE, 0, 0, Sellthreshold30Pips);
    ObjectCreate(0, "My Line3", OBJ_HLINE, 0, 0, Sellthreshold40Pips);

  } else if (initial == false) {
    OrderSend(Symbol(), OP_SELL, size, cost, slippage, 0, 0, magic, 0, 0, clrNONE);
  }
}

void ClosePositionsIfOpenForFiveDays() {

  double overallProfit = 0;
  int slippage = int(2.0 * (Ask - Bid) / _Point);

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol() == _Symbol) {
        datetime entryTime = OrderOpenTime();
        //Print("entryTime", entryTime);

        datetime currentTime = TimeCurrent();
        //Print("currentTime", currentTime);

        int timeDifference = (int)(currentTime - entryTime); // Calculate the time difference in seconds
        timeDifference = timeDifference / 86400;
        //Print("timeDifference", timeDifference);

        if ((timeDifference >= 2 /*&& ClosePositionsIfEquityBelowPercentOfBalance(51)*/)) {
          Print("CLOSE");
          for (i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
              if (OrderSymbol() == _Symbol) {
                if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), slippage, 0)) {
                  // Position closed successfully
                  sell_entry_made = false;
                  buy_entry_made = false;

                  Sellthreshold10Pips = 0;
                  Sellthreshold20Pips = 0;
                  Sellthreshold30Pips = 0;
                  Sellthreshold40Pips = 0;
                  Sellthreshold50Pips = 0;
                  Sellthreshold60Pips = 0;
                  Sellthreshold70Pips = 0;
                  Sellthreshold80Pips = 0;

                  Buythreshold10Pips = 0;
                  Buythreshold20Pips = 0;
                  Buythreshold30Pips = 0;
                  Buythreshold40Pips = 0;
                  Buythreshold50Pips = 0;
                  Buythreshold60Pips = 0;
                  Buythreshold70Pips = 0;
                  Buythreshold80Pips = 0;

                  SAdj1 = false;
                  SAdj2 = false;
                  SAdj3 = false;
                  SAdj4 = false;
                  SAdj5 = false;
                  SAdj6 = false;
                  SAdj7 = false;
                  SAdj8 = false;
                  BAdj1 = false;
                  BAdj2 = false;
                  BAdj3 = false;
                  BAdj4 = false;
                  BAdj5 = false;
                  BAdj6 = false;
                  BAdj7 = false;
                  BAdj8 = false;
                }
              }
            }
          }
        } else {
          // Failed to close position
          //Print("Failed to close position: ", GetLastError());
        }

      }
    }
  }
}


void AdjSellPositions()

{

  int magicNumber = 12; // Specify the magic number for the positions

  double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

  double openPrice = 0.0;

  double target_price = 0;

  double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  //if(ordertype == POSITION_TYPE_SELL)
  //currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if (currentPrice >= Sellthreshold10Pips && SAdj1 == false && currentPrice > upper && currentPrice > last_sell_bb_price && SellA1) {

    // Open position at 10 pips

    // ...

    //if(ordertype == POSITION_TYPE_SELL)

    //else if(ordertype == POSITION_TYPE_BUY)
    //sendBuyOrder(false);
    Print("SADJ2");
    SAdj1 = true;
    sendSellOrder(false);
    last_sell_bb_price = currentPrice;

  }

  if (currentPrice >= Sellthreshold20Pips && SAdj2 == false && currentPrice > upper && currentPrice > last_sell_bb_price && SellA2)

  {

    // Open position at 20 pips

    // ...
    Print("SADJ2");
    /*if(ordertype == POSITION_TYPE_SELL)
    sendSellOrder(false);
    else if(ordertype == POSITION_TYPE_BUY)
     //sendBuyOrder(false); */
    SAdj2 = true;
    sendSellOrder(false);
    last_sell_bb_price = currentPrice;

  }

  if (currentPrice >= Sellthreshold30Pips && SAdj3 == false && currentPrice > upper && currentPrice > last_sell_bb_price && SellA3)

  {

    // Open position at 30 pips

    // ...
    Print("SADJ3");
    /*if(ordertype == POSITION_TYPE_SELL)
     //sendSellOrder(false);
    else if(ordertype == POSITION_TYPE_BUY)
     //sendBuyOrder(false);*/
    SAdj3 = true;
    sendSellOrder(false);
    last_sell_bb_price = currentPrice;

  }

  if (currentPrice >= Sellthreshold40Pips && SAdj4 == false && currentPrice > UpperBuffer[0] && currentPrice > last_sell_bb_price && SellA4)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ4");
      
        SAdj4 = true;
        sendSellOrder(false);
        last_sell_bb_price = currentPrice;

    }
    
        if (currentPrice >= Sellthreshold50Pips && SAdj5 == false && currentPrice > UpperBuffer[0] && currentPrice > last_sell_bb_price && SellA5)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ5");
   
        SAdj5 = true;
        sendSellOrder(false);

    }
    
            if (currentPrice >= Sellthreshold60Pips && SAdj6 == false && currentPrice > UpperBuffer[0] && currentPrice > last_sell_bb_price && SellA6)

    {

        Print("ADJ6");
      
        SAdj6 = true;
        sendSellOrder(false);
        last_sell_bb_price = currentPrice;

    }
    
            if (currentPrice >= Sellthreshold70Pips && SAdj7 == false && currentPrice > UpperBuffer[0] && currentPrice > last_sell_bb_price && SellA7)

    {

        Print("ADJ7");
      
        SAdj7 = true;
        sendSellOrder(false);
        last_sell_bb_price = currentPrice;

    }
    
            if (currentPrice >= Sellthreshold80Pips && SAdj8 == false && currentPrice > UpperBuffer[0] && currentPrice > last_sell_bb_price && SellA8)

    {

        Print("ADJ8");
      
        SAdj8 = true;
        sendSellOrder(false);
        last_sell_bb_price = currentPrice;

    }

}

void AdjBuyPositions()

{

  int magicNumber = 7; // Specify the magic number for the positions

  double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

  double openPrice = 0.0;

  double target_price = 0;

  double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  //if(ordertype == POSITION_TYPE_SELL)
  //currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if (currentPrice <= Buythreshold10Pips && BAdj1 == false && currentPrice < lower && currentPrice < last_buy_bb_price && BuyA1) {

    // Open position at 10 pips

    // ...

    //if(ordertype == POSITION_TYPE_SELL)

    //else if(ordertype == POSITION_TYPE_BUY)
    //sendBuyOrder(false);
    Print("BADJ1");
    BAdj1 = true;
    sendBuyOrder(false);
    last_buy_bb_price = currentPrice;

  }

  if (currentPrice <= Buythreshold20Pips && BAdj2 == false && currentPrice < lower && currentPrice < last_buy_bb_price && BuyA2)

  {

    // Open position at 20 pips

    // ...
    Print("BADJ2");
    /*if(ordertype == POSITION_TYPE_SELL)
    sendSellOrder(false);
    else if(ordertype == POSITION_TYPE_BUY)
     //sendBuyOrder(false); */
    BAdj2 = true;
    sendBuyOrder(false);
    last_buy_bb_price = currentPrice;

  }

  if (currentPrice <= Buythreshold30Pips && BAdj3 == false && currentPrice < lower && currentPrice < last_buy_bb_price && BuyA3)

  {

    // Open position at 30 pips

    // ...
    Print("BADJ3");;
    /*if(ordertype == POSITION_TYPE_SELL)
     //sendSellOrder(false);
    else if(ordertype == POSITION_TYPE_BUY)
     //sendBuyOrder(false);*/
    BAdj3 = true;
    sendBuyOrder(false);
    last_buy_bb_price = currentPrice;

  }

  if (currentPrice <= Buythreshold40Pips && BAdj4 == false && currentPrice < LowerBuffer[0] && currentPrice < last_buy_bb_price && BuyA4)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ4");
      
        BAdj4 = true;
        sendBuyOrder(false);
        last_buy_bb_price = currentPrice;

    }
    
        if (currentPrice <= Buythreshold50Pips && BAdj5 == false && currentPrice < LowerBuffer[0] && currentPrice < last_buy_bb_price && BuyA5)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ5");
      
        BAdj5 = true;
        sendBuyOrder(false);
        last_buy_bb_price = currentPrice;

    }
    
            if (currentPrice <= Buythreshold60Pips && BAdj6 == false && currentPrice < LowerBuffer[0] && currentPrice < last_buy_bb_price && BuyA6)

    {

        // Open position at 30 pips

        // ...
        Print("ADJ6");
      
        BAdj6 = true;
        sendBuyOrder(false);
        last_buy_bb_price = currentPrice;

    }
    
            if (currentPrice <= Buythreshold70Pips && BAdj7 == false && currentPrice < LowerBuffer[0] && currentPrice < last_buy_bb_price && BuyA7)

    {

        Print("ADJ7");
      
        BAdj7 = true;
        sendBuyOrder(false);
        last_buy_bb_price = currentPrice;

    }
    
            if (currentPrice <= Buythreshold80Pips && BAdj8 == false && currentPrice < LowerBuffer[0] && currentPrice < last_buy_bb_price && BuyA8)

    {

        Print("ADJ8");
      
        BAdj8 = true;
        sendBuyOrder(false);
        last_buy_bb_price = currentPrice;;

    }

}

void countReps() {
  // Calculate the arrow coordinates
  double arrowX = TimeCurrent();
  double arrowY = SymbolInfoDouble(Symbol(), SYMBOL_BID);

  // Delete the previous arrow object, if it exists
  ObjectsDeleteAll(0, "CurrentPriceArrow");

  // Draw the arrow
  ObjectCreate(0, "CurrentPriceArrow", OBJ_ARROW, 0, arrowX, arrowY);
  ObjectSetInteger(0, "CurrentPriceArrow", OBJPROP_ARROWCODE, 233);
  ObjectSetInteger(0, "CurrentPriceArrow", OBJPROP_COLOR, clrGreen);
  ObjectSetInteger(0, "CurrentPriceArrow", OBJPROP_WIDTH, 1);
  ObjectSetInteger(0, "CurrentPriceArrow", OBJPROP_BACK, false);

  repcount++;
  Print("repcount: ", repcount);
}

void OnTick()

{


  double cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  // Calculate the Bollinger Bands
  int period = 20;
  double deviation = 2.0;
  int applied_price = PRICE_CLOSE;

  // Retrieve the most recent values

  upper = iBands(NULL, 0, period, deviation, 0, applied_price, MODE_UPPER, 0);
  middle = iBands(NULL, 0, period, deviation, 0, applied_price, MODE_MAIN, 0);
  lower = iBands(NULL, 0, period, deviation, 0, applied_price, MODE_LOWER, 0);

  // Print the indicator values
  //Print("Upper Band: ", upper);
  //Print("Middle Band: ", middle);
  //Print("Lower Band: ", lower);
  //Print("iClose(_Symbol, PERIOD_CURRENT,0): ", iClose(_Symbol, PERIOD_CURRENT,0));

  if (SAdj8 || BAdj8) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj7 && !SAdj8) || (BAdj7 && !BAdj8)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj6 && !SAdj7) || (BAdj6 && !BAdj7)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj5 && !SAdj6) || (BAdj5 && !BAdj6)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj4 && !SAdj5) || (BAdj4 && !BAdj5)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj3 && !SAdj4) || (BAdj3 && !BAdj4)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj2 && !SAdj3) || (BAdj2 && !BAdj3)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else if ((SAdj1 && !SAdj2) || (BAdj1 && !BAdj2)) {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  } else {
    CloseBuyPositions(tp);
    CloseSellPositions(tp);
  }


  //ClosePositionsIfOpenForFiveDays();
  //ClosePositionsIfOpenForFiveDays();
  //CloseBuyPositions();
  
  bool isBearishEveningStar = IsBearishEveningStar();

  bool isBullishMorningStar = IsBullishMorningStar();

  if (((iClose(_Symbol, PERIOD_CURRENT, 0) >= upper) && (upper - middle) > 50 * _Point && (upper - middle) < 100 * _Point && sell_entry_made == false)) {
    //Print("Sell");
    sendSellOrder(true);
  } else if (((iClose(_Symbol, PERIOD_CURRENT, 0) <= lower) && (middle - lower) > 50 * _Point && (middle - lower) < 100 * _Point && buy_entry_made == false)) {
    //Print("BUY");
    sendBuyOrder(true);
  }


  if (sell_entry_made) {
    AdjSellPositions();
  }
  if (buy_entry_made) {
    AdjBuyPositions();
  }

  /*Print("1: ", threshold10Pips);
  Print("2: ", threshold20Pips);
  Print("3: ", threshold30Pips);
  Print("entry_made: ", entry_made);
  Print("Adj1 Hit: ", Adj1);
  Print("Adj2 Hit: ", Adj2);
  Print("Adj3 Hit: ", Adj3);
  Print("AccountInfoDouble(ACCOUNT_PROFIT): ", AccountInfoDouble(ACCOUNT_PROFIT));  */
  //Print(SymbolInfoDouble(Symbol(), SYMBOL_ASK) > threshold10Pips);
  //Print(SymbolInfoDouble(Symbol(), SYMBOL_ASK));
  //ClosePositionsIfEquityBelowPercentOfBalance(60);

  // Check the higher timeframe trend

  //int higherTimeframeTrend = GetHigherTimeframeTrend();
  //Print(higherTimeframeTrend);

  // Check for pattern formations

 

  bool isBullishThreeInsideUp = IsBullishThreeInsideUp();

  bool isBearishThreeInsideDown = IsBearishThreeInsideDown();

  bool isBullishThreeWhiteSoldiers = IsBullishThreeWhiteSoldiers();

  bool isBearishThreeBlackCrows = IsBearishThreeBlackCrows();

  // Trading logic based on pattern detection

  /*if (isBearishEveningStar && higherTimeframeTrend == -1 && OrdersTotal() < 1)

  {

      // Execute bearish evening star trading strategy

      // ...
      
      //countReps();
      //sendSellOrder(true);
      

  }

  else if (isBullishMorningStar && higherTimeframeTrend == 1 && OrdersTotal() < 1 || isBullishMorningStar)

  {

      // Execute bullish morning star trading strategy

      // ...
      
    
     //sendBuyOrder();
     //Print("isBullishMorningStar");

  }

  else if (isBullishThreeInsideUp && higherTimeframeTrend == 1 && OrdersTotal() < 1)

  {

      // Execute bullish three inside up trading strategy

      // ...
    
      //Print("isBullishThreeInsideUp");
      
      //sendBuyOrder();

  }
  
  else if (isBearishThreeInsideDown && higherTimeframeTrend == -1 && OrdersTotal() < 1)

  {

      // Execute bullish three inside up trading strategy

      // ...
      
      //Print("isBullishThreeInsideUp");
      
      //sendBuyOrder();
      
  

  }
  
  else if (isBullishThreeWhiteSoldiers && higherTimeframeTrend == 1 && OrdersTotal() < 1)

  {

      // Execute bullish three inside up trading strategy

      // ...
      
      //Print("isBullishThreeInsideUp");
      
      //sendBuyOrder();

  }
  
  else if (isBearishThreeBlackCrows && higherTimeframeTrend == -1 && OrdersTotal() < 1)

  {

      // Execute bullish three inside up trading strategy

      // ...
      
      //Print("isBullishThreeInsideUp");
      
      //sendSellOrder(true);
      
      //countReps();
      //sendSellOrder(true);

  }*/

  // Continue with other pattern conditions and trading strategies

  // Rest of the OnTick logic

  // ...

}