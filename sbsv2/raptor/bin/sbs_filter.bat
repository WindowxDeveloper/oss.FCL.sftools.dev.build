@rem
@rem Copyright (c) 2005-2009 Nokia Corporation and/or its subsidiary(-ies).
@rem All rights reserved.
@rem This component and the accompanying materials are made available
@rem under the terms of the License "Eclipse Public License v1.0"
@rem which accompanies this distribution, and is available
@rem at the URL "http://www.eclipse.org/legal/epl-v10.html".
@rem
@rem Initial Contributors:
@rem Nokia Corporation - initial contribution.
@rem
@rem Contributors:
@rem
@rem Description: 
@rem

@REM Automatically find SBS_HOME if it is not set
@IF NOT "%SBS_HOME%"==""  goto foundhome
@SET RAPTORBINDIR=%~dp0
@SET WD=%cd%
@cd %RAPTORBINDIR%\..
@SET SBS_HOME=%cd%
@cd %WD%
:foundhome 

@REM Use the cygwin set by the environment if possible
@SET __CYGWIN__=%SBS_CYGWIN%
@IF "%__CYGWIN__%"=="" SET __CYGWIN__=%SBS_HOME%\win32\cygwin

@REM add to the search path
@SET PATH=%__CYGWIN__%\bin;%PATH%

@REM Make sure that /tmp is not set incorrectly for sbs
@umount -u /tmp >NUL  2>NUL
@mount -u %TEMP% /tmp >NUL 2>NUL
@umount -u / >NUL  2>NUL
@mount -u %__CYGWIN__% / >NUL 2>NUL

@REM Tell CYGWIN not to map unix security attributes to windows to
@REM prevent raptor from potentially creating read-only files:
@set CYGWIN=nontsec nosmbntsec

@REM Run with all the arguments.
@bash %SBS_HOME%\bin\sbs_filter %*

@ENDLOCAL
@cmd /c exit /b %ERRORLEVEL%