############################################################################
# Bcg729Config.cmake
# Copyright (C) 2015  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
############################################################################
#
# Config file for the bcg729 package.
# It defines the following variables:
#
#  BCG729_FOUND - system has bcg729
#  BCG729_INCLUDE_DIRS - the bcg729 include directory
#  BCG729_LIBRARIES - The libraries needed to use bcg729
#  BCG729_CPPFLAGS - The compilation flags needed to use bcg729

if(NOT LINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS)
	include("${CMAKE_CURRENT_LIST_DIR}/Bcg729Targets.cmake")
endif()

if(NO)
	set(BCG729_TARGETNAME bcg729)
	set(BCG729_LIBRARIES ${BCG729_TARGETNAME})
else()
	set(BCG729_TARGETNAME bcg729-static)
	if(TARGET ${BCG729_TARGETNAME})
		if(LINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS)
			set(BCG729_LIBRARIES ${BCG729_TARGETNAME})
		else()
			get_target_property(BCG729_LIBRARIES ${BCG729_TARGETNAME} LOCATION)
		endif()
		get_target_property(BCG729_LINK_LIBRARIES ${BCG729_TARGETNAME} INTERFACE_LINK_LIBRARIES)
		if(BCG729_LINK_LIBRARIES)
			list(APPEND BCG729_LIBRARIES ${BCG729_LINK_LIBRARIES})
		endif()
	endif()
endif()
get_target_property(BCG729_INCLUDE_DIRS ${BCG729_TARGETNAME} INTERFACE_INCLUDE_DIRECTORIES)
if (NOT BCG729_INCLUDE_DIRS)
	set (BCG729_INCLUDE_DIRS)
endif()
if(LINPHONE_BUILDER_GROUP_EXTERNAL_SOURCE_PATH_BUILDERS)
	list(INSERT BCG729_INCLUDE_DIRS 0 "${EP_bcg729_INCLUDE_DIR}")
else()
	list(INSERT BCG729_INCLUDE_DIRS 0 "/Users/hu/Documents/linphone/duhao-linphone/duhao-linphone/linphone-iphone/liblinphone-sdk/x86_64-apple-darwin.ios/include")
endif()
list(REMOVE_DUPLICATES BCG729_INCLUDE_DIRS)

set(BCG729_CPPFLAGS -DBCG729_STATIC)
set(BCG729_FOUND 1)
