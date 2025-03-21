//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                   Copyright 2025, Milad Alizade. |
//|                   https://www.mql5.com/en/users/MiladAlizade2559 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Milad Alizade."
#property link      "https://www.mql5.com/en/users/MiladAlizade2559"
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Base/SBase.mqh>
//+------------------------------------------------------------------+
//| Structs                                                          |
//+------------------------------------------------------------------+
struct STrailingSetting : public SBase
   {
    datetime         Set_Time;
    datetime         Start_Time;
    datetime         Stop_Time;
    double           Start_Price;
    double           Stop_Price;
    int              Trail_Point;
    int              SL_Point;
    int              TP_Point;
    int              Distance_Point;
    int              Variables(const ENUM_VARIABLES_FLAGS flag,string &array[],const bool compact_objs = false);
   };
//+------------------------------------------------------------------+
//| Setting variables                                                |
//+------------------------------------------------------------------+
int STrailingSetting::Variables(const ENUM_VARIABLES_FLAGS flag,string &array[],const bool compact_objs = false)
   {
    SBase::Variables(flag,array,compact_objs);
    _datetime(Set_Time);
    _datetime(Start_Time);
    _datetime(Stop_Time);
    _double(Start_Price);
    _double(Stop_Price);
    _int(Trail_Point);
    _int(SL_Point);
    _int(TP_Point);
    _int(Distance_Point);
    return(SBase::Variables(array));
   }
//+------------------------------------------------------------------+
