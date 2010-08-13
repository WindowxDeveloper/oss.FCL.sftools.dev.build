<#--
============================================================================ 
Name        : .xml.ftl 
Part of     : Helium 

Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
All rights reserved.
This component and the accompanying materials are made available
under the terms of the License "Eclipse Public License v1.0"
which accompanies this distribution, and is available
at the URL "http://www.eclipse.org/legal/epl-v10.html".

Initial Contributors:
Nokia Corporation - initial contribution.

Contributors:

Description:

============================================================================
--> 
<#include "diamonds_header.ftl">
<#if ant?keys?seq_contains("diamonds.files")>
<files>
    <#list ant['diamonds.files']?split(" ") as line>
        <#if line?split(".")?last == "fpsx">
    <file>
        <name>${line?split("\\")?last}</name>
        <url>${line}</url>
        <type>flash_image</type>
    </file>
        </#if>
        <#if line?split(".")?last == "html" || line?split(".")?last == "log">
    <file>
        <name>${line?split("\\")?last}</name>
        <url>${line}</url>
        <type>log</type>
    </file>
        </#if>
    </#list>
</files> 
</#if>
<#include "diamonds_footer.ftl"> 