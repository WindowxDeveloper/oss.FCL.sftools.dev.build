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


package com.nokia.maven.scm.provider.hg.command.init;

import java.io.File;

import org.apache.log4j.Logger;
import org.apache.maven.scm.CommandParameters;
import org.apache.maven.scm.ScmException;
import org.apache.maven.scm.ScmFileSet;
import org.apache.maven.scm.ScmResult;
import org.apache.maven.scm.command.AbstractCommand;
import org.apache.maven.scm.command.Command;
import org.apache.maven.scm.provider.ScmProviderRepository;
import org.apache.maven.scm.provider.hg.HgUtils;
import org.apache.maven.scm.provider.hg.command.HgCommandConstants;
import org.apache.maven.scm.provider.hg.repository.HgScmProviderRepository;

import com.nokia.maven.scm.command.init.InitScmResult;

public class HgInitCommand extends AbstractCommand implements Command {
    
    private static Logger log = Logger.getLogger(HgInitCommand.class);

    @Override
    protected ScmResult executeCommand(ScmProviderRepository arg0,
            ScmFileSet arg1, CommandParameters arg2) throws ScmException {
        // TODO Auto-generated method stub
        return null;
    }

    public InitScmResult executeInitCommand(ScmProviderRepository repository)
            throws ScmException {
        // Get the directory in which to create a new repository. Only local
        // filesystems supported.
        log.info("executeInitCommand" + repository);
        HgScmProviderRepository hgRepo = (HgScmProviderRepository) repository;
        String uri = hgRepo.getURI();
        String fileUri = uri.substring("scm:hg:file:/".length());
        log.info(fileUri);
        File hgRepoDir = new File(fileUri);

        boolean workingDirReady = hgRepoDir.mkdirs();
        if (!workingDirReady) {
            throw new ScmException("Could not initiate test branch at: "
                    + hgRepoDir);
        }

        // Create and run the command
        String[] initCmd = new String[] { HgCommandConstants.INIT_CMD };
        HgUtils.execute(new File("f:/hg"), initCmd);
        return null;
    }
}
