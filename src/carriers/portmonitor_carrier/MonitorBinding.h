// -*- mode:C++; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

/*
 * Copyright (C) 2012 IITRBCS
 * Authors: Ali Paikan
 * CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT
 *
 */

#ifndef _MONITORBINDING_INC_
#define _MONITORBINDING_INC_

#include <yarp/os/ConnectionReader.h>
#include <yarp/os/Property.h>
#include <yarp/os/Things.h>

#include "MonitorEvent.h"

class MonitorBinding 
{

public:
    virtual ~MonitorBinding();   
    virtual bool loadScript(const char* filename) = 0;
    virtual bool setParams(const yarp::os::Property& params) = 0;
    virtual bool getParams(yarp::os::Property& params) = 0;
    virtual bool acceptData(yarp::os::Things& thing) = 0;
    virtual yarp::os::Things& updateData(yarp::os::Things& thing) = 0;
    virtual bool peerTrigged(void) = 0;
    virtual bool setAcceptConstraint(const char* constraint) = 0;
    virtual const char* getAcceptConstraint(void) = 0;
    virtual bool canAccept(void) = 0;

    /**
     * factory method 
     */
    static MonitorBinding *create(const char* script_type);

};

#endif //_MONITORBINDING_INC_


