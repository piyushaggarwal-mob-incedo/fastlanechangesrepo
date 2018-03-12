//
//  DebugLogger.h
//  SnagFilms
//
//  Created by Anirudh Vyas on 17/11/14.
//  Copyright (c) 2014 None. All rights reserved.
//

//Debug log.

#if DEBUG
#   define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);//Print the method where the DebugLog has been called along with the line number.
#else
#   define DebugLog(...)
#endif