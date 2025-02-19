// -*- mode:C++; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

/*
 * Copyright: (C) 2010 RobotCub Consortium
 * Author: Paul Fitzpatrick
 * CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT
 */

#ifndef _YARP2_API_
#define _YARP2_API_

/*

The purpose of this header file is to correctly define:
  YARP_EXPORT
  YARP_IMPORT
Since YARP is composed of several libraries, we may be compiling one
library (and exporting its symbols) while using another (and importing
its symbols).  The set of YARP libraries is rather open-ended so,
it is better not to try enumerating them here.  Given that, the
recommended usage of this header within YARP is:
//
#include <yarp/conf/api.h>
#ifndef YARP_OS_API
#  ifdef YARP_OS_EXPORTS
#    define YARP_OS_API YARP_EXPORT
#  else
#     define YARP_OS_API YARP_IMPORT
#  endif
#endif

(replace YARP_OS with CMake target name for library)

*/

// YARP_DLL: defined if YARP is compiled as DLLs
#define YARP_DLL

// YARP_FILTER_API: define if YARP is configured to apply API declarations.
#define YARP_FILTER_API

#if defined _WIN32 || defined __CYGWIN__
#  define YARP_HELPER_DLL_IMPORT __declspec(dllimport)
#  define YARP_HELPER_DLL_EXPORT __declspec(dllexport)
#  define YARP_HELPER_DLL_LOCAL
#  define YARP_HELPER_DLL_IMPORT_EXTERN extern
#  define YARP_HELPER_DLL_EXPORT_EXTERN
#  ifndef YARP_NO_DEPRECATED_WARNINGS
#    define YARP_HELPER_DLL_DEPRECATED __declspec(deprecated)
#  endif
#else
#  if __GNUC__ >= 4
#    define YARP_HELPER_DLL_IMPORT __attribute__ ((visibility("default")))
#    define YARP_HELPER_DLL_EXPORT __attribute__ ((visibility("default")))
#    define YARP_HELPER_DLL_LOCAL  __attribute__ ((visibility("hidden")))
#    define YARP_HELPER_DLL_IMPORT_EXTERN
#    define YARP_HELPER_DLL_EXPORT_EXTERN
#  else
#     define YARP_HELPER_DLL_IMPORT
#     define YARP_HELPER_DLL_EXPORT
#     define YARP_HELPER_DLL_LOCAL
#     define YARP_HELPER_DLL_IMPORT_EXTERN
#     define YARP_HELPER_DLL_EXPORT_EXTERN
#  endif
#  if (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 1))
#    ifndef YARP_NO_DEPRECATED_WARNINGS
#      define YARP_HELPER_DLL_DEPRECATED __attribute__ ((__deprecated__))
#    endif
#  endif
#endif
#ifndef YARP_HELPER_DLL_DEPRECATED
#  define YARP_HELPER_DLL_DEPRECATED
#endif

#if defined YARP_DLL && defined YARP_FILTER_API
#  define YARP_IMPORT YARP_HELPER_DLL_IMPORT
#  define YARP_EXPORT YARP_HELPER_DLL_EXPORT
#  define YARP_LOCAL YARP_HELPER_DLL_LOCAL
#  define YARP_IMPORT_EXTERN YARP_HELPER_DLL_IMPORT_EXTERN
#  define YARP_EXPORT_EXTERN YARP_HELPER_DLL_EXPORT_EXTERN
#  define YARP_DEPRECATED YARP_HELPER_DLL_DEPRECATED
#else
#  define YARP_IMPORT
#  define YARP_EXPORT
#  define YARP_LOCAL
#  define YARP_IMPORT_EXTERN
#  define YARP_EXPORT_EXTERN
#  define YARP_DEPRECATED
#endif

#endif /* _YARP2_API_ */
