#   GNUmakefile 
#
#   Copyright (C) 1999 Free Software Foundation, Inc.
#
#   Author:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
#   Date: 1999
#   
#   This file is part of GNUstep.
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = StepTalkView

StepTalkView_OBJC_FILES = StepTalkObject.m StepTalkClass.m \
				StepTalkMethod.m StepTalkRuntime.m \
				StepTalkMetadatas.m StepTalkView.m

StepTalkView_HEADER_FILES = StepTalkObject.h StepTalkClass.h \
				StepTalkMethod.h StepTalkRuntime.h \
				StepTalkMetadatas.h StepTalkView.h
StepTalkView_HEADER_FILES_INSTALL_DIR = StepTalkView

ADDITIONAL_LDFLAGS += -lStepTalk

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble
