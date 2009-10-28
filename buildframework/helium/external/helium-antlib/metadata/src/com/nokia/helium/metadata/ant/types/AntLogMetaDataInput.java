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

package com.nokia.helium.metadata.ant.types;

import java.io.*;
import org.apache.tools.ant.BuildException;
import java.util.*;
import org.apache.log4j.Logger;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * This Type is to specify and use the ant logparser type to parse and store the data.
 *
 * <pre>
 * &lt;hlm:metadatafilterset id="ant.metadata.filter"&gt;
 *    &lt;metadatafilterset filterfile="${project.dir}/../data/common.csv" /&gt;
 * &lt;/hlm:metadatafilterset&gt;
 * 
 * &lt;hlm:antmetadatainput&gt;
 *    &lt;fileset dir="${project.dir}/../data/"&gt;
 *        &lt;include name="*zip*.log"/&gt;
 *    &lt;/fileset&gt;
 *    &lt;metadatafilterset refid="ant.metadata.filter" /&gt;
 * &lt;/hlm:antmetadatainput&gt;
 * </pre>
 * 
 * @ant.task name="textmetadatainput" category="Metadata"
 */
public class AntLogMetaDataInput extends TextLogMetaDataInput {

    private Logger log = Logger.getLogger(AntLogMetaDataInput.class);
    
    private Pattern antTargetPattern = Pattern.compile("^([^\\s=\\[\\]]+):$");
    
    private String currentComponent;
    
    private boolean entryCreated;
    
    public AntLogMetaDataInput() {
    }

    public boolean isEntryAvailable() {
        String exceptions = "";
        int currentFileIndex = getCurrentFileIndex();
        int lineNumber = getLineNumber(); 
        BufferedReader currentReader = getCurrentReader();
        log.debug("Getting next set of log entries for Ant Input");
        //log.debug("currentFileIndex" + currentFileIndex);
        List<File> fileList = getFileList();
        //log.debug("is filelist empty" + fileList.isEmpty());
        int fileListSize = fileList.size();
        log.debug("fileList.size" + fileListSize);
        while (currentFileIndex < fileListSize) {
            try {
                lineNumber ++;
                setLineNumber(lineNumber);
                log.debug("currentfileindex while getting file name: " + currentFileIndex);
                File currentFile = fileList.get(currentFileIndex);
                if (currentReader == null) {
                    setLineNumber(0);
                    log.debug("Current Text log file name:" + currentFile);
                    log.info("Processing file: " + currentFile);
                    currentReader = new BufferedReader(new FileReader(currentFile));
                    setCurrentReader(currentReader);
                }
                String logText = "";
                while ((logText = currentReader.readLine()) != null) {
                    //log.debug("logtext : " + logText + " line-number: " + lineNumber);
                    //log.debug("logtext : " + logText + " line-number: " + lineNumber);
                    Matcher match = antTargetPattern.matcher(logText); 
                    if (match.matches()) {
                        if (currentComponent != null && !entryCreated) {
                            addEntry("DEFAULT", currentComponent, currentFile.toString(), 
                                    0, "" );
                            entryCreated = true;
                            return true;
                        }
                        entryCreated = false;
                        currentComponent = match.group(1);
                        //log.debug("currentComponent:" + currentComponent);
                    }
                    logText = logText.replaceFirst("^[ ]*\\[.+?\\][ ]*", "");
                    String severity = getSeverity(logText);
                    if (severity != null) {
//                        log.debug("severity:" + severity);
//                        log.debug("currentFile:" + currentFile);
//                        log.debug("lineNumber:" + lineNumber);
//                        log.debug("logText:" + logText);
                        entryCreated = true;
                        // If there is no current component which means
                        // it is a redirected output, using file name as comp name
                        if (currentComponent == null ) {
                            currentComponent = currentFile.getName();
                        }
                        addEntry(severity, currentComponent, currentFile.toString(), 
                                lineNumber, logText );
                        logText = "";
                        return true;
                    }
                }
                currentReader.close();
                currentReader = null;
                setCurrentReader(currentReader);
                currentFileIndex ++;
                setCurrentFileIndex(currentFileIndex);
                //log.debug("currentfileindex: " + currentFileIndex);
                //log.debug("fileListSize: " + fileListSize);
            } catch (Exception ex) {
                log.debug("Exception in AntLogMetadata", ex);
                try {
                    currentReader.close();
                } catch ( IOException iex) {
                    log.debug("Exception in closing reader");
                }
                currentReader = null;
                setCurrentReader(null);
                exceptions = exceptions + ex.getMessage() + "\n";
                return false;
            }
        }
        if (!exceptions.equals("")) {
            throw new BuildException(exceptions);
        }
        
        return false;
    }
}