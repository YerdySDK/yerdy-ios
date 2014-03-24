//
//  YRDCompilerChecks.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-24.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#pragma once

// Verifies that appropriate compiling settings are enabled for proper compilation
// of Yerdy


#if __clang__ != 1
#error Only Clang is supported at this time
#endif


#if __OBJC__

// ARC
#if !__has_feature(objc_arc) || !__has_feature(objc_arc_weak)
#error ARC (including zeroing weak references) must be enabled
#endif

// instancetype
#if !__has_feature(objc_instancetype)
#error instancetype support must be enabled
#endif

// Objective-C property autosynthesis
#if !__has_feature(objc_default_synthesize_properties)
#error Support for autosynthesis of Objective C properties must be enabled
#endif

// number literals
#if !__has_feature(objc_bool)
#error Support for Objective C number literals (@YES, @1, @3.14, etc..) must be enabled
#endif

// boxed expressions
#if !__has_feature(objc_boxed_expressions)
#error Support for Objective C boxed expressions must be enabled
#endif

// collection literals
#if !__has_feature(objc_array_literals) || !__has_feature(objc_dictionary_literals)
#error NSArray/NSDictionary literals support must be enabled
#endif

// collection subscripting
#if !__has_feature(objc_subscripting)
#error Object subscripting support must be enabled
#endif


#endif  // if __OBJC__