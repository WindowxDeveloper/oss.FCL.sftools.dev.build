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

package com.nokia.helium.signal.ant;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.condition.Condition;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Target;
import com.nokia.helium.signal.Notifier;
import com.nokia.helium.signal.SignalStatus;
import com.nokia.helium.signal.SignalStatusList;
import com.nokia.helium.core.LogSource;
import com.nokia.helium.signal.ant.types.SignalListenerConfig;
import com.nokia.helium.signal.ant.types.SignalInput;
import com.nokia.helium.signal.ant.types.SignalNotifierInput;
import com.nokia.helium.signal.ant.types.SignalConfig;
import com.nokia.helium.signal.ant.types.NotifierInput;
import com.nokia.helium.signal.ant.types.SignalNotifierList;
import com.nokia.helium.signal.ant.types.TargetCondition;

import java.io.File;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.Vector;
import java.util.HashMap;
import java.util.Date;
import java.util.Enumeration;
import org.apache.log4j.Logger;

/**
 * Helper class to store the list of notifiers.
 */
public class SignalList {

    // default id list name
    public static final String DEFAULT_NOTIFIER_LIST_REFID = "defaultSignalInput";


    private Hashtable<String, SignalListenerConfig> signalListenerConfigs = new Hashtable<String, SignalListenerConfig>();

    private HashMap<String, List<SignalListenerConfig>> targetsMap = new HashMap<String, List<SignalListenerConfig>>();

    private Hashtable<String, SignalConfig> signalConfigs = new Hashtable<String, SignalConfig>();

    private HashMap<String, List<SignalConfig>> targetsConfigMap = new HashMap<String, List<SignalConfig>>();

    private Project project;

    private Logger log = Logger.getLogger(this.getClass());

     /**
     * Constructor
     */
    @SuppressWarnings("unchecked")
    public SignalList(Project project) {
        this.project = project;
        Hashtable<String, Object> references = project.getReferences();
        Enumeration<String> keyEnum = references.keys();
        while (keyEnum.hasMoreElements()) {
            String key = keyEnum.nextElement();
            if (references.get(key) instanceof SignalListenerConfig) {
                log.debug("SignalList: Found reference: " + key);
                SignalListenerConfig config = (SignalListenerConfig) references
                        .get(key);
                config.setConfigId(key);
                signalListenerConfigs.put(key, config);
                String targetName = config.getTargetName();
                List<SignalListenerConfig> list;
                if (targetsMap.get(targetName) == null) {
                    list = new ArrayList<SignalListenerConfig>();
                } else {
                    list = targetsMap.get(targetName);
                }
                list.add(config);
                targetsMap.put(targetName, list);
            }
            if (references.get(key) instanceof SignalConfig) {
                log.debug("SignalList: Found reference: " + key);
                SignalConfig config = (SignalConfig) references.get(key);
                config.setConfigId(key);
                signalConfigs.put(key, config);
                Set targetNameSet = config.getTargetNameSet();
                Iterator iter = targetNameSet.iterator();
                while (iter.hasNext()) {
                    String targetName = (String) iter.next();
                    List<SignalConfig> list;
                    if (targetsConfigMap.get(targetName) == null)
                    {
                        list = new ArrayList<SignalConfig>();
                    }
                    else
                    {
                        list = targetsConfigMap.get(targetName);
                    }
                    list.add(config);
                    targetsConfigMap.put(targetName, list);
                }
            }
        }
    }

    public Project getProject() {
        return project;
    }

    /**
     * Returns the list of SignalConfig discovered.
     * @return a Vector of SignalList objects.
     */
    public Vector<SignalListenerConfig> getSignalListenerConfigList() {
        return new Vector<SignalListenerConfig>(signalListenerConfigs.values());
    }

    /**
     * Check if targetName is defined is defined by a targetCondition.
     * @param targetName the target name
     * @return a boolean, true if found, false otherwise.
     */
    public boolean isTargetInSignalList(String targetName) {
        return targetsMap.get(targetName) != null;
    }

    /**
     * Return the list of signalConfig defining a target.
     * @param targetName
     * @return
     */
    public List<SignalListenerConfig> getSignalListenerConfig(String targetName) {
        return targetsMap.get(targetName);
    }

    protected void sendNotifications(Vector<Notifier> notifierList, String signalName) {
        sendNotifications(notifierList, signalName, false, null);
    }

    public void processForSignal(Project prj, SignalNotifierInput signalNotifierInput, String signalName, String targetName, 
            String errorMessage, boolean failBuild) {
        SignalInput signalInput = signalNotifierInput.getSignalInput();
        Vector<Notifier> notifierList = signalInput.getSignalNotifierList();
        if (notifierList == null) {
            Object obj = (Object) prj
                    .getReference(DEFAULT_NOTIFIER_LIST_REFID);
            if (obj instanceof SignalNotifierList) {
                notifierList = ((SignalNotifierList) obj)
                        .getNotifierList();
            }
        }
        NotifierInput notifierInput = signalNotifierInput.getNotifierInput();
        sendNotifications(notifierList, signalName, failBuild,
                notifierInput);
        if (failBuild) {
            String failStatus = "now";
            if (signalInput != null) {
                failStatus = signalInput.getFailBuild();
            } else {
                log.debug("Could not find config for signal: " + signalName);
            }
            if (failStatus == null || failStatus.equals("now")) {
                SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                        errorMessage, targetName, new Date()));
                throw new BuildException(new SignalStatus(signalName,
                        errorMessage, targetName, new Date()).toString());
            } else if (failStatus.equals("defer")) {
                log.debug("SignalList:adding defer signal:");
                log.info("Signal " + signalName + " will be deferred.");
                SignalStatusList.getDeferredSignalList().addSignalStatus(new SignalStatus(
                        signalName, errorMessage, targetName, new Date()));
            } else if (failStatus.equals("never")) {
                log.debug("SignalList:adding never signal:");
                SignalStatusList.getNeverSignalList().addSignalStatus(new SignalStatus(signalName,
                        errorMessage, targetName, new Date()));
            } else if (!failStatus.equals("never")) {
                SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                        errorMessage, targetName, new Date()));
                throw new BuildException(new SignalStatus(signalName,
                        errorMessage, targetName, new Date()).toString());
            } else {
                log.info("Signal " + signalName
                        + " set to be ignored by the configuration.");
            }
        }
    }
    /**
     * Send notification using the notification list.
     * 
     * @param notifierList
     */
    protected void sendNotifications(Vector<Notifier> notifierList, String signalName,
            boolean failStatus, NotifierInput notifierInput) {
        if (notifierList == null) {
            return;
        }
        for (Notifier notifier : notifierList) {
            if (notifier != null) {
                notifier.sendData(signalName, failStatus, notifierInput);
            }
        }
    }

    public boolean checkAndNotifyFailure(Target target, Project prj) {
        String targetName = target.getName();
        String signalName = "unknown";
        boolean retValue = false;
        
        if (isTargetInSignalList(targetName)) {
            retValue = true;
            for (SignalListenerConfig config : getSignalListenerConfig(targetName))
            {
                TargetCondition targetCondition = config
                        .getTargetCondition();
                String errorMessage = null;
                log.debug("targetcondition:" + targetCondition);
                Condition condition = null;
                if (targetCondition != null) {
                    condition = getFailureCondition(targetCondition);
                }
                errorMessage = config.getErrorMessage();
                String refid = config.getConfigId();
                log.debug("refid:" + refid);
                Object  configCurrent = prj.getReference(refid);
                if (configCurrent != null && configCurrent instanceof SignalListenerConfig) {
                    signalName = refid;
                }
                processForSignal(prj, config.getSignalNotifierInput(), signalName, 
                        targetName, errorMessage, condition != null);
                log.debug("SignalList:fail:signalName: " + signalName);
            }
        }
        return retValue;
    }
    
    private Condition getFailureCondition(TargetCondition targetCondition) {
        Condition retCondition = null;
        Vector<Condition> conditionList = targetCondition.getConditions();
        for (Condition condition : conditionList) {
            log.debug("SignalList:getErrorMessage:" + condition.eval());
            if (condition.eval()) {
                retCondition = condition;
                break;
            }
        }
        return retCondition;
    }


    
    /**
     * Returns the list of variables available in the VariableSet
     * 
     * @return variable list
     */
    public Vector<SignalConfig> getSignalConfigList() {
        return new Vector<SignalConfig>(signalConfigs.values());
    }

    public boolean isTargetInSignalConfigList(String targetName) {
        return targetsConfigMap.get(targetName) != null;
    }

    public List<SignalConfig> getSignalConfigs(String targetName) {
        return targetsConfigMap.get(targetName);
    }

    /**
     * Send signal notification by running configured notifiers.
     * 
     * @param targetName
     */
    public void sendSignal(String signalName, boolean failStatus)
    {
        log.debug("Sending signal for:" + signalName);
        if (signalConfigs.containsKey(signalName)) {
            SignalConfig config = signalConfigs.get(signalName);
            sendNotify(config.getSignalInput().getSignalNotifierList(),
                    signalName, failStatus, 
                    getFileList(project,config.getLogSourceList(), config.getSourceType()));
        } else if (project.getReference(DEFAULT_NOTIFIER_LIST_REFID) != null) {
            // sending using default settings
            sendNotify(((SignalInput) project
                    .getReference(DEFAULT_NOTIFIER_LIST_REFID))
                    .getSignalNotifierList(), signalName, failStatus,null);
        }
    }

    protected void sendNotify(Vector<Notifier> notifierList, String signalName) {
        sendNotify(notifierList, signalName, false, null);
    }

    /**
     * Send notification using the notification list.
     * 
     * @param notifierList
     */
    @SuppressWarnings("deprecation")
    protected void sendNotify(Vector<Notifier> notifierList, String signalName,
            boolean failStatus, List<String> fileList) {
        if (notifierList == null) {
            return;
        }
        for (Notifier notifier : notifierList) {
            if (notifier != null) {
                notifier.sendData(signalName, failStatus, fileList);
            }
        }
    }

    /**
     * Handle the signal, either fail now, or defer the failure.
     * 
     * @param targetName
     *            , target where the failure happened.
     * @param errMsg
     *            , the error message
     */
    public void fail(String signalName, String targetName, String errorMessage)
    {
        String failStatus = "now";
        if (signalConfigs.containsKey(signalName)) {
            SignalConfig config = signalConfigs.get(signalName);
            SignalInput si = config.getSignalInput();
            log.debug("failStatus: " + si);
            if (si != null) {
                failStatus = si.getFailBuild();
                
            }
        } else {
            log.debug("Could not find config for signal: " + signalName);
        }
        log.debug("failStatus: " + failStatus);
        if (failStatus == null || failStatus.equals("now")) {
            SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                    errorMessage, targetName, new Date()));
            throw new BuildException(new SignalStatus(signalName,
                    errorMessage, targetName, new Date()).toString());
        } else if (failStatus.equals("defer")) {
            log.debug("SignalList1:adding defer signal:");
            log.info("Signal " + signalName + " will be deferred.");
            SignalStatusList.getDeferredSignalList().addSignalStatus(new SignalStatus(
                    signalName, errorMessage, targetName, new Date()));
        } else if (failStatus.equals("never")) {
            log.debug("SignalList1:adding never signal:");
            SignalStatusList.getNeverSignalList().addSignalStatus(new SignalStatus(signalName,
                    errorMessage, targetName, new Date()));
        } else if (!failStatus.equals("never")) {
            SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                    errorMessage, targetName, new Date()));
            throw new BuildException(new SignalStatus(signalName,
                    errorMessage, targetName, new Date()).toString());
        } else {
            log.info("Signal " + signalName
                    + " set to be ignored by the configuration.");
        }
    }

    @SuppressWarnings("deprecation")
    public void checkAndNotify(Target target, Project prj) {
        String targetName = target.getName();
        String signalName = "unknown";
        
        if (isTargetInSignalConfigList(targetName)) {
            for (SignalConfig config : getSignalConfigs(targetName))
            {
                Vector<Notifier> notifierList = null;
                TargetCondition targetCondition = config
                        .getTargetCondition(targetName);
                String errorMessage = null;
                String failStatus = null;
                boolean buildFailed = false;
                if (targetCondition != null) {
                    List<String> fileList = getFileList(prj, config.getLogSourceList(),config.getSourceType());
                    log.debug("targetcondition:" + targetCondition);
                    Condition condition = getFailureCondition(targetName,
                            targetCondition, fileList);
                    errorMessage = targetCondition.getMessage();
                    String refid = config.getConfigId();
                    log.debug("refid:" + refid);
                    Object  configCurrent = prj.getReference(refid);
                    if (configCurrent != null && configCurrent instanceof SignalConfig) {
                        signalName = refid;
                    }
                    log.debug("SignalList:fail:signalName: " + signalName);
                    notifierList = config.getSignalInput().getSignalNotifierList();
                    if (notifierList == null) {
                        Object obj = (Object) prj
                                .getReference(DEFAULT_NOTIFIER_LIST_REFID);
                        if (obj instanceof SignalNotifierList) {
                            notifierList = ((SignalNotifierList) obj)
                                    .getNotifierList();
                        }
                    }
                    failStatus = config.getSignalInput().getFailBuild();
                    log.debug("SignalList:failStatus:" + failStatus);
                    buildFailed = condition != null;
                    sendNotify(notifierList, signalName, buildFailed,
                            fileList);
                }
                if (buildFailed) {
                    if (failStatus == null || failStatus.equals("now")) {
                        SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                                errorMessage, targetName, new Date()));
                        throw new BuildException(new SignalStatus(signalName,
                                errorMessage, targetName, new Date()).toString());
                    } else if (failStatus.equals("defer")) {
                        log.debug("SignalList1:adding defer signal:");
                        log.info("Signal " + signalName + " will be deferred.");
                        SignalStatusList.getDeferredSignalList().addSignalStatus(new SignalStatus(
                                signalName, errorMessage, targetName, new Date()));
                    } else if (failStatus.equals("never")) {
                        log.debug("SignalList1:adding never signal:");
                        SignalStatusList.getNeverSignalList().addSignalStatus(new SignalStatus(signalName,
                                errorMessage, targetName, new Date()));
                    } else if (!failStatus.equals("never")) {
                        SignalStatusList.getNowSignalList().addSignalStatus(new SignalStatus(signalName,
                                errorMessage, targetName, new Date()));
                        throw new BuildException(new SignalStatus(signalName,
                                errorMessage, targetName, new Date()).toString());
                    } else {
                        log.info("Signal " + signalName
                                + " set to be ignored by the configuration.");
                    }
                }
            }
        }
    }

    private List<String> getFileList(Project project, Vector<LogSource>sourceList,
            String sourceType) {
        List<String> fileList = new ArrayList<String>();
        if (sourceList != null) {
            for (LogSource l : sourceList)
            {
                File file = l.getFilename();
                if (file != null && file.exists()) {
                    fileList.add(project.replaceProperties(file.toString()));
                }
                if (sourceType == null || !sourceType.equals("combined")) {
                    break;
                    }
            }
        }
        return fileList;
    }
    
    private Condition getFailureCondition(String targetName,
            TargetCondition targetCondition, List<String> fileList) {
        Condition retCondition = null;
        
        for (Condition condition : targetCondition.getConditions()) {
            log.debug("SignalList:getErrorMessage:" + condition.eval());
            if (condition.eval()) {
                retCondition = condition;
                break;
            }
        }
        return retCondition;
    }
}