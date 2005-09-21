#
#  GNUmakefile
#
#  Copyright (C) 2000 Stefan Urbanek
#
#  This file is part of the StepTalk.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

include $(GNUSTEP_MAKEFILES)/common.make

include ../../Version

FRAMEWORK_NAME = StepTalkPanels

StepTalkPanels_OBJC_FILES = \
    STScriptView.m 

StepTalkPanels_HEADER_FILES = \
    STScriptView.m 

StepTalkPanels_RESOURCE_FILES = ScriptingInfo.plist        

ADDITIONAL_OBJCFLAGS = -Wno-import -DSTEPTALK_VERSION=$(STEPTALK_VERSION)

DOCUMENT_NAME = StepTalkPanels

StepTalkPanels_DOC_INSTALL_DIR = Developer

StepTalkPanels_HEADER_FILES_DIR = $(HEADER_DIR)
StepTalkPanels_AGSDOC_FILES = StepTalkPanels.gsdoc $(STEPTALK_HEADER_FILES)
StepTalkPanels_AGSDOC_FLAGS = \
        -Up StepTalk \
        -Declared StepTalkPanels \
        -DocumentationDirectory ../../Documentation/Reference

ifeq ($(GNUSTEP_TARGET_OS),mingw32)
    StepTalkPanels_LIBRARIES_DEPEND_UPON += -lStepTalk
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/framework.make

ifeq ($(doc), yes)
    include $(GNUSTEP_MAKEFILES)/documentation.make
endif

-include GNUmakefile.postamble
