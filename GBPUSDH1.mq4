//+------------------------------------------------------------------+
//                        DO NOT DELETE THIS HEADER
//             DELETING THIS HEADER IS COPYRIGHT INFRIGMENT 
//
//                   Copyright ©2011, ForexEAdvisor.com
//                 ForexEAdvisor Strategy Builder version 0.2
//                        http://www.ForexEAdvisor.com 
//
// THIS EA CODE HAS BEEN GENERATED USING FOREXEADVISOR STRATEGY BUILDER 0.2 
// on: 7/1/2016 5:17:27 PM
// Disclaimer: This EA is provided to you "AS-IS", and ForexEAdvisor disclaims any warranty
// or liability obligations to you of any kind. 
// UNDER NO CIRCUMSTANCES WILL FOREXEADVISOR BE LIABLE TO YOU, OR ANY OTHER PERSON OR ENTITY,
// FOR ANY LOSS OF USE, REVENUE OR PROFIT, LOST OR DAMAGED DATA, OR OTHER COMMERCIAL OR
// ECONOMIC LOSS OR FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, STATUTORY, PUNITIVE,
// EXEMPLARY OR CONSEQUENTIAL DAMAGES WHATSOEVER RELATED TO YOUR USE OF THIS EA OR 
// FOREXEADVISOR STRATEGY BUILDER     
// Because software is inherently complex and may not be completely free of errors, you are 
// advised to verify this EA. Before using this EA, please read the ForexEAdvisor Strategy Builder
// license for a complete understanding of ForexEAdvisor' disclaimers.  
// USE THIS EA AT YOUR OWN RISK. 
//  
// Before adding this expert advisor to a chart, make sure there are NO
// open positions.
//                      DO NOT DELETE THIS HEADER
//             DELETING THIS HEADER IS COPYRIGHT INFRIGMENT 
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Adrian Szajek  Copyright ©2011, ForexEAdvisor.com."
#property link      "https://www.mql5.com http://www.ForexEAdvisor.com "
#property version   "1.00"
#property strict
#property description   "The EA parameters are optimized for GBP/USD H1 ONLY !!!." 
//+------------------------------------------------------------------+


extern int              MagicNumber=1;
extern double           Lots =0.1;
extern double           StopLoss=0;
extern double           TakeProfit=50;
extern int              TrailingStop=50;
extern int              Slippage=3;  
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
int start()
{
  double MyPoint=Point;    
  if(Digits==3 || Digits==5) MyPoint=Point*10;
  
  double TheStopLoss=0;
  double TheTakeProfit=0;
  if( TotalOrdersCount()==0 ) 
  {
     int result=0;
     if((iMA("GBPUSD",PERIOD_H1,9,0,MODE_SMA,PRICE_CLOSE,0)>iMA("GBPUSD",PERIOD_H1,18,0,MODE_SMA,PRICE_CLOSE,0))&&(iCCI("GBPUSD",PERIOD_H1,14,PRICE_CLOSE,0)<-160)&&(iStochastic(NULL,0,5,3,3,MODE_SMA,1,MODE_MAIN,0)<16)) // Here is your open buy rule
     {
        result=OrderSend(Symbol(),OP_BUY,AdvancedMM(),Ask,Slippage,0,0,"EA Generator www.ForexEAdvisor.com",MagicNumber,0,Blue);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Ask+TakeProfit*MyPoint;
         if(StopLoss>0) TheStopLoss=Ask-StopLoss*MyPoint;
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
     if((iMA("GBPUSD",PERIOD_H1,9,0,MODE_SMA,PRICE_CLOSE,0)<iMA("GBPUSD",PERIOD_H1,18,0,MODE_SMA,PRICE_CLOSE,0))&&(iCCI("GBPUSD",PERIOD_H1,14,PRICE_CLOSE,0)>240)&&(iStochastic(NULL,PERIOD_H1,5,3,3,MODE_SMA,1,MODE_MAIN,0)>94)) // Here is your open Sell rule
     {
        result=OrderSend(Symbol(),OP_SELL,AdvancedMM(),Bid,Slippage,0,0,"EA Generator www.ForexEAdvisor.com",MagicNumber,0,Red);
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Bid-TakeProfit*MyPoint;
         if(StopLoss>0) TheStopLoss=Bid+StopLoss*MyPoint;
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
  }
  
  for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber 
         )  
        {
         if(OrderType()==OP_BUY)  
           {
           if (TimeCurrent()-OrderOpenTime()>14400) //here is your close buy rule
              {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
              }
            if(TrailingStop>0)  
              {                 
               if(Bid-OrderOpenPrice()>MyPoint*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-MyPoint*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*MyPoint,OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else 
           {
                if (TimeCurrent()-OrderOpenTime()>14400) // here is your close sell rule
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(MyPoint*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+MyPoint*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+MyPoint*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
   return(0);
}

int TotalOrdersCount()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}
double AdvancedMM()
{
 int i;
 double AdvancedMMLots = 0;
 bool profit1=false;
 int SystemHistoryOrders=0;
  for( i=0;i<OrdersHistoryTotal();i++)
  {  OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
     if (OrderMagicNumber()==MagicNumber) SystemHistoryOrders++;
  }
 bool profit2=false;
 int LO=0;
 if(SystemHistoryOrders<2) return(Lots);
 for( i=OrdersHistoryTotal()-1;i>=0;i--)
  {
     if(OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY))
     if (OrderMagicNumber()==MagicNumber) 
     {
        if(OrderProfit()>=0 && profit1) return(Lots);
        if( LO==0)
        {  if(OrderProfit()>=0) profit1=true;
           if(OrderProfit()<0)  return(OrderLots());
           LO=1;
        }
        if(OrderProfit()>=0 && profit2) return(AdvancedMMLots);
        if(OrderProfit()>=0) profit2=true;
        if(OrderProfit()<0 ) 
        {   profit1=false;
            profit2=false;
            AdvancedMMLots+=OrderLots();
        }
     }
  }
 return(AdvancedMMLots);
}
