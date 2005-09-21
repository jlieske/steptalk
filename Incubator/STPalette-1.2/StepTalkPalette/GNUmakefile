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

PALETTE_NAME = StepTalk
StepTalk_PALETTE_ICON = StepTalkPalette
StepTalk_OBJC_FILES = \
	StepTalkInspector.m \
	StepTalkClassInspector.m \
	StepTalkConnectionInspector.m \
	StepTalkPalette.m 

StepTalk_PRINCIPAL_CLASS = StepTalkPalette

ADDITIONAL_LDFLAGS += -lStepTalk -lStepTalkView

StepTalk_RESOURCE_FILES = \
	StepTalkIcon.png \
	StepTalkViewIcon.png \
	StepTalkPalette.tiff \
	StepTalkPalette.gorm \
	StepTalkInspector.gorm \
	StepTalkClassInspector.gorm \
	palette.table

StepTalk_STANDARD_INSTALL = no

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/palette.make

-include GNUmakefile.postamble
