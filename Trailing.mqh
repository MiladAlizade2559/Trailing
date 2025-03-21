//+------------------------------------------------------------------+
//|                                                     Trailing.mqh |
//|                                   Copyright 2025, Milad Alizade. |
//|                   https://www.mql5.com/en/users/MiladAlizade2559 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Milad Alizade."
#property link      "https://www.mql5.com/en/users/MiladAlizade2559"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Base/CBase.mqh>
#include <../Defines.mqh>
//+------------------------------------------------------------------+
//| Class CTrailing                                                  |
//| Usage: SL and TP control the signal                              |
//+------------------------------------------------------------------+
class CTrailing : public CBase
   {
private:
    int              m_sl;                         // sl value points
    int              m_tp;                         // tp value points
    datetime         m_time;                       // time
    double           m_bid;                        // bid price
    double           m_last_bid;                   // last bid price
protected:
    STrailingSetting m_inactive_settings[];        // settings array inactive
    STrailingSetting m_active_settings[];          // settings array active
    STrailingSetting m_history_settings[];         // settings array history
    int              m_inactive_settings_total;    // settings total inactive
    int              m_active_settings_total;      // settings total active
    int              m_history_settings_total;     // settings total history
private:
    //--- Functions for controlling work with trail setting
    int              Move(STrailingSetting &dst_settings[],STrailingSetting &src_settings[],const int dst_start);
    bool             InActiveCheck(const int index);
    bool             ActiveCheck(const int index);
    bool             UpdateSLTP(const int active_index);
public:
                     CTrailing(void);
                    ~CTrailing(void);
    //--- Functions for controlling data variables
    virtual int      Variables(const ENUM_VARIABLES_FLAGS flag,string &array[],const bool compact_objs = false);
    int              InActiveCreate(const double start_price,const double stop_price,const int trail_point,const int sl_point,const int tp_point);
    int              ActiveCreate(const double start_price,const double stop_price,const int trail_point,const int sl_point,const int tp_point);
    bool             InActiveDelete(const int index);
    bool             ActiveDelete(const int index);
    int              InActives(STrailingSetting &array[]);
    int              Actives(STrailingSetting &array[]);
    int              History(STrailingSetting &array[]);
    //--- Functions for controlling work with trail settings
    bool             Trailing(const double bid,const double last_bid);
    double           SL(void) {return(m_sl * Point());} // get sl value for trailing signal
    double           TP(void) {return(m_tp * Point());} // get tp value for trailing signal
    void             SLReset(void) {m_sl = 0;}          // reset sl value for next trailing signal
    void             TPReset(void) {m_tp = 0;}          // reset tp value for next trailing signal
   };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrailing::CTrailing(void)
   {
    m_inactive_settings_total = 0;
    m_active_settings_total = 0;
    m_history_settings_total = 0;
   }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrailing::~CTrailing(void)
   {
   }
//+------------------------------------------------------------------+
//| Setting variables                                                |
//+------------------------------------------------------------------+
int CTrailing::Variables(const ENUM_VARIABLES_FLAGS flag,string &array[],const bool compact_objs = false)
   {
    CBase::Variables(flag,array,compact_objs);
    _struct_array(m_inactive_settings);
    _struct_array(m_active_settings);
    _struct_array(m_history_settings);
    _int(m_inactive_settings_total);
    _int(m_active_settings_total);
    _int(m_history_settings_total);
    return(CBase::Variables(array));
   }
//+------------------------------------------------------------------+
//| Create trail setting in inactive settings array                  |
//+------------------------------------------------------------------+
int CTrailing::InActiveCreate(const double start_price,const double stop_price,const int trail_point,const int sl_point,const int tp_point)
   {
//--- resize array
    ArrayResize(m_inactive_settings,m_inactive_settings_total + 1);
//--- set values to array
    m_inactive_settings[m_inactive_settings_total].Set_Time = m_time;
    m_inactive_settings[m_inactive_settings_total].Start_Time = 0;
    m_inactive_settings[m_inactive_settings_total].Stop_Time = 0;
    m_inactive_settings[m_inactive_settings_total].Start_Price = start_price;
    m_inactive_settings[m_inactive_settings_total].Stop_Price = stop_price;
    m_inactive_settings[m_inactive_settings_total].Trail_Point = trail_point;
    m_inactive_settings[m_inactive_settings_total].SL_Point = sl_point;
    m_inactive_settings[m_inactive_settings_total].TP_Point = tp_point;
    m_inactive_settings[m_inactive_settings_total].Distance_Point = 0;
    m_inactive_settings_total++;
    return(m_inactive_settings_total - 1);
   }
//+------------------------------------------------------------------+
//| Create trail setting in active settings array                    |
//+------------------------------------------------------------------+
int CTrailing::ActiveCreate(const double start_price,const double stop_price,const int trail_point,const int sl_point,const int tp_point)
   {
//--- resize array
    ArrayResize(m_active_settings,m_active_settings_total + 1);
//--- set values to array
    m_active_settings[m_active_settings_total].Set_Time = m_time;
    m_active_settings[m_active_settings_total].Start_Time = m_time;
    m_active_settings[m_active_settings_total].Start_Price = start_price;
    m_active_settings[m_active_settings_total].Stop_Price = stop_price;
    m_active_settings[m_active_settings_total].Trail_Point = trail_point;
    m_active_settings[m_active_settings_total].SL_Point = sl_point;
    m_active_settings[m_active_settings_total].TP_Point = tp_point;
    m_active_settings[m_active_settings_total].Distance_Point = (int)((stop_price - m_bid) / Point());
    m_active_settings_total++;
    return(m_active_settings_total - 1);
   }
//+------------------------------------------------------------------+
//| Delete trail setting in inactive settings array                  |
//+------------------------------------------------------------------+
bool CTrailing::InActiveDelete(const int index)
   {
//--- check index
    if(index >= m_inactive_settings_total)
        return(false);
//--- moving setting to history
    if(Move(m_history_settings,m_inactive_settings,index) < 0)
        return(false);
    return(true);
   }
//+------------------------------------------------------------------+
//| Delete trail setting in active settings array                    |
//+------------------------------------------------------------------+
bool CTrailing::ActiveDelete(const int index)
   {
//--- check index
    if(index >= m_active_settings_total)
        return(false);
//--- moving setting to history
    int i = Move(m_history_settings,m_active_settings,index);
//--- check i
    if(i < 0)
        return(false);
//--- update stop time
    m_history_settings[i].Stop_Time = TimeTradeServer();
    return(true);
   }
//+------------------------------------------------------------------+
//| Get inacteve settings array                                      |
//+------------------------------------------------------------------+
int CTrailing::InActives(STrailingSetting &array[])
   {
//--- resize array
    ArrayResize(array,m_inactive_settings_total);
//--- set values to array
    for(int i = 0; i < m_inactive_settings_total; i++)
       {
        array[i] = m_inactive_settings[i];
       }
    return(m_inactive_settings_total);
   }
//+------------------------------------------------------------------+
//| Get acteve settings array                                        |
//+------------------------------------------------------------------+
int CTrailing::Actives(STrailingSetting &array[])
   {
//--- resize array
    ArrayResize(array,m_active_settings_total);
//--- set values to array
    for(int i = 0; i < m_active_settings_total; i++)
       {
        array[i] = m_active_settings[i];
       }
    return(m_active_settings_total);
   }
//+------------------------------------------------------------------+
//| Get history settings array                                       |
//+------------------------------------------------------------------+
int CTrailing::History(STrailingSetting &array[])
   {
//--- resize array
    ArrayResize(array,m_history_settings_total);
//--- set values to array
    for(int i = 0; i < m_history_settings_total; i++)
       {
        array[i] = m_history_settings[i];
       }
    return(m_history_settings_total);
   }
//+------------------------------------------------------------------+
//| Move trailing setting                                            |
//+------------------------------------------------------------------+
int CTrailing::Move(STrailingSetting &dst_settings[],STrailingSetting &src_settings[],const int src_start)
   {
//--- check src start
    if(src_start >= ArraySize(src_settings))
        return(-1);
//--- resize dst settings array
    int size = ArraySize(dst_settings);
    ArrayResize(dst_settings,size + 1);
//--- set value to dst settings array from src settings array
    dst_settings[size] = src_settings[src_start];
    ArrayRemove(src_settings,src_start,1);
    return(size);
   }
//+------------------------------------------------------------------+
//| Checking inactive setting                                        |
//+------------------------------------------------------------------+
bool CTrailing::InActiveCheck(const int index)
   {
//--- checking start price is between bid and last bid
    if((m_inactive_settings[index].Start_Price > m_last_bid &&
        m_inactive_settings[index].Start_Price <= m_bid) ||
       (m_inactive_settings[index].Start_Price < m_last_bid &&
        m_inactive_settings[index].Start_Price >= m_bid))
        return(true);
    return(false);
   }
//+------------------------------------------------------------------+
//| Checking active setting                                          |
//+------------------------------------------------------------------+
bool CTrailing::ActiveCheck(const int index)
   {
//--- checking is distance point < trail point
    if(m_active_settings[index].Distance_Point < m_active_settings[index].Trail_Point)
        return(true);
    return(false);
   }
//+------------------------------------------------------------------+
//| Updating sl and tp values                                        |
//+------------------------------------------------------------------+
bool CTrailing::UpdateSLTP(const int active_index)
   {
    int distance = 0;
//--- checking start and stop price is location
    if(m_active_settings[active_index].Stop_Price > m_active_settings[active_index].Start_Price)
       {
        //--- get the distance between the stop price and the bid price
        distance = (int)((m_active_settings[active_index].Stop_Price - m_bid) / Point());
        if(distance <= 0)
            return(false);
        //--- get the difference between the distance point setting and the distance point
        distance = (int)(m_active_settings[active_index].Distance_Point - distance);
       }
    else
       {
        //--- get the distance between the stop price and the bid price
        distance = (int)((m_bid - m_active_settings[active_index].Stop_Price) / Point());
        if(distance <= 0)
            return(false);
        //--- get the difference between the distance point setting and the distance point
        distance = (int)(m_active_settings[active_index].Distance_Point - distance);
       }
//--- checking is distance point >= trail point setting for update
    if(distance >= m_active_settings[active_index].Trail_Point)
       {
        //--- get trail points
        int trail = distance / m_active_settings[active_index].Trail_Point;
        //--- update sl and tp
        m_sl += (trail * m_active_settings[active_index].SL_Point);
        m_tp += (trail * m_active_settings[active_index].TP_Point);
        //--- update distance point setting
        m_active_settings[active_index].Distance_Point -= m_active_settings[active_index].Trail_Point * trail;
        return(true);
       }
    return(false);
   }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
bool CTrailing::Trailing(const double bid,const double last_bid)
   {
    bool change = false;
//--- update bid and last bid price
    m_time = TimeTradeServer();
    m_bid = bid;
    m_last_bid = last_bid;
//--- checking inactive setting for move to active settings array
    for(int i = m_inactive_settings_total - 1; i >= 0; i--)
       {
        //--- checking inactive setting
        if(InActiveCheck(i))
           {
            //--- moving inactive setting to active setting array
            int index = Move(m_active_settings,m_inactive_settings,i);
            //--- check index and update start time
            if(index >= 0)
                m_active_settings[index].Start_Time = m_time;
           }
       }
//--- checking active settings for move to history settings array
    for(int i = m_active_settings_total - 1; i >= 0; i--)
       {
        //--- updating sl and tp with active setting
        if(UpdateSLTP(i))
            change = true;
        //--- checking active setting
        if(ActiveCheck(i))
           {
            //--- moving active setting to history settings array
            int index = Move(m_history_settings,m_active_settings,i);
            //--- check index and update stop time
            if(index >= 0)
                m_history_settings[index].Stop_Time = m_time;
           }
       }
    return(change);
   }
//+------------------------------------------------------------------+
