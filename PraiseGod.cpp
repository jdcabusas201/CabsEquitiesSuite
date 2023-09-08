#include 
<Trade\Trade.mqh>

CTrade trade;  // Create an instance of the CTrade class
COrderInfo orderInfo;
// Inputs

input ENUM_TIMEFRAMES HigherTimeframe = PERIOD_H1;

input int MA_Period_Short = 50;

input int MA_Period_Medium = 100;

input int MA_Period_Long = 200;

input double LotSize = 0.01;

input double BalanceThreshold = 50;

input int PipAdj = 10;

int pips = PipAdj;

double threshold10Pips = 0;

double threshold20Pips = 0;

double threshold30Pips = 0;

double threshold40Pips = 0;

double threshold50Pips = 0;

double threshold60Pips = 0;

double threshold70Pips = 0;

double threshold80Pips = 0;

bool Adj1 = false;
bool Adj2 = false;
bool Adj3 = false;
bool Adj4 = false;
bool Adj5 = false;
bool Adj6 = false;
bool Adj7 = false;
bool Adj8 = false;

bool entry_made = false;

int repcount = 0;

 

// Function to check higher timeframe trend

void ClosePositionsIfProfitAbove(double profitThreshold)
{
    double overallProfit = AccountInfoDouble(ACCOUNT_PROFIT);
    CTrade trade;
    
    if (overallProfit > profitThreshold || ClosePositionsIfEquityBelowPercentOfBalance(BalanceThreshold))
    {
      for (int i = PositionsTotal(); i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket)) trade.PositionClose(ticket);
       
      }
      threshold10Pips = 0;
      threshold20Pips = 0;
      threshold30Pips = 0;
      threshold40Pips = 0;
      threshold50Pips = 0;
      threshold60Pips = 0;
      threshold70Pips = 0;
      threshold80Pips = 0;
      
      Adj1 = false;
      Adj2 = false;
      Adj3 = false;
      Adj4 = false;
      Adj5 = false;
      Adj6 = false;
      Adj7 = false;
      Adj8 = false;
      
      entry_made = false;
         
     pips = PipAdj;
}
}

bool ClosePositionsIfEquityBelowPercentOfBalance(double percentThreshold) {
  double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
  bool result = false;

  if ((accountEquity / accountBalance) * 100 < percentThreshold) {
    result = true;
  }

  return result;
}



int GetHigherTimeframeTrend()

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

}

bool IsBearishEveningStar()
{
    if (iClose(Symbol(), Period(), 2) > iOpen(Symbol(), Period(), 2) &&                  // Large bullish candle
        iClose(Symbol(), Period(), 1) > iOpen(Symbol(), Period(), 1) &&                  // Small-bodied candle (can be bullish or bearish)
        iClose(Symbol(), Period(), 1) > iClose(Symbol(), Period(), 2) &&                 // Second candle gaps up
        iClose(Symbol(), Period(), 0) < iOpen(Symbol(), Period(), 0) &&                  // Large bearish candle
        iClose(Symbol(), Period(), 0) < iClose(Symbol(), Period(), 2) + (iOpen(Symbol(), Period(), 2) - iClose(Symbol(), Period(), 2)) / 2)   // Third candle closes below midpoint of first candle
    {
        return true;    // Bearish Evening Star pattern is present
    }
    
    return false;       // Bearish Evening Star pattern is not present
}

bool IsBullishMorningStar()
{
    if (iClose(Symbol(), Period(), 2) < iOpen(Symbol(), Period(), 2) &&                  // Large bearish candle
        iClose(Symbol(), Period(), 1) < iOpen(Symbol(), Period(), 1) &&                  // Small-bodied candle (can be bullish or bearish)
        iClose(Symbol(), Period(), 1) < iClose(Symbol(), Period(), 2) &&                 // Second candle gaps down
        iClose(Symbol(), Period(), 0) > iOpen(Symbol(), Period(), 0) &&                  // Large bullish candle
        iClose(Symbol(), Period(), 0) > iClose(Symbol(), Period(), 2) + (iClose(Symbol(), Period(), 2) - iOpen(Symbol(), Period(), 2)) / 2)   // Third candle closes above midpoint of first candle
    {
        return true;    // Bullish Morning Star pattern is present
    }
    
    return false;       // Bullish Morning Star pattern is not present
}

bool IsBullishThreeInsideUp()
{
    if (iClose(Symbol(), Period(), 2) > iOpen(Symbol(), Period(), 2) &&                  // Bearish candle
        iClose(Symbol(), Period(), 1) < iOpen(Symbol(), Period(), 1) &&                  // Small-bodied candle (can be bullish or bearish)
        iClose(Symbol(), Period(), 1) > iClose(Symbol(), Period(), 2) &&                 // Second candle is engulfed by first candle
        iClose(Symbol(), Period(), 0) > iOpen(Symbol(), Period(), 0) &&                  // Bullish candle
        iClose(Symbol(), Period(), 0) > iHigh(Symbol(), Period(), 1))                    // Third candle closes above high of second candle
    {
        return true;    // Bullish Three Inside Up pattern is present
    }
    
    return false;       // Bullish Three Inside Up pattern is not present
}

bool IsBearishThreeInsideDown()
{
    if (iClose(Symbol(), Period(), 2) < iOpen(Symbol(), Period(), 2) &&                  // Bullish candle
        iClose(Symbol(), Period(), 1) > iOpen(Symbol(), Period(), 1) &&                  // Small-bodied candle (can be bullish or bearish)
        iClose(Symbol(), Period(), 1) < iClose(Symbol(), Period(), 2) &&                 // Second candle is engulfed by first candle
        iClose(Symbol(), Period(), 0) < iOpen(Symbol(), Period(), 0) &&                  // Bearish candle
        iClose(Symbol(), Period(), 0) < iLow(Symbol(), Period(), 1))                     // Third candle closes below low of second candle
    {
        return true;    // Bearish Three Inside Down pattern is present
    }
    
    return false;       // Bearish Three Inside Down pattern is not present
}


bool IsBullishThreeWhiteSoldiers()
{
    if (iClose(Symbol(), Period(), 2) < iOpen(Symbol(), Period(), 2) &&                  // Bearish candle
        iClose(Symbol(), Period(), 1) < iOpen(Symbol(), Period(), 1) &&                  // Bearish candle
        iClose(Symbol(), Period(), 0) > iOpen(Symbol(), Period(), 0) &&                  // Bullish candle
        iClose(Symbol(), Period(), 0) > iClose(Symbol(), Period(), 1) &&                 // Third candle closes above the second candle
        iClose(Symbol(), Period(), 1) > iClose(Symbol(), Period(), 2))                   // Second candle closes above the first candle
    {
        return true;    // Bullish Three White Soldiers pattern is present
    }
    
    return false;       // Bullish Three White Soldiers pattern is not present
}

bool IsBearishThreeBlackCrows()
{
    if (iClose(Symbol(), Period(), 2) > iOpen(Symbol(), Period(), 2) &&                  // Bullish candle
        iClose(Symbol(), Period(), 1) > iOpen(Symbol(), Period(), 1) &&                  // Bullish candle
        iClose(Symbol(), Period(), 0) < iOpen(Symbol(), Period(), 0) &&                  // Bearish candle
        iClose(Symbol(), Period(), 0) < iClose(Symbol(), Period(), 1) &&                 // Third candle closes below the second candle
        iClose(Symbol(), Period(), 1) < iClose(Symbol(), Period(), 2))                   // Second candle closes below the first candle
    {
        return true;    // Bearish Three Black Crows pattern is present
    }
    
    return false;       // Bearish Three Black Crows pattern is not present
}

void sendBuyOrder(bool initial)
{

        double cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      //if (order_type == ORDER_TYPE_SELL)
        //cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
        
        string magic = " ";
        if(initial)
         magic = "12";
        
        MqlTradeRequest request = {};
        request.action = TRADE_ACTION_DEAL;
        request.symbol = Symbol();
        request.volume = LotSize;
        request.type = ORDER_TYPE_BUY;
        request.price = cost;
        request.deviation = 2;
        request.comment = magic;
        request.type_filling = ORDER_FILLING_FOK;
        //request.tp = 1;
        MqlTradeResult result;

        // SEND ORDER ONLY IF WE ARE WITHIN SET HOURS
        datetime currentTime = TimeCurrent();
        MqlDateTime timeStruct;
        TimeToStruct(currentTime, timeStruct);
        int currentHour = timeStruct.hour;

        if (currentHour > 12 && currentHour < 20) {
          OrderSend(request, result);  // ORDER SEND
          //last_profit_level = cost;    // Update the last profit level
          if(entry_made == false){
            threshold10Pips = cost - (500 * _Point);
            threshold20Pips = cost - (1000 * _Point);
            threshold30Pips = cost - (1500 * _Point);
            }
        }
}

void sendSellOrder(bool initial)
{
      
        double size = LotSize;
        if(Adj1)
         size = 0.01;
        if(Adj2)
         size = 0.02;
        if(Adj3)
         size = 0.03;
        if(Adj4)
         size = 0.04;
        if(Adj5)
         size = 0.05;
        if(Adj6)
         size = 0.06;
        if(Adj7)
         size = 0.07;
        if(Adj8)
         size = 0.08;        
        
        double cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      //if (order_type == ORDER_TYPE_SELL)
        //cost = SymbolInfoDouble(Symbol(), SYMBOL_BID);
        
        string magic = " ";
        if(initial)
         magic = "12";
        
        MqlTradeRequest request = {};
        request.action = TRADE_ACTION_DEAL;
        request.symbol = Symbol();
        request.volume = size;
        request.type = ORDER_TYPE_SELL;
        request.price = cost;
        request.deviation = 2;
        request.comment = magic;
        request.type_filling = ORDER_FILLING_FOK;
        //request.tp = 1;
        MqlTradeResult result;

        // SEND ORDER ONLY IF WE ARE WITHIN SET HOURS
        datetime currentTime = TimeCurrent();
        MqlDateTime timeStruct;
        TimeToStruct(currentTime, timeStruct);
        int currentHour = timeStruct.hour;
      
        if (currentHour > 12 && currentHour < 20 && initial == true) {
          OrderSend(request, result);  // ORDER SEND
          //last_profit_level = cost;    // Update the last profit level
            int points = 500;
            threshold10Pips = cost + (points * _Point);
            threshold20Pips = cost + (points * 2 * _Point);
            threshold30Pips = cost + (points * 3 * _Point);
            threshold40Pips = cost + (points * 5 * _Point);
            threshold50Pips = cost + (points * 8 * _Point);
            threshold60Pips = cost + (points * 3 * _Point);
            threshold70Pips = cost + (points * 5 * _Point);
            threshold80Pips = cost + (points * 8 * _Point);
            entry_made = true;
            
            ObjectCreate(0,"My Line1",OBJ_HLINE,0,0,threshold10Pips);
            ObjectCreate(0,"My Line2",OBJ_HLINE,0,0,threshold20Pips);
            ObjectCreate(0,"My Line3",OBJ_HLINE,0,0,threshold30Pips);
            
        }else if(initial == false){
         OrderSend(request, result);
        }
}



void ClosePositionsIfOpenForFiveDays()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        
        if (PositionSelectByTicket(ticket))
        {
            datetime entryTime = PositionGetInteger(POSITION_TIME);
            datetime currentTime = TimeCurrent();
            int timeDifference = (int)(currentTime - entryTime) / 60 / 60 / 24;  // Calculate the time difference in days
            
            if (timeDifference >= 20)
            {
               trade.PositionClose(ticket);
            }
        }
    }
}



void OpenPositions()

{

    int magicNumber = 12;  // Specify the magic number for the positions

    double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

    double openPrice = 0.0;
    
    double target_price = 0;
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    //if(ordertype == POSITION_TYPE_SELL)
       //currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    
      if (currentPrice >= threshold10Pips && Adj1 == false)
    {

        // Open position at 10 pips

        // ...
      
        //if(ordertype == POSITION_TYPE_SELL)
      
        //else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);
         
        Adj1 = true; 
        sendSellOrder(false);

        

     }

 

    if (currentPrice >= threshold20Pips && Adj2 == false)

    {

        // Open position at 20 pips

        // ...
          Print("ADJ2");
        /*if(ordertype == POSITION_TYPE_SELL)
        sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false); */
        Adj2 = true;
        sendSellOrder(false);

    }

 

    if (currentPrice >= threshold30Pips && Adj3 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj3 = true;
        sendSellOrder(false);

    }
    
        if (currentPrice >= threshold40Pips && Adj4 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj4 = true;
        sendSellOrder(false);

    }
    
        if (currentPrice >= threshold50Pips && Adj5 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj5 = true;
        sendSellOrder(false);

    }
    
            if (currentPrice >= threshold50Pips && Adj6 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj6 = true;
        sendSellOrder(false);

    }
    
            if (currentPrice >= threshold50Pips && Adj7 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj7 = true;
        sendSellOrder(false);

    }
    
            if (currentPrice >= threshold50Pips && Adj8 == false)

    {

        // Open position at 30 pips

        // ...
         Print("ADJ3");
        /*if(ordertype == POSITION_TYPE_SELL)
         //sendSellOrder(false);
        else if(ordertype == POSITION_TYPE_BUY)
         //sendBuyOrder(false);*/
        Adj8 = true;
        sendSellOrder(false);

    }
    
   

   }
   
void countReps()
{
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

//OpenPositions();
   /*for (int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      
      if (PositionSelectByTicket(ticket)) {
        string magic = PositionGetString(POSITION_COMMENT);
        int order_type = PositionGetInteger(POSITION_TYPE);
        OpenPositions(order_type);

         }
      }*/
   ClosePositionsIfProfitAbove(20);
   //ClosePositionsIfOpenForFiveDays();
   
   if(entry_made){
   
      
      OpenPositions();
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

    int higherTimeframeTrend = GetHigherTimeframeTrend();
    //Print(higherTimeframeTrend);


    // Check for pattern formations

    bool isBearishEveningStar = IsBearishEveningStar();

    bool isBullishMorningStar = IsBullishMorningStar();

    bool isBullishThreeInsideUp = IsBullishThreeInsideUp();

    bool isBearishThreeInsideDown = IsBearishThreeInsideDown();

    bool isBullishThreeWhiteSoldiers = IsBullishThreeWhiteSoldiers();

    bool isBearishThreeBlackCrows = IsBearishThreeBlackCrows();

 

    // Trading logic based on pattern detection

    if (isBearishEveningStar && higherTimeframeTrend == -1 && PositionsTotal() < 1)

    {

        // Execute bearish evening star trading strategy

        // ...
        
        countReps();
        sendSellOrder(true);
        

    }

    else if (isBullishMorningStar && higherTimeframeTrend == 1 && PositionsTotal() < 1 || isBullishMorningStar)

    {

        // Execute bullish morning star trading strategy

        // ...
        
       //sendBuyOrder();
       Print("isBullishMorningStar");

    }

    else if (isBullishThreeInsideUp && higherTimeframeTrend == 1 && PositionsTotal() < 1)

    {

        // Execute bullish three inside up trading strategy

        // ...
        
        //Print("isBullishThreeInsideUp");
        
        //sendBuyOrder();

    }
    
    else if (isBearishThreeInsideDown && higherTimeframeTrend == -1 && PositionsTotal() < 1)

    {

        // Execute bullish three inside up trading strategy

        // ...
        
        //Print("isBullishThreeInsideUp");
        
        //sendBuyOrder();
        
    

    }
    
    else if (isBullishThreeWhiteSoldiers && higherTimeframeTrend == 1 && PositionsTotal() < 1)

    {

        // Execute bullish three inside up trading strategy

        // ...
        
        //Print("isBullishThreeInsideUp");
        
        //sendBuyOrder();

    }
    
    else if (isBearishThreeBlackCrows && higherTimeframeTrend == -1 && PositionsTotal() < 1)

    {

        // Execute bullish three inside up trading strategy

        // ...
        
        //Print("isBullishThreeInsideUp");
        
        //sendSellOrder(true);
        
        //countReps();
        //sendSellOrder(true);

    }

    // Continue with other pattern conditions and trading strategies

 

    // Rest of the OnTick logic

    // ...

}