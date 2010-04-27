/*
 * Copyright (c) 2007-2008 Nokia Corporation and/or its subsidiary(-ies).
 * All rights reserved.
 * This component and the accompanying materials are made available
 * under the terms of the License "Eclipse Public License v1.0"
 * which accompanies this distribution, and is available
 * at the URL "http://www.eclipse.org/legal/epl-v10.html".
 *
 * Initial Contributors:
 * Nokia Corporation - initial contribution.
 *
 * Contributors:
 *
 * Description:  
 *
 */
package com.nokia.helium.sbs.ant.taskdefs;

import java.util.Vector;
import java.util.Map.Entry;

import com.nokia.helium.core.ant.types.Variable;
import com.nokia.helium.core.ant.types.VariableSet;

/**
 * This task is to execute the cov-build command with the list of sbs parameters
 * using sbsinput type. Based on the raptor input list of additional log file
 * path used needs to be set, so that the scanlog, additional log files are
 * generated properly.
 * 
 * <pre>
 * Example 1:
 * 
 * &lt;coveritybuild sbsinput=&quot;sbs.input&quot; sysdefFile=&quot;system.def.file&quot;
 *      workingDir=&quot;build.drive&quot; failOnError=&quot;false&quot; 
 *      cleanLog=&quot;sbs.log.file.clean.log&quot; 
 *      failOnError=&quot;false&quot; 
 *      errorfile=&quot;path to error file&quot;/&gt;
 * </pre>
 * 
 * @ant.task name="coveritybuild" category="SBS"
 */
public class SBSCoverity extends SBSTask {

    private Vector<VariableSet> coverityOptions = new Vector<VariableSet>();
    
    /**
     * Default constructor.
     */
    public SBSCoverity() {
        super();
        setAddMakeOptions(false);
        getSbsCmd().setExecutable("cov-build");
    }
    
    
    protected String getSBSCmdLine() {

        StringBuffer coverityCmdOptions = new StringBuffer();

        String coverityConfig = "";
        for (VariableSet coverityArg : coverityOptions) {
            for (Entry<String, Variable> entry : coverityArg.getVariablesMap()
                    .entrySet()) {
                coverityConfig = coverityConfig + entry.getKey() + " "
                        + entry.getValue().getValue() + " ";
            }
        }
        coverityCmdOptions.append(coverityConfig + "sbs" + super.getSBSCmdLine());
        return coverityCmdOptions.toString();

    }
    
    /**
     * @param pattern. To set the pattern to be read from error to super class.
     */
    protected String getErrorStreamPattern() {
        return "ERROR";
    }
    

    /**
     * To read the coverity arguments for cov-build command.
     * 
     * @param coverityArg
     */
    public void addCoverityOptions(VariableSet coverityArg) {
        if (!coverityOptions.contains(coverityArg)) {
            coverityOptions.add(coverityArg);
        }
    }

}
