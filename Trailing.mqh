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

protected:
    STrailingSetting m_inactive_settings[];        // settings array inactive
    STrailingSetting m_active_settings[];          // settings array active
    STrailingSetting m_history_settings[];         // settings array history
    int              m_inactive_settings_total;    // settings total inactive
    int              m_active_settings_total;      // settings total active
    int              m_history_settings_total;     // settings total history
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
    m_inactive_settings[m_inactive_settings_total].Set_Time = TimeTradeServer();
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
    m_active_settings[m_active_settings_total].Set_Time = TimeTradeServer();
    m_active_settings[m_active_settings_total].Start_Time = TimeTradeServer();
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
