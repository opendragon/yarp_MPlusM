# Copyright: (C) 2013 Istituto Italiano di Tecnologia
# Authors: Elena Ceseracciu, Daniele Domenichelli
# CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT

include(CMakeParseArguments)
include(GNUInstallDirs)

# This macro generates the following CMake variables, that can be used as "DESTINATION" argument to the yarp_install macro 
# to copy/install data into appropriate folders in the calling package's build tree and installation directory:
# <PACKAGE>_CONTEXTS_INSTALL_DIR for "context" folders, containing configuration files and data that modules look for at runtime
# <PACKAGE>_PLUGIN_MANIFESTS_INSTALL_DIR for plugin manifest files
# <PACKAGE>_APPLICATIONS_INSTALL_DIR for XML files describing applications (collections of modules and connections between them)
# <PACKAGE>_MODULES_INSTALL_DIR for XML files describing modules (including input/output ports)
# <PACKAGE>_ROBOTS_INSTALL_DIR for robot-specific configuration files
# <PACKAGE>_TEMPLATES_INSTALL_DIR generic directory for templates; it is however advised to use specific applications/modules templates install directories
# <PACKAGE>_APPLICATIONS_TEMPLATES_INSTALL_DIR for application templates (XML files with .template extension), which need to be properly customized
# <PACKAGE>_MODULES_TEMPLATES_INSTALL_DIR for module templates (should not be needed)
# <PACKAGE>_DATA_INSTALL_DIR generic directory for data; it is however advised to use more specific directories
# <PACKAGE>_CONFIG_INSTALL_DIR generic directory for configuration files
#
# Furthermore, this macro checks if the installation directory of the package is the same as YARP's, in which case it sets up automatic recognition of data directories;
# otherwise, it warns the user to set up appropriately the YARP_DATA_DIRS environment variable.

macro(YARP_CONFIGURE_EXTERNAL_INSTALLATION _name)
    if (YARP_INSTALL_PREFIX) #if YARP is installed

        get_filename_component(yarp_prefix "${YARP_INSTALL_PREFIX}" ABSOLUTE)
        get_filename_component(current_prefix "${CMAKE_INSTALL_PREFIX}" ABSOLUTE)
        string(COMPARE EQUAL ${yarp_prefix}  ${current_prefix} same_path)
        if((NOT same_path) AND WIN32) #CMAKE appends project name to default prefix, let's also check parent directories
            get_filename_component(yarp_prefix_parent ${yarp_prefix} PATH)
            get_filename_component(current_prefix_parent ${current_prefix} PATH)
            string(COMPARE EQUAL ${yarp_prefix_parent} ${current_prefix_parent} same_path)
        endif()

        if (same_path)
            set(BUFFER "###### This file is automatically generated by CMake.\n")
            set(BUFFER "${BUFFER}[search ${_name}]\n")
            set(BUFFER "${BUFFER}path \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/${_name}\"\n")
            file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/path.d/${_name}.ini "${BUFFER}") #Create _name.ini file inside build directory
            install(FILES ${CMAKE_CURRENT_BINARY_DIR}/path.d/${_name}.ini DESTINATION ${YARP_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/yarp/config/path.d) #Install the file into yarp config dir
            message(STATUS "Setting up installation of ${_name}.ini to ${YARP_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/yarp/config/path.d folder.")
        else()
            if(WIN32)
                set(PATH_SEPARATOR ";")
            else()
                set(PATH_SEPARATOR ":")
            endif()

            if("$ENV{YARP_DATA_DIRS}" STREQUAL "")
                message(WARNING "Installation prefix is different from YARP's : no file will we be installed into path.d folder, you need to set YARP_DATA_DIRS environment variable to ${YARP_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/yarp${PATH_SEPARATOR}${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/${_name}")
            else()
                message(WARNING "Installation prefix is different from YARP's : no file will we be installed into path.d folder, you need to set YARP_DATA_DIRS environment variable to $ENV{YARP_DATA_DIRS}${PATH_SEPARATOR}${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/${_name}")
            endif()
        endif()

    endif()

    string(TOUPPER ${_name} _NAME)
    # (uppercase _name -> _NAME)
    # Generate and set variables
    set(${_NAME}_DATA_INSTALL_DIR ${CMAKE_INSTALL_DATADIR}/${_name} CACHE INTERNAL "general data installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_CONFIG_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/config CACHE INTERNAL "configuration files installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_PLUGIN_MANIFESTS_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/plugins CACHE INTERNAL "plugin manifests installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_MODULES_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/modules CACHE INTERNAL "modules' XML descriptions installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_APPLICATIONS_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/applications CACHE INTERNAL "applications' XML descriptions installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_TEMPLATES_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/templates CACHE INTERNAL "general templates installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_CONTEXTS_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/contexts CACHE INTERNAL "contexts installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_APPLICATIONS_TEMPLATES_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/templates/applications CACHE INTERNAL "application templates' installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_MODULES_TEMPLATES_INSTALL_DIR ${${_NAME}_DATA_INSTALL_DIR}/templates/modules CACHE INTERNAL "module templates' installation directory for ${_name} (relative to build/installation dir")
    set(${_NAME}_ROBOTS_INSTALL_DIR  ${${_NAME}_DATA_INSTALL_DIR}/robots CACHE INTERNAL "robot-specific configurations installation directory for ${_name} (relative to build/installation dir")
endmacro()

# This macro has the same signature as CMake "install" command (i.e., with DESTINATION and FILES/DIRECTORY arguments); in addition to calling the "install" command,
# it also copies files to the build directory, keeping the same directory tree structure, to allow direct use of build tree without installation.
macro(YARP_INSTALL)

   install(${ARGN})
   #change destination argument 'dest' to "${CMAKE_BINARY_DIR}/${dest}"
   cmake_parse_arguments(currentTarget "" "DESTINATION" "FILES;DIRECTORY;PROGRAMS;PERMISSIONS" "${ARGN}")

   string(REGEX REPLACE "^${CMAKE_INSTALL_PREFIX}/" "" currentTarget_DESTINATION_RELATIVE ${currentTarget_DESTINATION})
   string(REGEX REPLACE ";DESTINATION;${currentTarget_DESTINATION}(;|$)" ";DESTINATION;${CMAKE_BINARY_DIR}/${currentTarget_DESTINATION_RELATIVE}\\1" copyARGN "${ARGN}")
   list(REMOVE_AT copyARGN 0)
   list(INSERT copyARGN 0 COPY)
   if (currentTarget_PROGRAMS AND NOT currentTarget_PERMISSIONS)
       list(APPEND copyARGN "FILE_PERMISSIONS;OWNER_READ;OWNER_WRITE;OWNER_EXECUTE;GROUP_READ;GROUP_EXECUTE;WORLD_READ;WORLD_EXECUTE")
   endif()
   file(${copyARGN})

endmacro()

