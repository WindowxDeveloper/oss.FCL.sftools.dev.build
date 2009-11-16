#
# Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# This component and the accompanying materials are made available
# under the terms of the License "Eclipse Public License v1.0"
# which accompanies this distribution, and is available
# at the URL "http://www.eclipse.org/legal/epl-v10.html".
#
# Initial Contributors:
# Nokia Corporation - initial contribution.
#
# Contributors:
#
# Description: 
#

from raptor_tests import SmokeTest

def run():
	t = SmokeTest()
	t.id = "11"
	t.name = "dll_armv7"
	t.command = "sbs -b smoke_suite/test_resources/simple_dll/bld.inf -c armv7"
	t.targets = [
		"$(EPOCROOT)/epoc32/release/armv7/udeb/createstaticdll.dll.sym",
		"$(EPOCROOT)/epoc32/release/armv7/urel/createstaticdll.dll.sym",
		"$(EPOCROOT)/epoc32/release/armv5/lib/createstaticdll.dso",
		"$(EPOCROOT)/epoc32/release/armv5/lib/createstaticdll{000a0000}.dso",
		"$(EPOCROOT)/epoc32/release/armv7/udeb/createstaticdll.dll",
		"$(EPOCROOT)/epoc32/release/armv7/urel/createstaticdll.dll"
		]
	t.addbuildtargets('smoke_suite/test_resources/simple_dll/bld.inf', [
		"createstaticdll_dll/armv7/udeb/CreateStaticDLL.o",
		"createstaticdll_dll/armv7/urel/CreateStaticDLL.o",
		"createstaticdll_dll/armv7/udeb/armv7_specific.o",
		"createstaticdll_dll/armv7/urel/armv7_specific.o"		
	])
	t.run()
	return t
